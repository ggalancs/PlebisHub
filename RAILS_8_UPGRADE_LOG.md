# Registro de ejecución — Upgrade a Rails 8

Complemento de [RAILS_8_UPGRADE_PLAN.md](RAILS_8_UPGRADE_PLAN.md). Aquí queda lo que
se ejecutó realmente, incluidas las **desviaciones del plan** y las **hipótesis del
plan que resultaron falsas al medirlas**.

**Rama:** `rails-8-upgrade` · **Punto de retorno:** tag `pre-rails8-baseline` (commit `74ead484`)

---

## 0. Tres bugs de producción destapados por el upgrade

Ninguno lo causó el cambio de versión: los tres llevaban tiempo ahí y salieron al
ejecutar por primera vez código y tests que nadie ejecutaba.

### 0.1 Los secrets anidados devolvían `nil`

`config_for(:secrets)` symboliza las claves, pero la aplicación los lee con claves
string en sus 254 usos:

```ruby
Rails.application.secrets.agora['servers']       # => nil
Rails.application.secrets.forms['domain']        # => nil
Rails.application.secrets.microcredits['brands'] # => nil
```

Solo funcionaba donde algún parche inyectaba claves string por efecto colateral:
`secrets.agora` tenía `:themes` y `"themes"` **duplicadas** porque
`config/initializers/test_agora_themes.rb` hace `agora["themes"] ||= …` sobre un hash
con claves símbolo y nunca las encontraba.

Corregido dando acceso indiferente a los hashes anidados en `config/application.rb`.

> **Conviene revisar qué funcionalidad llevaba degradada por esto**: integración con
> Ágora, formularios embebidos y configuración de marcas de microcréditos.

### 0.2 `root_url` reventaba en los engines montados

`ApplicationController` usaba `root_url` en sus tres redirects de acceso denegado
(`rescue_from CanCan::AccessDenied`, `access_denied` y `authenticate_admin_user!`). Los
8 engines montados heredan de esa clase y, en un controlador de engine, los url helpers
se resuelven contra el route set del propio engine, que no define `root`.

Resultado: en lugar de redirigir, esos redirects lanzaban
`ActionController::UrlGenerationError`. **Un usuario sin permisos en una acción
protegida de un engine recibía un 500.** Corregido con `main_app.root_url`.

### 0.3 Códigos de credencial malformados

Ver §8.

---

## 1. Resultados de la suite

Todas las ejecuciones son de la suite raíz completa (`bundle exec rspec`), en la misma
máquina y con la misma base de datos.

| # | Configuración | Ejemplos | Fallos | Pending |
|---|---|---:|---:|---:|
| 1 | Rails 7.2.3 — **línea base** | 10.522 | **0** | 666 |
| 2 | Rails 8.0.5.1, `load_defaults 7.2` | 10.522 | **0** | 666 |
| 3 | Rails 8.0.5.1, `load_defaults 8.0` | 10.522 | **0** | 666 |
| 4 | Rails 8.1.3.1, `load_defaults 8.0` | 10.522 | 1 † | 666 |
| 5 | Rails 8.1.3.1, `load_defaults 8.1` | 10.522 | **0** | 666 |
| 6 | Rails 8.1.3.1 + 15 bumps de seguridad | 10.522 | 1 † | 666 |

† En ambos casos, el mismo bug preexistente del código de producción (§8), en dos specs
distintos y con seeds distintos. No es una regresión de Rails 8.

**Suites de los 9 engines** (64 spec files que no forman parte de la suite raíz ni de CI),
comparadas siempre contra una base de datos recién cargada:

| Configuración | Ejemplos | Fallos |
|---|---:|---:|
| Rails 7.2.3 | 2.163 | 461 |
| Rails 8.1.3.1 | 2.187 | **447** |

Regresiones reales del upgrade: **0**. Fallos que el upgrade resuelve: **16**.

### Verificación estática

| Comprobación | Antes (7.2) | Después (8.1) |
|---|---|---|
| `bin/rails zeitwerk:check` | ❌ falla | ✅ *All is good* |
| `bundler-audit` | ~90 hallazgos | **2** (solo Devise) |
| `brakeman` | 1 aviso + 1 entrada obsoleta | ✅ sin avisos |
| `rubocop` (config de CI) | 0 ofensas | ✅ 0 ofensas |

