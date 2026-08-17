# Plan de cierre — de 228 fallos a despliegue

Continuación de [RAILS_8_UPGRADE_LOG.md](RAILS_8_UPGRADE_LOG.md). Cubre los 4 puntos
abiertos y define **exactamente** qué significa «100 % correcto», porque ese es el
requisito que habilita el despliegue.

**Rama:** `rails-8-upgrade` · **Punto de retorno:** tag `pre-rails8-baseline`
**Estado de partida:** Rails 8.1.3.1 / Ruby 3.4.10 · suite raíz 10.522/0 · engines 228 fallos

---

## 1. Decisión arquitectónica (resuelve el punto 3)

> **Los engines son la fuente de la verdad. La aplicación solo contiene
> personalizaciones, igual que se hace con Devise.**

Hoy conviven dos jerarquías de clases sobre las mismas tablas. Con Devise el patrón ya
está establecido en este repositorio y es el que se replica:

```ruby
# La gema/engine aporta la funcionalidad
Devise::ConfirmationsController

# La app solo personaliza, heredando
class ConfirmationsController < Devise::ConfirmationsController
  # …solo lo que cambia
end
```

### Patrón objetivo por tipo de artefacto

| Hoy | Objetivo |
|---|---|
| `app/models/collaboration.rb` (450 líneas, copia completa) | `class Collaboration < PlebisCollaborations::Collaboration; end` o eliminado |
| `engines/plebis_collaborations/app/models/.../collaboration.rb` | **Canónico.** Toda la lógica vive aquí |
| `app/controllers/microcredit_controller.rb` | Ya sigue el patrón: hereda del engine ✅ |
| `config/initializers/plebis_*_aliases.rb` | Se elimina: el alias deja de hacer falta cuando la app hereda explícitamente |

### Reglas de decisión, aplicables sin ambigüedad

1. Si el fichero de `app/` y el del engine son **equivalentes** → borrar el de `app/` y
   dejar que el alias del engine resuelva el nombre.
2. Si el de `app/` tiene **lógica que el engine no tiene** → mover esa lógica al engine y
   borrar el de `app/`.
3. Si esa lógica es **específica de esta instalación** (marca, textos, integraciones
   propias) → dejar en `app/` una subclase que herede del engine con solo esa parte.
4. Si el del engine está **incompleto** respecto al de `app/` → completar el engine
   primero, nunca al revés.

### Inventario a consolidar

| Engine | Modelos duplicados en `app/` |
|---|---|
| `plebis_collaborations` | `collaboration.rb`, `order.rb` |
| `plebis_votes` | `election.rb`, `election_location.rb`, `election_location_question.rb`, `vote.rb`, `vote_circle.rb`, `vote_circle_type.rb` |
| `plebis_impulsa` | `impulsa_*.rb` + 3 concerns en `app/models/concerns/` |
| `plebis_microcredit` | `microcredit.rb`, `microcredit_loan.rb` |
| `plebis_cms` | `notice.rb`, `page.rb`, `post.rb` |
| resto | pendiente de inventariar en A.0 |

---

## 2. Definición de «100 % correcto» — la puerta al despliegue

El despliegue **no se ejecuta** hasta que estas 9 condiciones se cumplan a la vez, todas
verificables por comando, sin juicio subjetivo:

| # | Condición | Comando | Umbral |
|---|---|---|---|
| 1 | Suite raíz | `bundle exec rspec spec` | 0 fallos |
| 2 | Suites de engines | `bundle exec rspec engines` | **0 fallos** |
| 3 | Sin dependencia del orden | 3 seeds distintos, ambas suites | 0 fallos en las 3 |
| 4 | Eager loading | `bin/rails zeitwerk:check` | *All is good* |
| 5 | Arranque en producción | `RAILS_ENV=production bin/rails runner` | sin excepción |
| 6 | Vulnerabilidades | `bundle exec bundler-audit check` | **0 hallazgos** |
| 7 | Análisis estático | `bundle exec brakeman -q` | 0 avisos |
| 8 | Estilo | `bundle exec rubocop` (config CI) | 0 ofensas |
| 9 | Sin duplicación pendiente | script `bin/check_engine_duplication` | 0 ficheros duplicados |

La condición 6 implica **Devise 5.0.4** (punto 2 de la lista abierta): es la única
vulnerabilidad que queda.

La condición 3 es la que evita repetir lo vivido: tres fuentes de intermitencia ya
corregidas que habrían hecho fallar CI de forma aleatoria.

---

## 3. Fases

### Fase A — Cerrar los 228 fallos de engines *(sin cambios de arquitectura)*

Trabajo mecánico y medible, fichero a fichero, del más cargado al menos. Ya hay
precedente: `application_helper_spec.rb` pasó de 17 a 0.

