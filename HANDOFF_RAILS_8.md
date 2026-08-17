# Handoff — upgrade a Rails 8

Estado tras cerrar el plan completo. Documento de referencia para retomar.

---

## 1. Estado actual

|                           |                                                          |
| ------------------------- | -------------------------------------------------------- |
| Rama                      | `rails-8-upgrade`                                        |
| Punto de retorno          | tag `pre-rails8-baseline` (commit `74ead484`)            |
| **Rails**                 | **8.1.3.1** con `config.load_defaults 8.1`               |
| **Ruby**                  | **3.4.10** (3.5 solo existe como `preview1`)             |
| **Devise**                | **5.0.4**                                                |
| Commits desde el baseline | 43, cada uno revertible por separado                     |
| Despliegue                | **NO ejecutado** — es la única decisión humana que queda |

### Puerta de despliegue (las 9 condiciones de `RAILS_8_REMAINING_WORK_PLAN.md` §2)

| #   | Condición                 | Comando                                 | Estado                                                     |
| --- | ------------------------- | --------------------------------------- | ---------------------------------------------------------- |
| 1   | Suite raíz                | `bundle exec rspec spec`                | ✅ 10.185 ejemplos, 0 fallos                               |
| 2   | Suites de engines         | `bundle exec rspec engines`             | ✅ 2.231 ejemplos, 0 fallos                                |
| 3   | Sin dependencia del orden | 3 semillas, ambas suites juntas         | ✅ 12.416 ejemplos, 0 fallos en las 3 (1234 / 4321 / 9876) |
| 4   | Eager loading             | `bin/rails zeitwerk:check`              | ✅ _All is good_                                           |
| 5   | Arranque en producción    | `RAILS_ENV=production bin/rails runner` | ✅                                                         |
| 6   | Vulnerabilidades          | `bundle exec bundler-audit check`       | ✅ 0 hallazgos                                             |
| 7   | Análisis estático         | `bundle exec brakeman -q`               | ✅ 0 avisos, 0 entradas obsoletas                          |
| 8   | Estilo                    | `rubocop` con la config de CI           | ✅ 0 ofensas                                               |
| 9   | Sin duplicación pendiente | `bin/check_engine_duplication`          | ✅ 0 ficheros (40 delegan)                                 |

La config de CI para rubocop:

```bash
bundle exec rubocop --parallel \
  --except Layout/LineLength,Metrics/MethodLength,Metrics/AbcSize,Metrics/BlockLength,Metrics/ClassLength
```

Base de datos de trabajo: `plebis_eng` (separada de `plebis_hub_test`). Si hay que
recrearla: `RAILS_ENV=test DATABASE_NAME=plebis_eng bundle exec rails db:create db:schema:load`.

---

## 2. Lo que falta

### 2.1 Cobertura reactivada

La suite tenía **509 ejemplos saltados**. Se revisaron todos y se reactivaron los
que no tenían motivo real. El saldo:

| Fichero saltado                                             | Ejemplos | ¿Estaba justificado?                                                    |
| ----------------------------------------------------------- | -------: | ----------------------------------------------------------------------- |
| `spec/requests/blog_spec.rb` y otros 8 de request           |      280 | **No.** Pasaban tal cual                                                |
| `spec/requests/notice_spec.rb`                              |       81 | **No.** 79 pasaban; 2 eran specs mal escritos                           |
| `spec/controllers/open_id_controller_spec.rb`               |       77 | **No.** Bastaba activar OpenID en los secrets de test                   |
| `spec/controllers/api/v1/brand_settings_controller_spec.rb` |       21 | **No.** Pasaba entero                                                   |
| 16 `xit` sueltos                                            |       16 | **No** en 10 de ellos                                                   |
| `spec/requests/devise_unlocks_new_spec.rb` + mailer         |       18 | **Sí**: `unlock_strategy = :time`, Devise no genera rutas de desbloqueo |

O sea: de 509 pendientes quedan **18**, y los 18 con el motivo verificado, no
supuesto. Reactivarlos destapó 7 bugs de producción (los números 32 a 38).

La lección para futuras revisiones: **un `skip` con un motivo plausible no es un
motivo verificado**. Casi todos decían «comprueban estructura HTML concreta» y
casi ninguno era cierto.

### 2.2 Despliegue

**Solo el despliegue.** Requiere saber el entorno destino y si hay credenciales en
la máquina; es la única decisión que no se puede tomar desde aquí.