Cobertura en la línea base: 86,64 % (10.421 / 12.028 líneas).

---

## 2. Hipótesis del plan que resultaron falsas

### 2.1 «La suite tiene 240 fallos y hay que arreglarlos antes de empezar» — FALSO

`TEST_SUITE_STATUS.md` (3-dic-2025) documentaba 240 fallos en request specs y el plan lo
tomó como prerequisito bloqueante. Al ejecutar la suite el 16-ago-2026 el resultado fue
**10.522 ejemplos, 0 fallos**. El documento estaba obsoleto. La Fase 0 bloqueante ya
estaba cumplida.

**Lección:** medir antes de planificar sobre documentación interna con fecha.

### 2.2 «ActiveAdmin es el gran riesgo para Rails 8.1» — MITIGADO

El plan lo situaba como riesgo #1 porque ni ActiveAdmin 3.5.2 ni 4.0.0.beta22 tienen
`gemfiles/rails_81` en su matriz de CI. Medido en un worktree aislado:

- Rails 8.1.3.1 arranca y ActiveAdmin 3.4.0 carga **28 recursos y 284 rutas `/admin`**.
- `spec/admin` completo bajo 8.1: **1.686 ejemplos, 1 fallo**.
- Ese único fallo (`spec/admin/user_spec.rb:120`) resultó ser contaminación entre tests
  por orden aleatorio: en aislado con `--seed 1` da **159 ejemplos, 0 fallos**.

### 2.3 «`Regexp.timeout = 1` puede romper el parser Norma43 y los validadores» — FALSO

Las 5 regex reales del código, medidas contra entradas adversas de 200 KB:

| Regex | Tiempo |
|---|---:|
| `order.rb:411` scan de comentarios HTML | 0,0000 s |
| `municipies_extract` gsub | 0,0006 s |
| `cmd_get_data` scan de argumentos | 0,0079 s |
| `engine_generator` validación de nombre | 0,0033 s |
| `vote_circle` código | 0,0000 s |

Tres órdenes de magnitud por debajo del límite.

### 2.4 «`strict_freshness` hay que revisarlo» — SIN SUPERFICIE

Cero usos de `fresh_when`, `stale?`, `etag` o `last_modified` en toda la aplicación.

### 2.5 «`raise_on_missing_required_finder_order_columns` es riesgo medio-alto» — BAJO

Solo 7 finders `.first`/`.last` sobre relaciones, todos en modelos con clave primaria
`id` estándar, así que Active Record tiene columna de orden a la que recurrir.

### 2.6 «`action_on_path_relative_redirect = :raise` es riesgo medio» — SIN SUPERFICIE

Cero ocurrencias de `redirect_to "cadena"` en `app/` y `engines/`.

### 2.7 «El parche de `Rails.application.secrets` es frágil y puede romperse» — SOBREVIVE

Verificado en 8.0 y en 8.1: devuelve `ActiveSupport::OrderedOptions` con las claves
resueltas y `secret_key_base` presente. Sigue siendo deuda técnica (254 usos), pero no
bloquea el upgrade.

---

## 3. Desviaciones del plan

| Plan | Ejecutado | Motivo |
|---|---|---|
| PR #6: migrar `aws-sdk-rails` a v5 | **No hecho.** Se queda en 3.13.0 | Declara `railties >= 5.2.0` sin tope superior, así que funciona con Rails 8. La v4 partió la gema en tres (`aws-actionmailer-ses`, `aws-activejob-sqs`, `aws-record-rails`): es una migración breaking independiente, no un requisito del upgrade |
| Fase 1b: eliminar gems abandonadas | **No hecho.** Documentado | De la lista solo `cocoon` está sin uso. `rack-openid`, `pushmeup`, `rubypress`, `espeak-ruby` y `jquery-fileupload-rails` se usan en código vivo: retirarlas es quitar funcionalidad, que es decisión de producto, no del upgrade |
| Defaults 8.0 «uno a uno, con la suite entre medias» | **Activados juntos** en una sola pasada | Cada uno se derriesgó individualmente con medidas (§2.3–2.5) antes de activarlos. Tres pasadas de suite habrían costado 2 h sin información adicional |
| Actualizar `activeadmin`, `sidekiq`, `formtastic`, `friendly_id`, `state_machines-activerecord` antes del salto | **No hecho.** Solo se subió lo que bloqueaba | Ninguna bloqueaba la resolución ni fallaba en runtime. Actualizarlas es higiene deseable, pero mezclarla con el upgrade habría añadido variables a un cambio que salió limpio |

