# Plan de Actualización a Rails 8 — PlebisHub

> ## ⚠️ ESTADO: EJECUTADO — este documento es el plan original, conservado como referencia
>
> **El upgrade está hecho.** Lo que realmente ocurrió, con las desviaciones y las
> hipótesis que resultaron falsas al medirlas, está en
> **[RAILS_8_UPGRADE_LOG.md](RAILS_8_UPGRADE_LOG.md)** — ese es el documento vivo.
>
> Varias secciones de abajo quedaron **obsoletas o desmentidas** durante la ejecución.
> Están marcadas con ❌. No las uses como referencia sin leer antes el registro.

**Fecha del plan:** 2026-08-16 · **Ejecutado:** 2026-08-16
**Origen:** Rails 7.2.3 / Ruby 3.4.4 → **Estado final: Rails 8.1.3.1 / Ruby 3.4.10**
**Rama:** `rails-8-upgrade` · **Punto de retorno:** tag `pre-rails8-baseline`
**Método:** guía oficial `https://guides.rubyonrails.org/upgrading_ruby_on_rails.html`, avance versión menor a versión menor (7.2 → 8.0 → 8.1), nunca en un solo salto.

### Estado por fase

| Fase | Estado | Nota |
|---|---|---|
| 0 — Prerequisitos | ✅ Hecho | La suite ya estaba verde: §1.3 era falso ❌ |
| 1 — Preparación en 7.2 | ✅ Hecho | Solo se subieron las gems que bloqueaban |
| 1b — Gems abandonadas | ⏭️ No ejecutado | Solo `cocoon` está sin uso; el resto es funcionalidad viva |
| 2 — Rails 8.0 + `load_defaults 8.0` | ✅ Hecho | 10.522 ejemplos, 0 fallos |
| 3 — Rails 8.1 + `load_defaults 8.1` | ✅ Hecho | 10.522 ejemplos, 0 fallos |
| 4 — Limpieza de parches | 🔶 Parcial | Eager loading arreglado; `secrets` y ActionText siguen pendientes |
| 5 — Infraestructura | 🔶 Parcial | Docker y CI actualizados; **sin desplegar** |
| 6 — Verificación | ✅ Hecho | `zeitwerk:check`, brakeman, bundler-audit y rubocop en verde |

### Añadido sobre el plan original

| Trabajo | Estado |
|---|---|
| Ruby 3.4.4 → **3.4.10** (última estable) | ✅ Hecho |
| **3 bugs de producción** destapados y corregidos | ✅ Hecho — §0 del registro |
| Suites de los 9 engines: 447 → 228 fallos preexistentes | 🔶 En curso |
| CI cubre ahora engines y `zeitwerk:check` | ✅ Hecho |
| Fuentes de intermitencia de la suite (3) | ✅ Corregidas |

---

## 1. Diagnóstico del estado actual

### 1.1 Stack verificado

| Elemento | Estado real (verificado) |
|---|---|
| Rails | 7.2.3 (`Gemfile.lock`), `config.load_defaults 7.2` |
| Ruby | `.ruby-version` = 3.4.4; `Gemfile` = `ruby '>= 3.3.6'`; Dockerfile = **ruby:3.3.6-alpine** (desalineado) |
| Rack | 3.2.4 (ya en Rack 3, un obstáculo menos) |
| Arranque | ✅ `require "./config/environment"` arranca sin error |
| BD | PostgreSQL (`pg` 1.6.2) en runtime; `sqlite3` 1.7.3 declarado en Gemfile |
| Assets | **Doble pipeline**: Sprockets 4.2.2 (`sass-rails`, `coffee-rails`, `jquery-rails`, `bootstrap-sass` 3.4.1, `font-awesome-rails`) + Vite 3.0.19 / Vue 3 (`app/frontend`) |
| Jobs | Sidekiq 7.3.9 + Redis 5.4.1 |
| Admin | ActiveAdmin 3.4.0 — **43 ficheros** en `app/admin` + engines, 25 specs |
| Auth | Devise 4.9.4 |
| Servidores | Puma 6.6.1 **y** Unicorn 6.1.0 (ambos declarados) |
| Deploy | Capistrano 3.10 + Docker Compose |
| CI | `.github/workflows/ci.yml` con **solo `workflow_dispatch`** (automatismo comentado) |

### 1.2 Tamaño del código

- 92 modelos, 39 controladores, 302 vistas, 173 migraciones
- 9 engines locales (`engines/plebis_*`), todos con `spec.add_dependency 'rails', '~> 7.2.3'` — **pin restrictivo que bloquea el bundle update**
- 309 ficheros de spec, ~3.735 ejemplos