Antes de desplegar conviene leer §3: hay cambios de comportamiento visibles.

---

## 3. Cambios de comportamiento que verá un usuario

Corregir los bugs cambia lo que hace la aplicación. Lo relevante para producción:

1. **Toda colaboración nueva nacía con estado 2 («Sin confirmar») en vez de 0
   («Sin pago»).** Al investigarlo resultó no ser una regresión de la fase B sino
   un bug que **estuvo años en producción**:
   - hasta el **2020-11-10** el valor por defecto de la columna era 0, así que el
     `after_create` con `self.status = 0` (que no persiste) era inocuo;
   - la migración `20201110125929` cambió el defecto a **2**, y desde entonces
     toda colaboración nueva quedó con 2;
   - el **2025-11-30** (`d4820c38`, ya en master) se cambió a `before_create` y
     dejó de ocurrir;
   - la consolidación de la fase B lo reintrodujo **solo en esta rama**, que nunca
     se desplegó.

   Importa porque `has_payment?` es `status.positive?`: una colaboración con 2
   afirma tener pago sin tenerlo, y de ahí dependen las ramas de `edit` y
   `confirm`. **Los registros de esa ventana de 5 años no se han migrado.** Para
   medir el alcance antes de decidir, hay una tarea de solo lectura:

   ```bash
   bundle exec rake plebisbrand:diagnose_collaboration_status
   ```

2. **La sección `/colabora` entera devolvía error 500** (`ActionNotFound`). Al
   arreglarla vuelve a estar accesible.
3. **La aplicación no arrancaba con `RAILS_ENV=production`** (`FrozenError` en la
   pila de middleware). Nunca se llegó a desplegar esta rama, así que el impacto
   es futuro, no pasado.
4. **Los límites de `Rack::Attack` valían la mitad** de lo configurado, porque el
   middleware estaba registrado dos veces. Al corregirlo, los límites efectivos
   se duplican respecto a lo que había en marcha: revisar que los valores de
   `config/initializers/rack_attack.rb` siguen siendo los deseados.
5. **Cinco pantallas del admin no existían** (`Category`, `Notice`, `Page`,
   `Post`, `ParticipationTeam`): sus ficheros vivían solo en los engines, que
   ActiveAdmin nunca cargaba. Ahora aparecen en el menú.
6. **Los códigos de credencial** de ~11 % de los usuarios cambian (bug 4).
   Además, el envío de credenciales marcaba la verificación como enviada con un
   `update` que corría las validaciones: si fallaban, el guardado fallaba en
   silencio y **ese usuario volvía a entrar en el siguiente envío** (bug 32 de la
   tanda anterior). Conviene revisar si hay usuarios que hayan recibido la
   credencial impresa más de una vez.
7. **OpenID vuelve a funcionar.** Estaba completamente roto (bugs 32-35). Si
   había partes confiadas integradas contra él, llevaban tiempo sin poder
   autenticar. Ojo: es OpenID 2.0, **deprecado desde 2014**; el propio
   controlador recomienda migrar a OIDC.
8. **El censo por CSV y el voto en papel vuelven a funcionar** (bug 36).
9. **Los informes de verificación dejan de salir vacíos** (bug 37): pasan a
   devolver 52 provincias y 227 municipios.
10. **Los teléfonos válidos se rechazaban y los inválidos se aceptaban** en los
    formularios de Impulsa: los datos ya guardados pueden ser inválidos.

---

## 4. Los 38 bugs de PRODUCCIÓN encontrados

Ninguno lo causó el cambio de versión. El upgrade los destapó al obligar a
ejecutar código y tests que nadie ejecutaba.

### Configuración y arranque

1. **Secrets anidados devolvían `nil`** — `config_for` symboliza claves y el código
   las lee como strings en sus 254 usos.
2. **Eager loading roto desde 7.2** — producción arranca con `eager_load = true` y
   `zeitwerk:check` fallaba. 7 capas corregidas.
3. **`root_url` en engines montados** — los 8 engines heredan `ApplicationController`;
   sus 3 redirects de acceso denegado lanzaban `UrlGenerationError`.
4. **La aplicación no arrancaba en producción** — `asset_caching.rb` registraba
   `Rack::Deflater` dentro de un `after_initialize`, con la pila ya congelada.
5. **Las cabeceras de caché `immutable` no se aplicaban nunca** — se fijaban
   después de construir `ActionDispatch::Static`.