### 3.1 Bloqueo no previsto en el plan

**`minitest-rails ~> 7.1`** tenía tope `railties < 8.0` e impedía que Bundler resolviera
Rails 8. No estaba en el análisis de gems. Subido a `~> 8.0` y luego `~> 8.1`.

**`paper_trail` 15.2** avisa explícitamente al arrancar de que no es compatible con
ActiveRecord 8.0. Estaba previsto subirlo; se confirmó que es obligatorio, no opcional.

---

## 4. Hallazgo mayor: el eager loading estaba roto desde antes

`bin/rails zeitwerk:check` fallaba **igual en Rails 7.2** (verificado en un worktree sobre
el tag `pre-rails8-baseline`). Como `config.eager_load = true` en producción, esto
significa que **producción no podía arrancar limpiamente**. No lo causó el upgrade; lo
destapó.

Siete capas, todas resueltas en `config/application.rb`:

1. `lib/add_unique_month_to_dates.rb` — reabre `Date`/`Time`/`ActiveRecord`, no define
   constante. Se carga desde `config/initializers/date_extensions.rb` → excluido de
   `autoload_lib`.
2. `lib/plebisbrand_export.rb` — define métodos sueltos, sin constante → excluido.
3. `lib/plebisbrand_import{,_collaborations,_collaborations2017}.rb` y `lib/sms.rb` —
   definen `PlebisBrandImport…` y `SMS`, que no coinciden con la constante que Zeitwerk
   infiere. Todos con carga explícita → excluidos.
4. `lib/paperclip/rotator.rb` — hereda de `Paperclip::Thumbnail`; la gema Paperclip ya no
   está instalada. Código muerto → excluido.
5. `lib/generators` — convención estándar de Rails → excluido.
6. `app/workers/plebisbrand_*_worker.rb` definen `PlebisBrand…` (B mayúscula). Se añadió
   una **inflexión de Zeitwerk acotada a esos tres ficheros**, en lugar de registrar un
   acrónimo global `PlebisBrand`, que también cambiaría `underscore` en toda la app y
   chocaría con el alias `PlebisBrand = Podemos` de
   `config/initializers/plebis_brand_alias.rb`.
7. `engines/*/app/admin` — los engines exponen `app/admin` como autoload path, pero son
   ficheros DSL de ActiveAdmin sin constantes. `Rails.autoloaders.main.ignore(...)`,
   igual que hace ActiveAdmin con el `app/admin` de la app principal.

Además, los concerns de `plebis_impulsa` vivían en `app/models/plebis_impulsa/concerns`
con una raíz de autoload extra y tres `require_relative` como parche. Movidos a
`app/models/concerns/plebis_impulsa/`, que Rails ya trata como raíz y que mapea
directamente a las constantes `PlebisImpulsa::…` que los ficheros definen. Parches
eliminados.

**Resultado:** `bin/rails zeitwerk:check` → *All is good!* en 8.0 y en 8.1.

---

## 5. Otro no-op detectado

`Rails.application.config.active_record.belongs_to_required_by_default = false` en
`config/initializers/new_framework_defaults.rb` **nunca se aplicó**. En 7.2 el valor
efectivo ya era `true` (verificado sobre el tag base): en esta aplicación ActiveRecord se
carga durante la inicialización, antes de que corran los `config/initializers`, así que el
railtie ya había capturado el valor de `load_defaults`.

Se retiró la línea en lugar de dejar documentada una desviación inexistente. El
comportamiento efectivo no cambia.

Mismo patrón con `ActiveSupport.to_time_preserves_timezone`: asignarlo desde un
initializer es un no-op. Se movió a `config/application.rb`, donde sí surte efecto.

---

## 6. Limpieza colateral

`:unprocessable_entity` → `:unprocessable_content`, deprecado en Rack 3.1 (la aplicación
ya corría sobre Rack 3.2). 3 ficheros de aplicación y 10 de spec. Rack 3.2 mapea el
símbolo nuevo a 422; el viejo ya no está en `SYMBOL_TO_STATUS_CODE` y pasa por un shim de
deprecación que ensuciaba la salida en cada request de test.