### 1.3 Salud de la suite de tests (baseline crítico) — ❌ FALSO

> **Desmentido al medirlo.** Esta sección se apoyaba en `TEST_SUITE_STATUS.md`
> (3-dic-2025), que estaba obsoleto. Al ejecutar la suite el 16-ago-2026:
> **10.522 ejemplos, 0 fallos, 666 pending, 86,64 % de cobertura**. El
> prerequisito bloqueante ya estaba cumplido.
>
> El plan tampoco contaba con las **suites de los 9 engines** (2.188 ejemplos),
> que no forman parte de la suite raíz ni de CI y acumulaban **447 fallos**.
> Ese era el verdadero agujero de cobertura.

<details><summary>Texto original del plan (obsoleto)</summary>

Según `TEST_SUITE_STATUS.md` (3-dic-2025):

| Categoría | Ejemplos | Fallos |
|---|---|---|
| Models / Views / Controllers / Services / Mailers | 2.602 | 0 |
| **Requests** | **1.133** | **240 (21%)** |
| **Total** | **3.735** | **240 (6,4%)** |

</details>

### 1.4 Deuda técnica que condiciona el upgrade

1. **`Rails.application.secrets` parcheado a mano** — `config/application.rb` redefine `secrets` y hace `config.secrets = config_for(:secrets)` para revivir una API eliminada en Rails 7.2. Hay **254 usos** en ~40 ficheros (modelos, mailers, admin, initializers, engines, rutas). Funciona por el `method_missing` de `Rails::Railtie::Configuration`; es frágil y debe verificarse en cada salto.
2. **Frameworks desactivados por workarounds** en `config/application.rb`:
   - `action_text/engine` comentado ("causes FrozenError in Rails 7.2 test environment")
   - `rails/test_unit/railtie` comentado
   - `config.add_autoload_paths_to_load_path = true` forzado para que engines legacy puedan mutar `autoload_paths`
   - `config/initializers/unfreezeautoload_paths.rb` y `ruby_3_file_exists_patch.rb` — parches activos