6. **`Rack::Attack` registrado dos veces** — en `application.rb` y por el railtie
   de la gema: todos los límites de tasa valían la mitad.

### Verificación e identidad

4. **Códigos de credencial malformados** — `to_s(32)` no rellena con ceros: 10,8 %
   de los `user_id` producían códigos de 6-7 caracteres en un fichero que se
   imprime y se envía por correo postal.
5. **`sms_confirmation_attempts` no existe en `User`** — cualquier código SMS
   incorrecto lanzaba `NoMethodError`.
6. **`authenticated_root_path` sin `main_app`** — un código SMS **correcto**
   acababa en la pantalla de error.
7. **`edit_user_registration_path` / `create_vote_path` sin `main_app`**.
8. **`UserVerification` reventaba con `NoMethodError` sobre `nil`** al validar un
   registro sin usuario (`require_back?` / `not_require_photos?`).
9. **`UserVerification#determine_initial_status`** devolvía String en una rama y
   símbolos en las otras.

### Territorio y votaciones

15. **`VoteCircle#in_spain?`** comparaba el nombre del enum (String) contra los
    valores enteros: **siempre false**. Afectaba al formulario de colaboraciones,
    a la exportación de órdenes y a una rake task.
16. **`ElectionLocationQuestion#options=`** reventaba con `nil` antes de que la
    validación pudiera informar del campo obligatorio.
17. **`VoteController#create`** perdió los `return` antes de los redirect del
    control por SMS: la acción seguía ejecutándose tras redirigir.
18. **`VoteController#create_token`** perdió la mitigación SEC-036: el
    cortocircuito de `&&` volvía a filtrar por tiempos qué comprobación falló.

### Impulsa

16. **Validación de teléfono invertida** en el wizard y en la evaluación:
    rechazaba los válidos y aceptaba los inválidos.
17. **`wizard_eval_condition`** llamaba a `SafeConditionEvaluator.evaluate` sobre
    el módulo, donde ese método no existe: **toda** condición lanzaba
    `NoMethodError` y los grupos condicionados del wizard nunca se validaban.
18. **El tokenizador de `SafeConditionEvaluator`** descartaba en silencio el texto
    que no encajaba: una condición mal escrita se evaluaba como **verdadera**.
19. **`available_frequencies_for_user`** hacía `FREQUENCIES.to_a.slice(...)`.

### Colaboraciones y pagos

10. **`PARENT_CLASSES[parent.class]`** dejó de casar al heredar. Resuelto por
    ascendencia.
11. **4 validaciones de `MicrocreditLoan`** accedían a `microcredit` sin comprobar
    que existiera.
12. **`redsys_callback_response` lanzaba `FrozenError`** — `rstrip!` sobre un
    heredoc con `frozen_string_literal`.
13. **`redsys_expiration` lanzaba `TypeError`** si Redsys no devolvía
    `Ds_ExpiryDate`.
14. **`CollaborationsController` listaba `confirm_bank`** en el `only:` de un
    `before_action` y esa acción no existe: `ActionNotFound` en **cualquier**
    petición al controlador.
15. **`Collaboration#set_initial_status`** pasó de `before_create` a
    `after_create`: la asignación no se persistía.
16. **`Collaboration#set_warning!`** perdió la guarda `persisted?`:
    `check_spanish_bic` lo llama desde un `before_save`.
17. **`Collaboration#default_url_options`** desapareció: enlaces sin dominio.

### OpenID (todos destapados al activarlo en los secrets de test)

32. **El proveedor OpenID no funcionaba en absoluto** — `decode_request` recibía
    `params`, que desde Rails 5 es `ActionController::Parameters` y no un Hash:
    ruby-openid le llamaba a `length` y **toda** petición contestaba 500.
33. **`/user/xrds` era inalcanzable** — `/user/:id` se declaraba antes y la
    capturaba con `id="xrds"`, así que quien pedía el documento XRDS recibía la
    página HTML de identidad.
34. **Una petición sin parámetros devolvía 500** en vez de la página informativa
    que el propio código construye: `render_response` llamaba a `needs_signing`
    sobre un `WebResponse`, que no lo tiene.
35. **`is_authorized` devolvía `nil`** en vez de `false` cuando no hay usuario.

### Censo, informes y admin

36. **El parseo del censo por CSV estaba roto** —
    `app/services/census_file_parser.rb` usaba `Paperclip.io_adapters`, pero la
    gema ya no está en el Gemfile y la constante **no existe en runtime**:
    `NameError`. Afectaba al voto en papel y a las elecciones con censo CSV.
    `census_file` ya es un adjunto de ActiveStorage.