---

## 8. Bug destapado: códigos de credencial malformados

> **Decisión pendiente para el equipo.** Es el único punto no verde del upgrade y hará que
> CI falle de forma intermitente hasta que se resuelva.

Falló dos veces, en **specs distintos y con seeds distintos**:

- ejecución #4 — `spec/admin/credential_shipment_spec.rb:273`, `expected "H4GC-IU8" to match /^[A-Z0-9]{4}-[A-Z0-9]{4}$/i`
- ejecución #6 — `spec/requests/admin/credential_shipment_spec.rb:85`, código `73GD-L8M`

**No es una regresión de Rails 8.1.** En `app/admin/credential_shipment.rb:41` el código se
genera así:

```ruby
code = ([r.user_id].pack('L')[0..2] +
        Digest::CRC16.digest("#{r.user_id}-#{r.born_at}").ljust(8, "\x00")).unpack1('Q').to_s(32).upcase
code = "#{code[0..3]}-#{code[4..7]}"
```

`to_s(32)` **no rellena con ceros a la izquierda**, así que la cadena mide entre 6 y 8
caracteres según el valor. Cuando mide menos de 8, `code[4..7]` devuelve un fragmento corto
y sale un código tipo `H4GC-IU8`.

Comprobado con Ruby puro, sin Rails de por medio: de los `user_id` del 1 al 3000,
**324 (10,8 %) producen un código de 6 o 7 caracteres**.

```
id=104 code=1G00038 (7)   id=107 code=HI0003B (7)   id=114 code=BGG003I (7)
id=117 code=RIG003L (7)   id=124 code=SH0003S (7)   id=127 code=CJ0003V (7)
```

El test es correcto; el código de producción es el que está mal. Falla o no según qué
`user_id` haya acumulado la suite antes de llegar a ese ejemplo, lo que depende del orden
aleatorio de RSpec. El baseline de 7.2 pasó por suerte de seed, y en aislado no reproduce
(seeds 63577, 1 y 42: 40 ejemplos, 0 fallos).

**No se ha corregido, deliberadamente.** El arreglo es `rjust(8, '0')` antes de partir la
cadena, pero eso cambia los códigos de credencial que se envían por correo postal a
personas reales para el ~11 % de los casos. Es una decisión de producto, no del upgrade.
Debe abrirse como incidencia aparte.

---

## 7. Pendiente

### Decisiones que requieren al equipo

1. **Bug de los códigos de credencial (§8).** Único punto no verde. El arreglo es una
   línea; el impacto es de producto.
2. **`devise` 4.9.4 → 5.0.4.** Últimas 2 vulnerabilidades Medium que quedan en
   `bundler-audit`. Es un mayor con breaking changes.
3. **Despliegue.** **No ejecutado por diseño.** Staging primero, con verificación manual de
   los flujos críticos (§10 del plan): Devise, ActiveAdmin, Redsys, microcréditos, Ágora,
   ActiveStorage, SES/Esendex, Sidekiq.

### Recomendaciones

4. **Meter los engines en CI.** Hoy CI solo ejecuta `bundle exec rspec spec/`, dejando fuera
   2.187 ejemplos que llevan tiempo pudriéndose (447 en rojo). Da una falsa sensación de
   seguridad.
5. **Meter `zeitwerk:check` en CI.** Habría detectado años antes que producción no podía
   hacer eager loading.
6. **Higiene de gems aplazada**: `activeadmin` 3.4 → 3.5.2, `sidekiq` 7 → 8,
   `formtastic` 5 → 6, `friendly_id` 5.5 → 5.7, `state_machines-activerecord` 0.100 → 0.200,
   `aws-sdk-rails` 3 → 5. Ninguna bloqueaba; se dejaron fuera para no añadir variables.

### Deuda técnica destapada, fuera del alcance del upgrade

- `app/services/census_file_parser.rb:39` llama a `Paperclip.io_adapters`, pero la gema
  Paperclip no está instalada. Fallaría en runtime.
- 254 usos de `Rails.application.secrets` apoyados en un parche en `config/application.rb`.
- Duplicación `app/` ↔ `engines/`: cada corrección hay que aplicarla dos veces.
- `action_text/engine` y `rails/test_unit/railtie` siguen comentados en
  `config/application.rb` desde el upgrade a 7.2.
