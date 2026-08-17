# Migración de una instalación de Participa a PlebisHub

Guía para quien traiga datos de una instalación antigua. **No hace falta si tu
base de datos parte de cero**: PlebisHub ya crea las colaboraciones con el estado
correcto.

---

## 1. Estado de las colaboraciones (`collaborations.status`)

### Qué significa cada valor

```ruby
STATUS = { 'Sin pago' => 0, 'Error' => 1, 'Sin confirmar' => 2,
           'OK' => 3, 'Alerta' => 4, 'Migración' => 9 }
```

Los dos que importan aquí:

| Valor | Nombre          | Significado                                                                        |
| ----- | --------------- | ---------------------------------------------------------------------------------- |
| **0** | `Sin pago`      | La colaboración existe pero **todavía no hay ningún pago**                         |
| **2** | `Sin confirmar` | El callback de la pasarela volvió OK y está **pendiente de confirmación bancaria** |

El 2 lo pone `set_active!`, que solo se invoca desde la acción `OK` del
controlador, es decir, **después** de que la pasarela conteste.

### Por qué importa la diferencia

`has_payment?` es literalmente `status.positive?`, y de ahí depende el flujo:

```ruby
# CollaborationsController#confirm
redirect_to edit_collaboration_path if @collaboration.frequency.positive? && @collaboration.has_payment?
```

Comprobado sobre la aplicación real, con una colaboración recurrente recién
creada:

| Estado inicial    | `has_payment?` | `GET /colabora/confirmar`     |
| ----------------- | -------------- | ----------------------------- |
| `0` Sin pago      | `false`        | **200, renderiza el pago** ✅ |
| `2` Sin confirmar | `true`         | **302 → `/colabora/ver`** ❌  |

Y `create` redirige al usuario justo a `confirmar` tras dar de alta la
colaboración. Con estado 2 rebota inmediatamente a `ver`, así que **el usuario
nunca llega a la pantalla de pago**.

Por eso el valor correcto al crear es **0**, aunque «ha entrado en el flujo» sea
una descripción razonable en abstracto: con `has_payment? = status > 0`, un 2
inicial afirma que ya hay pago y rompe el paso de confirmación.

### El bug histórico

`set_initial_status` siempre quiso poner 0, pero durante años fue un
`after_create` con una asignación que **no se persistía**, así que mandaba el
valor por defecto de la columna:

| Desde        | Defecto de columna               | Resultado                                                               |
| ------------ | -------------------------------- | ----------------------------------------------------------------------- |
| —            | `0`                              | Coincidía con la intención, sin daño                                    |
| `2020-11-10` | `2` (migración `20201110125929`) | **Toda colaboración nueva nació como «Sin confirmar» sin haber pagado** |
| `2025-11-30` | `2`                              | `d4820c38` lo pasa a `before_create`: vuelve a persistir 0              |

O sea: las instalaciones que estuvieran en producción **entre el 10/11/2020 y el
30/11/2025** tienen filas con estado 2 que deberían ser 0.

> En **este** repositorio no hay nada que migrar: es un fork que nunca se ha
> llevado a producción. `rake plebisbrand:collaboration_status:analyze` lo
> confirma devolviendo 0 en todos los recuentos.

---

## 2. La herramienta

`lib/tasks/plebisbrand/collaboration_status.rake`

### Paso 1 — Analizar (solo lectura, no modifica nada)

```bash
bundle exec rake plebisbrand:collaboration_status:analyze
```

Informa de cuántas colaboraciones se crearon en la ventana afectada, cuántas
están en estado 2, y las separa en tres grupos según la evidencia de haber
entrado de verdad al flujo de pago:

```
A) sin ninguna orden ..................    123   <- casi seguro el bug
B) con ordenes pero ninguna cobrada ...     45   <- probable, revisar
C) con alguna orden cobrada ...........     12   <- NO tocar
```

**Por qué tres grupos y no uno.** Un 2 legítimo y un 2 por el bug son
indistinguibles mirando solo la columna `status`. Lo único que los separa es si
la colaboración llegó a generar cobros:

- **A** nunca generó ninguna orden → no pasó por el flujo de pago. Es el bug.
- **B** tiene órdenes pero ninguna cobrada → probablemente el bug, pero conviene
  mirarlo antes de tocar.
- **C** tiene alguna orden cobrada → estuvo activa de verdad. **No se toca nunca.**

### Paso 2 — Simular

```bash
bundle exec rake plebisbrand:collaboration_status:migrate
```

Por defecto es un **simulacro**: dice cuántas filas cambiaría, cuántas dejaría
intactas y enseña una muestra de hasta 10, pero no escribe nada.

Para ampliar el criterio al grupo B:

```bash
bundle exec rake plebisbrand:collaboration_status:migrate SCOPE=sin_cobros
```

### Paso 3 — Aplicar, con autorización expresa

```bash
bundle exec rake plebisbrand:collaboration_status:migrate CONFIRM=SI
```

Sin `CONFIRM=SI` **nunca** escribe. Al aplicarlo:

- corre dentro de una transacción;
- usa `update_all`, sin disparar callbacks ni validaciones (es una corrección de
  datos, no una operación de negocio);
- deja los ids modificados en `tmp/collaboration_status_migrated.txt` para poder
  auditar o revertir.

**Antes de ejecutarlo en producción, haz copia de seguridad de la tabla:**

```sql
CREATE TABLE collaborations_backup_estado AS
  SELECT id, status FROM collaborations;
```

Y para revertir:

```sql
UPDATE collaborations c SET status = b.status
  FROM collaborations_backup_estado b WHERE b.id = c.id;
```

---

## 3. Verificación posterior

```bash
bundle exec rake plebisbrand:collaboration_status:analyze
```

Los grupos A (y B, si lo incluiste) deben quedar a 0 y C sin tocar.

Comprobación funcional: entra con un usuario que tuviera una colaboración
afectada y abre `/colabora/confirmar`. Debe **renderizar la pantalla de pago**,
no redirigir a `/colabora/ver`.

---

## 4. Nota sobre el valor por defecto de la columna

El defecto de `collaborations.status` sigue siendo **2**. Ya no afecta al
funcionamiento normal, porque `before_create :set_initial_status` escribe 0 en
cada alta, pero es una trampa latente para cualquier inserción que no pase por el
modelo (importaciones con SQL directo, `insert_all`, cargas masivas).

Hoy ninguna importación depende de ese defecto: `lib/plebisbrand_import_collaborations2017.rb`
asigna `status = 2` explícitamente, que es lo correcto para colaboraciones que
llegan ya activas desde otro sistema.

Si vas a hacer cargas masivas por SQL, **asigna el estado explícitamente** en vez
de confiar en el defecto de la columna.