37. **Los tres informes de verificación devolvían vacío en silencio** — pasaban
    SQL crudo a `pluck`, que Rails 8 rechaza con `UnknownAttributeReference`, y
    el `rescue` se lo tragaba. Tras el arreglo: 52 provincias y 227 municipios.
38. **`OpenStruct.human_attribute_name` con firma incompatible** —
    `loan_renewal_service.rb` reabre `OpenStruct` (clase global) y la definía con
    un solo argumento cuando Rails la llama con `(attribute, options = {})`.
    Dejaba en **500 permanente** la ficha de Activaciones de Engines del admin.
    En producción el eager loading carga siempre ese fichero.

### Otros

8.  **Traducciones ausentes** `plebisbrand.errors.*`.
9.  **`Gamification::ProposalListener`** resolvía el usuario con `proposal.author`,
    que es una **columna de texto**, no una asociación.
10. **`Notice#broadcast_gcm`** usaba `in_groups_of(1000)` sin desactivar el
    relleno: enviaba a GCM cientos de destinatarios `nil` por lote.

---

## 5. Decisión arquitectónica vigente

**Los engines son la fuente de la verdad. La app solo personaliza heredando, al
estilo Devise** (`class Collaboration < PlebisCollaborations::Collaboration`).

Verificado: ninguna de las 12 tablas implicadas tiene columna `type`, así que
heredar **no activa STI**.

`bin/check_engine_duplication` es la condición 9 de la puerta de despliegue.

### `app/admin` — lo contrario de lo que parecía

El handoff anterior suponía que para `app/admin/*` la copia viva era la de la app
y que consolidar era arriesgado. Lo primero era cierto y lo segundo no:

- ActiveAdmin solo carga `Rails.root/app/admin`, así que los `app/admin` de los
  engines **nunca se habían ejecutado** y conservaban la sintaxis de ActiveAdmin 2
  (`status_tag(x, :ok)`, `params.merge`).
- La consolidación va, por tanto, **de la app al engine**: los 13 ficheros se
  movieron con sus arreglos de Rails 8, cualificando las constantes de modelo.
- `config.load_paths` en `config/initializers/active_admin.rb` añade los
  `app/admin` de los engines.
- Los recursos conservan su nombre con `as:`, así que **no se movió ninguna de las
  64 rutas del admin**.

---

## 6. Patrones que se repiten en los specs

Casi ningún fallo era del código de test en sí: los specs se escribieron contra
comportamiento que **nunca se ejecutaba**.

- **Doble sobre la clase equivocada**: `allow_any_instance_of(Election)` no aplica
  porque las consultas devuelven `PlebisVotes::Election`. Es el patrón más
  frecuente con diferencia. Igual con `allow(Order).to receive(...)` para métodos
  de clase, y con los argumentos: `.with(:read, UserVerification)`.
- **Stub sobre la instancia equivocada**: `allow(user).to receive(...)` no aplica
  porque `current_user` es otra instancia cargada de la sesión.
- **Desajuste de clase**: `ActiveRecord#==` exige `instance_of?`, así que un
  registro del engine nunca es `==` a uno de la factory de la app. Comparar por
  `id`.
- **Expectativa acotada sin stub permisivo debajo**: con
  `expect(X).to receive(:m).with(...)`, cualquier otra llamada a `:m` falla.
- **`parent_type` polimórfico** guarda la `base_class`, o sea la del engine.
- **Datos que no pasan validación**: teléfonos que no son móviles españoles,
  `terms_of_service: true` cuando la validación admite `[true, '1']`, adjuntos
  obligatorios ausentes.
- **Locale**: el arnés fija `I18n.locale = :es`. Ojo con
  `Rails.application.routes.default_url_options[:locale]`: se fijaba en cada spec
  de tipo `:request` y no se restauraba, lo que hacía que las suites pasaran por
  separado y fallaran juntas.
- **`main_app.` en specs de engine**: incluir `url_helpers` no basta, porque
  `_routes` apunta al route set del engine.

---

## 7. Documentos relacionados

- `RAILS_8_UPGRADE_PLAN.md` — plan original, con las secciones desmentidas marcadas
- `RAILS_8_UPGRADE_LOG.md` — registro de ejecución, resultados y desviaciones
- `RAILS_8_REMAINING_WORK_PLAN.md` — las 9 condiciones que habilitan el despliegue