| Fichero | Fallos |
|---|---:|
| `plebis_verification/…/user_verifications_controller_spec.rb` | 33 |
| `plebis_verification/…/sms_validator_controller_spec.rb` | 24 |
| `plebis_microcredit/…/loan_renewal_service_spec.rb` | 17 |
| `plebis_collaborations/…/collaborations_mailer_spec.rb` | 15 |
| `plebis_votes/…/territory_details_spec.rb` | 12 |
| `plebis_cms/…/blog_controller_spec.rb` | 10 |
| resto (~20 ficheros) | 100 |
| ~~`plebis_microcredit/…/application_helper_spec.rb`~~ | ~~17~~ ✅ |

**Ciclo por fichero, automatizable:** ejecutar → agrupar fallos por mensaje → arreglar la
causa común → re-ejecutar → pasar al siguiente. Medición siempre contra base de datos
recién cargada (§1 del registro: una BD sucia inflaba el recuento de 447 a 604).

**Regla:** si el arreglo correcto exige consolidar duplicación, se anota y se pospone a la
Fase B en lugar de parchear el spec.

### Fase B — Consolidación app → engines *(el punto 3)*

Por engine, en orden de menor a mayor riesgo, un commit por engine:

1. `diff` entre la copia de `app/` y la del engine.
2. Aplicar las reglas de decisión de §1.
3. Completar el engine si le falta algo.
4. Sustituir el fichero de `app/` por subclase o borrarlo.
5. Retirar el `config/initializers/plebis_*_aliases.rb` correspondiente.
6. Suite raíz + suite del engine en verde antes de pasar al siguiente.

Orden propuesto: `participation` → `gamification` → `proposals` → `cms` → `impulsa` →
`microcredit` → `verification` → `votes` → `collaborations`.

> **Aviso de alcance honesto.** Esto no es un cambio mecánico. Son ~30 modelos, sus
> controladores, vistas y specs, sobre un dominio con dinero (Redsys, microcréditos,
> remesas Norma43) y votaciones. Cada engine es un PR revisable por separado, y el
> orden está pensado para que los de mayor riesgo lleguen con el patrón ya rodado.

### Fase C — Devise 4.9.4 → 5.0.4 *(el punto 2)*

Cierra la condición 6. Cambios conocidos a revisar: los 8 controladores que heredan de
Devise, `config/initializers/devise.rb`, y `error_status`/`redirect_status`.

### Fase D — Revisar el impacto en producción del bug de secrets *(el punto 1)*

No es código: es una revisión funcional de qué llevaba degradado.

| Área | Qué comprobar |
|---|---|
| Ágora | `secrets.agora['servers']`, `['default']`, `['themes']` → integración de votaciones |
| Formularios embebidos | `secrets.forms['domain']`, `['secret']` → CMS e iframes |
| Microcréditos | `secrets.microcredits['brands']` → marca, remitente, URLs en emails |
| Órdenes | `secrets.orders['payment_day']` → día de cobro |
| Redsys | `secrets.redsys[...]` → pasarela de pago |

Se entrega como informe, no como parche.

### Fase E — Despliegue

**Sólo si las 9 condiciones de §2 están en verde.**

1. `cap staging deploy` + verificación manual de los 10 flujos críticos (§10 del plan
   original).
2. Observación en staging.
3. `cap production deploy`.
4. Rollback listo: `cap production deploy:rollback`; sin migraciones destructivas.

> **Necesito confirmación tuya en este punto**, no por la decisión —ya me la has dado—
> sino por los datos: qué entorno es el destino, y si las credenciales de despliegue
> están disponibles en esta máquina. No voy a desplegar a ciegas.

---

## 4. Automatización

### Guardas en CI (impiden la regresión)

- `zeitwerk:check` ✅ ya añadido
- suites de engines ✅ ya añadidas — **quitar `continue-on-error` al terminar la Fase A**
- añadir: `bundler-audit` sin excepciones y el script de duplicación de la condición 9
- añadir: segunda ejecución con seed distinto, para cazar dependencias de orden

### Herramientas a crear

| Script | Función |
|---|---|
| `bin/check_engine_duplication` | Lista ficheros presentes en `app/` y en un engine; sale con 1 si hay alguno |
| `bin/verify_release` | Ejecuta las 9 condiciones de §2 y devuelve un informe |

---

## 5. Orden de ejecución

```
A (228 → 0)  →  C (Devise 5)  →  B (consolidación, 9 PRs)  →  D (informe)  →  E (despliegue)
```

C va antes que B a propósito: es acotado, cierra una condición de la puerta y no interfiere
con la consolidación.

**Estimación honesta:** A es de horas. C, de horas. B es el grueso: días de trabajo con
revisión humana por engine. D es una tarde. La puerta de §2 no se abrirá en una sesión.