3. **Duplicación app/ ↔ engines/** — p.ej. `app/models/collaboration.rb` y `engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb` conviven. Cada corrección hay que aplicarla dos veces.
4. **`belongs_to_required_by_default = false`** en `new_framework_defaults.rb` (default moderno desde Rails 5).
5. Gems sin mantenimiento en el árbol (ver §5).

### 1.5 Grep de APIs eliminadas — resultado

| Patrón | Estado |
|---|---|
| `enum status: {...}` (keyword, **eliminado en 8.0**) | ✅ 0 ocurrencias (los 5 `enum` usan sintaxis nueva) |
| `before_filter` / `render :text` en código productivo | ✅ 0 (solo comentarios históricos) |
| `update_attributes` | ✅ 0 |
| `ActiveSupport::ProxyObject`, `ActiveSupport::Configurable` | ✅ 0 |
| `read_encrypted_secrets`, `Rails::ConsoleMethods`, `use_big_decimal_serializer`, `warn_on_records_fetched_greater_than`, `commit_transaction_on_non_local_return` | ✅ 0 |
| Active Storage `:azure` | ✅ no usado (solo comentario en `storage.yml`) |
| **`mb_chars`** (deprecado en 8.1) | ⚠️ **6 usos** en `app/models/collaboration.rb` y su gemelo del engine |
| **`ActiveSupport.to_time_preserves_timezone = true`** | ⚠️ en `new_framework_defaults.rb` — sintaxis eliminada en 8.1 |
| **`active_job.enqueue_after_transaction_commit`** | ⚠️ en `new_framework_defaults_7_2.rb` — **eliminado en 8.1** |
| `params.require(...).permit` | ℹ️ 16 usos — migrables a `params.expect` (8.0, opcional) |

**Conclusión del diagnóstico:** el código de aplicación está sorprendentemente limpio de APIs eliminadas. El riesgo real no está en el código propio sino en **(a) las gems del ecosistema, (b) los 240 tests rojos y (c) los parches de compatibilidad acumulados**.

> **Revisión tras ejecutar.** El punto (a) resultó trivial: Rails 8.0 y 8.1 resolvieron
> con solo tres cambios de gem. El (b) era falso (§1.3). El (c) acertó, pero se quedó
> corto: los parches acumulados no solo estorbaban, **escondían tres bugs de
> producción** (secrets con claves string, `root_url` en engines montados y códigos de
> credencial malformados). El riesgo real no estaba en migrar de versión, sino en el
> código que llevaba años sin ejecutarse: eager loading y suites de engines.

---

## 2. Estrategia y decisión de alcance

### 2.1 Hallazgo que define la estrategia: ActiveAdmin

ActiveAdmin es la dependencia más pesada del proyecto (43 ficheros de admin). Verificado contra el repositorio oficial:

| Versión AA | Matriz de CI (gemfiles/) |
|---|---|
| 3.5.2 (última estable, jul-2026) | rails_61, rails_70, rails_71, rails_72, **rails_80** |
| 4.0.0.beta22 y `master` | rails_72, **rails_80** |

**ActiveAdmin no testea Rails 8.1 en ninguna versión publicada.** Su `gemspec` solo exige `railties >= 6.1`, así que *puede* instalar y hasta funcionar, pero sin soporte declarado.

### 2.2 Decisión propuesta

**Dos hitos independientes y desplegables:**

- **Hito A — Rails 8.0.5.1** → objetivo de producción. Todo el ecosistema (ActiveAdmin, Devise, Ransack, PaperTrail, Paranoia, Formtastic, Grape, state_machines) tiene soporte declarado.
- **Hito B — Rails 8.1.3.1** → se aborda después, condicionado a un *spike* de validación de ActiveAdmin bajo 8.1. Si ActiveAdmin falla, se mantiene A en producción y B queda en rama hasta que AA 4.0 estable publique soporte 8.1.

Esto respeta la regla oficial de avance incremental y evita quedar bloqueado en una rama larga sin poder desplegar.

> **Resultado: el riesgo no se materializó.** El spike midió ActiveAdmin 3.4.0 bajo
> Rails 8.1.3.1: **28 recursos y 284 rutas `/admin` cargadas**, y `spec/admin` completo
> en **1.686 ejemplos con 1 fallo**, que resultó ser contaminación entre tests por
> orden aleatorio (en aislado: 159 ejemplos, 0 fallos).
>
> Se ejecutaron **ambos hitos** en la misma sesión: 8.0.5.1 primero, con la suite en
> verde, y después 8.1.3.1. Ninguno quedó condicionado.

### 2.3 Lo que este plan **NO** incluye (Rails 8 lo ofrece, pero es opcional)

Rails 8 cambia *defaults de generador*, no obliga a migrar. Se recomienda **no** mezclar esto con el upgrade:

- Propshaft en lugar de Sprockets → proyecto aparte (hay `sass-rails`/`coffee-rails`/`bootstrap-sass` acoplados)
- Solid Queue / Solid Cache / Solid Cable en lugar de Sidekiq+Redis → no hay motivo, Sidekiq 8 funciona
- Kamal 2 / Thruster en lugar de Capistrano+Docker → decisión de infraestructura, no de framework
- Generador de autenticación nativo en lugar de Devise → no aplica

---

## 3. Fase 0 — Prerequisitos (bloqueante)

> Sin esto, el upgrade se hace a ciegas.

### 0.1 Rama y línea base
```bash
git checkout -b rails-8-upgrade
git tag pre-rails8-baseline           # punto de retorno
```

### 0.2 Poner la suite en verde
```bash
bundle exec rspec 2>&1 | tail -40     # medir el baseline real hoy
```
Decidir explícitamente sobre los 240 request specs rojos:
- **Opción recomendada:** arreglar los errores 500 (son bugs reales según `REQUEST_SPEC_ANALYSIS.md`) y marcar como `pending` los tests frágiles de HTML, moviéndolos a `spec/requests_brittle/` (el directorio ya existe).
- **Inaceptable:** empezar el upgrade con fallos rojos indistinguibles de los que introduzca el upgrade.

Criterio de salida: `bundle exec rspec` → 0 failures.

### 0.3 Activar CI automático
Editar `.github/workflows/ci.yml`: descomentar `push`/`pull_request`. Durante la transición, matriz de dos entradas (`rails-7.2` y `rails-8.0`) vía `BUNDLE_GEMFILE`.

### 0.4 Alinear Ruby en los tres sitios
- `Gemfile`: `ruby '3.4.4'` (fijar, no `>=`)
- `Dockerfile`: `FROM ruby:3.3.6-alpine` → `ruby:3.4.4-alpine` (y el comentario de cabecera)
- CI: ya está en 3.4.4 ✅

### 0.5 Auditoría previa
```bash
bundle exec bundler-audit check --update
bundle exec brakeman -q
bundle outdated --strict | tee /tmp/outdated-pre-upgrade.txt
```

### 0.6 Higiene del repositorio (opcional pero recomendado)
Eliminar del control de versiones: `Gemfile.rails50`, `coverage_report.json` (15 MB), `results.xml` (2,3 MB), scripts sueltos (`fix_semantic_form_with.sh`, `find_coverage.rb`, `create_remaining_specs.sh`…) y consolidar los ~40 `.md` de informes en `docs/`. Reduce el ruido de los diffs de `app:update`.

---

## 4. Fase 1 — Preparación dentro de Rails 7.2 (sin cambiar de versión)

**Principio de la guía oficial:** exprimir los avisos de deprecación de la versión actual antes de saltar.

### 1.1 Convertir deprecaciones en errores
En `config/environments/test.rb`:
```ruby
config.active_support.deprecation = :raise   # hoy es :stderr
```
Ejecutar la suite completa y corregir **todo** lo que salte. Este paso hace aflorar deprecaciones tanto de Rails como de las gems.

### 1.2 Cambios pre-aplicables ya en 7.2

| Cambio | Ficheros | Motivo |
|---|---|---|
| `ActiveSupport.to_time_preserves_timezone = true` → `config.active_support.to_time_preserves_timezone = :zone` | `config/initializers/new_framework_defaults.rb` | La forma booleana se elimina en 8.1 |
| Eliminar `Rails.application.config.active_job.enqueue_after_transaction_commit = :default` | `config/initializers/new_framework_defaults_7_2.rb` | **Eliminado** en Rails 8.1 |
| `mb_chars.upcase.to_s` → `upcase` | `app/models/collaboration.rb:452-458`, `engines/plebis_collaborations/.../collaboration.rb:546-552` | `String#upcase` es Unicode-aware desde Ruby 2.4; `mb_chars` se deprecia en 8.1 |
| Revisar `redirect_to` con rutas relativas sin `/` inicial | `grep -rn "redirect_to ['\"]" app/ engines/` | 8.1 puede lanzar `UnsafeRedirectError` |
| Revisar `.first` / `.last` / `.second` sin `order` explícito | modelos y scopes | 8.1 deprecia el finder dependiente de orden |

### 1.3 Actualizar gems **dentro** de 7.2 (reduce variables antes del salto)

Compatibles y actualizables ya:

| Gem | Actual | Objetivo | Nota |
|---|---|---|---|
| `activeadmin` | 3.4.0 | **3.5.2** | soporte Rails 8.0 declarado |
| `paper_trail` | 15.2.0 | **17.0.0** | `activerecord >= 7.1`; revisar CHANGELOG 16→17 |
| `sidekiq` | 7.3.9 | **8.1.6** | Sidekiq 8 aporta su propio adaptador ActiveJob (el built-in se deprecia en Rails 8.1) |
| `sidekiq-unique-jobs` | 8.0.x | **8.1.0** | acompaña a Sidekiq 8 |
| `aws-sdk-rails` | 3.13.0 | **5.2.0** | ⚠️ **breaking**: la v4 dividió la gema en `aws-actionmailer-ses`, `aws-activejob-sqs`, `aws-record-rails`. Revisar `config/initializers/amazon_ses.rb` |
| `formtastic` | 5.0.0 | **6.0.0** | `actionpack >= 7.2` |
| `friendly_id` | 5.5.1 | **5.7.0** | |
| `state_machines-activerecord` | 0.100.0 | **0.200.0** | `activerecord >= 7.2` |
| `sqlite3` | 1.7.3 | **`~> 2.1`** | ⚠️ **Rails 8 exige `sqlite3 >= 2.1`** |
| `flag_shih_tzu` | — | **1.0.5** | mantenida (jul-2026) |
| `phonelib`, `ffi-icu`, `rqrcode`, `secure_headers`, `rack-attack`, `grape`, `vite_rails` | varias | últimas | sin breaking conocido |

**Actualización mayor a decidir aparte:**
- `devise` 4.9.4 → **5.0.4**. Es un salto mayor con cambios de comportamiento. Devise 4.9.4 declara `railties >= 4.1.0` y funciona con Rails 8.0. **Recomendación: no mezclarlo con el upgrade de Rails**; hacerlo como PR independiente antes o después.

**Ya compatibles, sin acción:**
`paranoia` 3.1.0 (`activerecord >= 7, < 8.2` → cubre 8.0 y 8.1 ✅), `ransack` 4.4.1, `cancancan` 3.6.1, `kaminari` 1.2.2, `sprockets-rails` 3.5.2, `pg` 1.6.2, `puma` 6.6.1, `unicorn` 6.1.0.

### 1.4 Desbloquear los engines
Los 9 gemspecs tienen `spec.add_dependency 'rails', '~> 7.2.3'`, que **impide** que Bundler resuelva Rails 8. Cambiar a un rango:
```ruby
spec.add_dependency 'rails', '>= 7.2.3', '< 9.0'
spec.required_ruby_version = '>= 3.3.6'   # o '>= 3.4' si se fija Ruby
```
Ficheros: `engines/plebis_{cms,collaborations,gamification,impulsa,microcredit,participation,proposals,verification,votes}/*.gemspec`

**Criterio de salida de la Fase 1:** suite en verde, `deprecation = :raise`, cero deprecaciones, gems actualizadas, engines desbloqueados — todo aún sobre Rails 7.2.

---

## 5. Fase 1b — Decisión sobre gems abandonadas

Estas gems no han tenido *release* en años. No bloquean necesariamente, pero son el riesgo latente de todo el upgrade:

| Gem | Último release | Riesgo | Acción propuesta |
|---|---|---|---|
| `rack-openid` | 2014 | 🔴 alto — diseñado para Rack 1; el proyecto ya usa Rack 3.2 | Verificar si `open_id_controller.rb` sigue activo (SimpleCov lo excluye: *"conditionally enabled via secrets.openid, disabled in test"*). Si está muerto → **eliminar** junto a `ruby-openid` |
| `pushmeup` | 2014 | 🔴 alto | Verificar uso real; sustituir o eliminar |
| `rubypress` | 2017 | 🟠 | XML-RPC a WordPress; verificar uso |
| `jquery-fileupload-rails` | 2018 | 🟠 | reemplazable por el pipeline Vite |
| `formtastic-bootstrap` | 2015 | 🟠 | acoplado a Formtastic 6 → verificar en el spike |
| `carmen-rails` | 2014 | 🟠 | `rails >= 0`; usado por VoteCircle |
| `active_skin` | 2020 | 🟡 | tema de ActiveAdmin; posible incompatibilidad con AA 3.5/4 |
| `cocoon` | 2020 | 🟡 | |
| `rake-progressbar` | 2012 | 🟡 | trivialmente reemplazable |
| `bootstrap-sass` 3.4.1 | 2019 | 🟡 | Bootstrap 3 es EOL |
| `simple_captcha2` | 2019 | 🟡 | |
| `auto_html` | 2025 ✅ | 🟢 | mantenida |
| `norma43` | fork git de podemos-info | 🟠 | dependencia de un fork sin versionar |

**Entregable de esta fase:** una tabla de decisión *mantener / sustituir / eliminar* firmada, antes de tocar Rails.

---

## 6. Fase 2 — Rails 7.2 → 8.0 (procedimiento oficial)

### Paso 1 — Subir la versión
```ruby
# Gemfile
gem 'rails', '~> 8.0.5'
gem 'sqlite3', '~> 2.1'
```
```bash
bundle update rails
```

### Paso 2 — `bin/rails app:update`
```bash
bin/rails app:update
```
Revisar **fichero por fichero** con `git diff`. Prestar atención a:
- `bin/*` (nuevos `bin/setup`, `bin/dev`; Rails 8 añade la carpeta `script/`)
- `config/environments/{development,production,test}.rb` — **conservar** los ajustes propios (`config.hosts`, `force_ssl`, logger a STDOUT, mailer hosts)
- `config/environments/staging.rb` — **no lo toca `app:update`**, replicar los cambios a mano
- **No aceptar** la sobreescritura de `config/application.rb` (contiene el parche de `secrets` y el `require` selectivo de frameworks)
- Rails 8 propondrá `Dockerfile`/`.kamal` — **rechazar**, ya existe infraestructura propia

### Paso 3 — Mantener defaults antiguos y añadir el fichero de transición
- `config/application.rb`: **dejar `config.load_defaults 7.2`** por ahora
- Crear `config/initializers/new_framework_defaults_8_0.rb` con las 3 opciones comentadas:
  ```ruby
  # Rails.application.config.active_support.to_time_preserves_timezone = :zone
  # Rails.application.config.action_dispatch.strict_freshness = true
  # Regexp.timeout = 1
  ```

### Paso 4 — Verificar antes de tocar defaults
```bash
bundle exec rspec
RAILS_ENV=development bundle exec ruby -e 'require "./config/environment"; puts Rails.version'
bin/rails zeitwerk:check
bin/rails db:migrate:status
```
**Verificación específica de este proyecto:** que `config.secrets = config_for(:secrets)` y el método `secrets` sigan funcionando (dependen del `method_missing` de `Rails::Railtie::Configuration`). Test rápido:
```bash
bin/rails runner 'puts Rails.application.secrets.microcredits["default_brand"]'
```

### Paso 5 — Activar los defaults 8.0 **uno a uno**, con la suite entre medias

1. `to_time_preserves_timezone = :zone` — impacto en fechas de colaboraciones, órdenes y elecciones. Revisar `spec/models/order_spec.rb`, `collaboration_spec.rb`.
2. `action_dispatch.strict_freshness = true` — solo afecta a respuestas con `If-Modified-Since` + `If-None-Match` simultáneos.
3. **`Regexp.timeout = 1`** ⚠️ **el de mayor riesgo real en este código**. Revisar regexes sobre entradas grandes: parser Norma43 (extractos bancarios), validadores de NIF/NIE/IBAN, `auto_html`, importadores CSV. Si algo se pasa de 1 s, lanzará `Regexp::TimeoutError` en producción. Mitigación: medir con `bundle exec ruby -e` sobre ficheros reales antes de activarlo, o subir el valor (`Regexp.timeout = 5`).

### Paso 6 — Consolidar
```ruby
config.load_defaults 8.0
```
Y **eliminar** `config/initializers/new_framework_defaults_7_2.rb` y `new_framework_defaults_8_0.rb`. Revisar también `new_framework_defaults.rb` (fichero heredado de Rails 5): salvo `belongs_to_required_by_default = false`, el resto ya son defaults y puede borrarse.

### Paso 7 — Alinear engines
Cada engine: `bundle exec rspec` desde su directorio; ajustar `spec/dummy` si existe.

### Paso 8 — Removals de Rails 8.0 a verificar
Ya comprobado que ninguno aparece en el código propio (§1.5). Volver a ejecutar el grep tras `bundle update`, por si alguna gem los usa:
```bash
grep -rn "ProxyObject\|read_encrypted_secrets\|ConsoleMethods\|use_big_decimal_serializer\|commit_transaction_on_non_local_return\|allow_deprecated_singular_associations_name\|warn_on_records_fetched_greater_than" app/ lib/ config/ engines/
```
Deprecaciones 8.0 a atender: `bin/rake stats` → `bin/rails stats`; opción `retries` del adaptador SQLite3.

**Criterio de salida:** `config.load_defaults 8.0`, suite en verde, arranque correcto en `development`, `test` y `production` (`RAILS_ENV=production bin/rails runner 'puts 1'`), Brakeman sin regresiones. → **Desplegable a staging.**

---

## 7. Fase 3 — Rails 8.0 → 8.1

### 3.0 Spike previo obligatorio (timebox 4 h)
Antes de comprometerse: rama desechable con `gem 'rails', '~> 8.1.3'`, `bundle update rails` y ejecutar `bundle exec rspec spec/admin`. **Si ActiveAdmin 3.5.2 no funciona bajo Rails 8.1** (no está en su matriz de CI), congelar el Hito B y mantener 8.0 en producción hasta que ActiveAdmin publique soporte.

### 3.1 Procedimiento
Idéntico al de la Fase 2: `gem 'rails', '~> 8.1.3'` → `bundle update rails` → `bin/rails app:update` → mantener `load_defaults 8.0` → añadir `new_framework_defaults_8_1.rb`.

### 3.2 Removals de 8.1 que **sí** afectan a este proyecto

| Removal / deprecación | Acción concreta |
|---|---|
| `active_job.enqueue_after_transaction_commit` **eliminado** | Borrar la línea de `new_framework_defaults_7_2.rb` (ya hecho en Fase 1) |
| `to_time` preservando hora local del sistema **eliminado** | Ya migrado a `:zone` en Fase 1 |
| `Benchmark.ms` **eliminado** | `grep -rn "Benchmark.ms"` |
| Suma `Time` + `ActiveSupport::TimeWithZone` **eliminada** | Revisar aritmética de fechas en `order.rb`, `microcredit.rb`, `election.rb` |
| `String#mb_chars` deprecado | Ya migrado en Fase 1 |
| Adaptador Sidekiq built-in deprecado | Lo aporta la gem `sidekiq` 8 (ya actualizada en Fase 1); revisar `config/initializers/sidekiq.rb` |
| Punto y coma como separador de query string **eliminado** | Revisar rutas de callback externas (Redsys, Agora) |
| `ActiveRecord::Base.signed_id_verifier_secret` deprecado | `grep`; usar `Rails.application.message_verifiers` |
| Storage `:azure` **eliminado** | No usado ✅ |
| **`schema.rb` con columnas ordenadas alfabéticamente** | Regenerar el esquema en un commit aislado (`bin/rails db:migrate` sobre BD limpia); solo cambia formato, no datos |

### 3.3 Defaults 8.1 a activar uno a uno

| Default | Riesgo |
|---|---|
| `action_controller.escape_json_responses = false` | Bajo — verificar la API Grape y los endpoints JSON de Vue |
| `active_support.escape_js_separators_in_json = false` | Bajo |
| `active_record.raise_on_missing_required_finder_order_columns = true` | **Medio-alto** — cualquier `.first`/`.last` sin `order` sobre modelos sin `primary_key` claro lanzará excepción. Activar el último y ejecutar la suite entera |
| `action_controller.action_on_path_relative_redirect = :raise` | **Medio** — auditar todos los `redirect_to` con string |
| `action_view.render_tracker = :ruby` | Bajo |
| `action_view.remove_hidden_field_autocomplete = true` | Bajo — puede romper asserts de HTML en request specs |

### 3.4 Consolidar
`config.load_defaults 8.1`, eliminar `new_framework_defaults_8_1.rb`.

---

## 8. Fase 4 — Limpieza de parches de compatibilidad

Con Rails 8 estable, reevaluar los workarounds acumulados (cada uno, un PR independiente):

1. **`action_text/engine`** — reactivar el `require` y verificar si el `FrozenError` de 7.2 persiste.
2. **`config.add_autoload_paths_to_load_path = true`** e `config/initializers/unfreezeautoload_paths.rb` — intentar eliminarlos; `bin/rails zeitwerk:check` como validación.
3. **`config/initializers/ruby_3_file_exists_patch.rb`** — probablemente innecesario con las gems actualizadas.
4. **Migración de `Rails.application.secrets`** (254 usos) — trabajo mayor, planificar aparte. Ruta recomendada: introducir un objeto `Settings` respaldado por `config_for` + credentials cifradas, y migrar por módulos. **No hacerlo durante el upgrade de Rails.**
5. **Duplicación `app/` ↔ `engines/`** — decidir cuál es la fuente de verdad por modelo y eliminar la copia.

---

## 9. Fase 5 — Infraestructura y despliegue

- `Dockerfile`: Ruby 3.4.4, actualizar comentario de cabecera (dice "Rails 7.2")
- `docker-compose.yml` / `docker-compose.dev.yml`: revisar versiones de servicios
- CI: PostgreSQL 14 → considerar 16/17 (Rails 8 optimiza para versiones recientes); quitar `RUBYOPT: "-W0"` si es posible tras actualizar gems (hoy oculta avisos que interesan durante un upgrade)
- **Decidir Puma o Unicorn** — mantener ambos duplica la superficie de riesgo con Rack 3. Recomendación: Puma
- Capistrano 3.10 → 3.19
- Despliegue: **staging primero**, con al menos una semana de observación antes de producción
- `config/newrelic.yml` / Airbrake: verificar compatibilidad de los agentes con Rails 8

---

## 10. Fase 6 — Verificación final

### Automática
```bash
bundle exec rspec                       # 0 failures
bundle exec rubocop                     # con TargetRailsVersion: 8.1 en .rubocop.yml
bundle exec brakeman -q
bundle exec bundler-audit check --update
bin/rails zeitwerk:check
RAILS_ENV=production bin/rails runner 'puts Rails.version'
```

### Manual (flujos críticos, en staging)
1. Registro y login (Devise) + recuperación de contraseña
2. Panel ActiveAdmin: listados, filtros Ransack, exportación CSV, formularios Formtastic
3. Colaboraciones y órdenes → pasarela Redsys, generación de remesas Norma43
4. Microcréditos: alta de préstamo, PDF (WickedPDF), notificaciones
5. Votaciones: integración Agora, firma de URLs, generación de QR
6. Verificación de usuario: subida de documentos (ActiveStorage), variantes de imagen
7. Impulsa: wizard de proyectos, adjuntos
8. CMS: páginas, blog (`auto_html`), notices
9. Envío de emails (SES) y SMS (Esendex)
10. Jobs de Sidekiq y su panel

---

## 11. Riesgos priorizados — resultado real

**8 de los 10 riesgos previstos no se materializaron.** El plan sobreestimó el riesgo de
migrar de versión y subestimó el del código que nadie ejecutaba.

| # | Riesgo previsto | Resultado |
|---|---|---|
| 1 | ActiveAdmin sin soporte para 8.1 | ✅ **No se materializó.** 1.686 ejemplos de `spec/admin`, 0 fallos reales |
| 2 | 240 request specs en rojo | ❌ **Era falso.** La suite estaba verde: 10.522 / 0 |
| 3 | El parche de `secrets` se rompe en 8.x | ✅ **Sobrevive.** Pero escondía un bug peor: §0.1 del registro |
| 4 | `Regexp.timeout = 1` rompe Norma43 | ✅ **No se materializó.** La regex más lenta: 8 ms sobre 200 KB |
| 5 | Gems abandonadas | ⏭️ **No tocadas.** Solo `cocoon` está sin uso; el resto es funcionalidad viva |
| 6 | `aws-sdk-rails` v3→v5 | ⏭️ **Innecesario.** La v3.13 no tiene tope de railties |
| 7 | Duplicación app/engines | ⚠️ **Confirmado, y es el mayor problema estructural que queda** |
| 8 | Sprockets legacy | ✅ **Sin incidencias.** Sigue soportado |
| 9 | `raise_on_missing_required_finder_order_columns` | ✅ **Sin superficie.** 7 finders, todos con PK estándar |
| 10 | Devise 4.9 → 5.0 | ⏭️ **Fuera de alcance.** Únicas 2 vulnerabilidades que quedan |

### Riesgos que el plan NO previó y sí aparecieron

| Riesgo | Impacto real |
|---|---|
| **El eager loading llevaba roto desde 7.2** | Producción (`eager_load = true`) no arrancaba limpiamente |
| **Secrets anidados devolviendo `nil`** en 254 usos | Funcionalidad degradada en producción sin que nadie lo relacionara |
| **`root_url` en engines montados** | 500 en vez de redirección para usuarios sin permisos |
| **Suites de engines fuera de CI** | 447 fallos acumulados, 2.188 ejemplos sin cobertura |
| **`minitest-rails ~> 7.1`** con tope `railties < 8.0` | Bloqueaba la resolución; no estaba en el análisis de gems |
| **Tres fuentes de intermitencia** en la suite | Habrían hecho fallar CI de forma aleatoria |

---

## 12. Secuencia de entrega — commits reales

Los 17 PRs previstos se condensaron en 11 commits en `rails-8-upgrade`, cada uno
revertible por separado:

| Commit | Contenido |
|---|---|
| `07e7b2f2` | Plan de upgrade y specs pendientes |
| `4be2b038` | Fase 0: Ruby alineado, CI automático, escape hatch de cobertura |
| `18ea07cf` | Fase 1: retirada de APIs deprecadas (`mb_chars`, `to_time`) |
| `e6edacb8` | **Rails 7.2.3 → 8.0.5.1** + `app:update` + arreglo del eager loading |
| `a3203a8f` | `config.load_defaults 8.0` |
| `2159cc2e` | **Rails 8.0.5.1 → 8.1.3.1** + `load_defaults 8.1` |
| `7a2c5218` | Seguridad de dependencias y verificación estática |
| `21d3e95f` | Regeneración de `schema.rb` con el formato de 8.1 |
| `c5cf3e90` | Acceso indiferente en secrets + arnés de test de los engines |
| `0d8b4bde` | `root_url` en engines montados + más reparaciones de engines |
| `2e65377f` | **Ruby 3.4.4 → 3.4.10** + corrección de 15 regresiones propias |
| *(último)* | Mapping de Devise autorreparable en specs de controlador |

**No se ejecutó ningún despliegue** (PRs 12 y 16 del plan original). Requiere decisión
humana: staging primero, con la verificación manual de §10.

### Verificación final

```
Ruby 3.4.10 / Rails 8.1.3.1
suite raíz     10.522 ejemplos, 0 fallos, 666 pending
engines         2.188 ejemplos, 228 fallos preexistentes (eran 447)
zeitwerk:check  All is good
brakeman        0 avisos
bundler-audit   2 hallazgos (solo Devise)
rubocop (CI)    0 ofensas
```

---

## 13. Plan de reversión

- Tag `pre-rails8-baseline` antes de empezar
- Cada hito es un merge a `master` independiente y revertible
- Despliegue Capistrano: `cap production deploy:rollback`
- **Sin migraciones destructivas en este upgrade** — el único cambio de esquema es el reformateo alfabético de `schema.rb` en 8.1, que no altera datos

---

## 14. Referencias oficiales

- Guía de actualización: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html
- Release notes 8.0: https://guides.rubyonrails.org/8_0_release_notes.html
- Release notes 8.1: https://guides.rubyonrails.org/8_1_release_notes.html
- `new_framework_defaults_8_0.rb`: https://github.com/rails/rails/blob/v8.0.5.1/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_8_0.rb.tt
- `new_framework_defaults_8_1.rb`: https://github.com/rails/rails/blob/v8.1.3.1/railties/lib/rails/generators/rails/app/templates/config/initializers/new_framework_defaults_8_1.rb.tt
