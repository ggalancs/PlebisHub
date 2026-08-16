# Handoff — continuación del upgrade a Rails 8

Documento para retomar el trabajo en una conversación nueva.

---

## 0. INSTRUCCIÓN DE TRABAJO (leer primero)

**No respondas hasta haber agotado el trabajo posible.** Cada respuesta cierra el turno.
Encadena decenas de llamadas a herramientas por turno: mide, corrige, vuelve a medir,
commitea, y sigue con el siguiente fichero. Responde solo cuando termines un bloque
grande o cuando necesites de verdad una decisión humana.

**No ejecutes la suite completa** hasta que los ficheros que fallan estén a cero.
El bucle correcto tarda ~1:36 en vez de ~40 minutos:

```bash
cd /Users/gabriel/Development/2014/PlebisHub
D=/private/tmp/.../scratchpad/upgrade   # o regenera la lista con el comando de abajo
RUBYOPT=-W0 SKIP_COVERAGE_CHECK=1 RAILS_ENV=test DATABASE_NAME=plebis_eng \
  bundle exec rspec $(cat "$D/failing_files.txt" | tr '\n' ' ') \
  --format progress --format json --out "$D/run.json"
```

Base de datos de trabajo: `plebis_eng` (separada de `plebis_hub_test`). Si hay que
recrearla: `RAILS_ENV=test DATABASE_NAME=plebis_eng bundle exec rails db:create db:schema:load`.

> **Ojo con la contaminación de datos**: medir los engines contra una base sucia infla el
> recuento (447 → 604 en una medición intermedia). Comparar siempre con base limpia.

---

## 1. Estado actual

| | |
|---|---|
| Rama | `rails-8-upgrade` |
| Punto de retorno | tag `pre-rails8-baseline` (commit `74ead484`) |
| **Rails** | **8.1.3.1** con `config.load_defaults 8.1` ✅ |
| **Ruby** | **3.4.10** (3.5 solo existe como `preview1`) ✅ |
| Suite raíz | 10.522 ejemplos, 0 fallos |
| Suites de engines | **63 fallos** (empezaron en 447) |
| Duplicación app↔engines | **15 ficheros** (empezó en 34) |
| `zeitwerk:check` | All is good |
| `bundler-audit` | 2 hallazgos (solo Devise) |
| `brakeman` | 0 avisos |
| `rubocop` (config CI) | 0 ofensas |
| Despliegue | **NO ejecutado** |

27 commits, cada uno revertible por separado.

---

## 2. Lo que falta

### 2.1 Los 63 fallos de engines, por fichero

```
7  plebis_proposals/spec/controllers/plebis_proposals/proposals_controller_spec.rb
7  plebis_verification/spec/services/plebis_verification/town_verification_report_service_spec.rb
6  plebis_votes/spec/models/plebis_votes/vote_circle_spec.rb
6  plebis_cms/spec/controllers/plebis_cms/page_controller_spec.rb
5  plebis_impulsa/spec/models/plebis_impulsa/concerns/impulsa_project_evaluation_spec.rb
5  plebis_verification/spec/models/plebis_verification/user_verification_spec.rb
4  plebis_impulsa/spec/models/plebis_impulsa/concerns/impulsa_project_wizard_spec.rb
3  plebis_participation/spec/helpers/plebis_participation/participation_teams_helper_spec.rb
2  plebis_votes/spec/models/plebis_votes/election_location_spec.rb
2  plebis_cms/spec/controllers/plebis_cms/blog_controller_spec.rb
2  plebis_proposals/spec/controllers/plebis_proposals/supports_controller_spec.rb
2  plebis_proposals/spec/models/plebis_proposals/proposal_spec.rb
2  plebis_verification/spec/services/plebis_verification/user_verification_report_service_spec.rb
2  plebis_verification/spec/services/plebis_verification/exterior_verification_report_service_spec.rb
2  plebis_cms/spec/models/plebis_cms/category_spec.rb
1  plebis_proposals/spec/models/plebis_proposals/support_spec.rb
1  plebis_votes/spec/phase3_fixes_spec.rb
1  plebis_cms/spec/models/plebis_cms/notice_spec.rb
1  plebis_votes/spec/models/plebis_votes/election_location_question_spec.rb
1  plebis_gamification/spec/services/gamification/badge_awarder_spec.rb
1  plebis_collaborations/spec/services/plebis_collaborations/redsys_payment_processor_spec.rb
```

### 2.2 Consolidación pendiente (`bin/check_engine_duplication`)

Quedan **15 ficheros**, casi todos en `app/admin/`. Ojo: **para `app/admin/*` la copia viva
es la de la app** — ActiveAdmin solo carga `Rails.root/app/admin`, los `app/admin` de los
engines nunca se cargan. Consolidarlos exige además tocar `ActiveAdmin.application.load_paths`,
con riesgo de doble registro. Es un bloque aparte y más delicado.

### 2.3 Decisiones humanas pendientes

1. **Devise 4.9.4 → 5.0.4** — únicas 2 vulnerabilidades que quedan (Medium).
2. **Despliegue** — requiere saber el entorno destino y si hay credenciales en la máquina.
3. **Revisar impacto en producción del bug de secrets** (§3.1) — lo más urgente.

---

## 3. Los 14 bugs de PRODUCCIÓN encontrados

Ninguno lo causó el cambio de versión: el upgrade los destapó al obligar a ejecutar
código y tests que nadie ejecutaba.

1. **Secrets anidados devolvían `nil`** — `config_for` symboliza claves y el código las lee
   como strings en sus 254 usos: `secrets.agora['servers']`, `secrets.forms['domain']`,
   `secrets.microcredits['brands']`. **Revisar qué funcionalidad llevaba degradada.**
2. **Eager loading roto desde 7.2** — producción arranca con `eager_load = true` y
   `zeitwerk:check` fallaba. 7 capas corregidas.
3. **`root_url` en engines montados** — los 8 engines heredan `ApplicationController`; sus
   3 redirects de acceso denegado lanzaban `UrlGenerationError`: 500 en vez de redirección.
4. **Códigos de credencial malformados** — `to_s(32)` no rellena con ceros: 10,8 % de los
   `user_id` producían códigos de 6-7 caracteres en un fichero que se imprime y se envía
   por correo postal. **Corregido: cambia los códigos generados para ese ~11 %.**
5. **`sms_confirmation_attempts` no existe en `User`** — cualquier código SMS incorrecto
   lanzaba `NoMethodError` y el usuario veía un error genérico.
6. **`authenticated_root_path` sin `main_app`** — un código SMS **correcto** acababa en la
   pantalla de error.
7. **`edit_user_registration_path` / `create_vote_path` sin `main_app`** — una verificación
   enviada correctamente acababa en pantalla de error.
8. **Traducciones ausentes** `plebisbrand.errors.*` — el usuario veía literalmente
   `"Translation missing: es.plebisbrand.errors.generic_error"`.
9. **`available_frequencies_for_user`** hacía `FREQUENCIES.to_a.slice(...)`: `slice` y
   `except` son de Hash, sobre Array lanzaban `TypeError`/`NoMethodError`.
10. **`PARENT_CLASSES[parent.class]`** dejó de casar al heredar y reventaba la generación
    del identificador de pago de Redsys. Resuelto por ascendencia.
11. **`Gamification::ProposalListener`** resolvía el usuario con `proposal.author`, que es
    una **columna de texto** (nombre importado de Reddit), no una asociación: los eventos
    de propuesta aprobada, destacada e implementada **fallaban siempre**.
12. **4 validaciones de `MicrocreditLoan`** accedían a `microcredit` sin comprobar que
    existiera.
13. **`redsys_callback_response` lanzaba `FrozenError`** — `rstrip!` sobre un heredoc con
    `frozen_string_literal`: la respuesta al callback de Redsys **no se generaba nunca**.
14. **`redsys_expiration` lanzaba `TypeError`** si Redsys no devolvía `Ds_ExpiryDate`,
    tumbando el procesado del pago.

---

## 4. Decisión arquitectónica vigente

**Los engines son la fuente de la verdad. La app solo personaliza heredando, al estilo
Devise** (`class Collaboration < PlebisCollaborations::Collaboration`).

Verificado: ninguna de las 12 tablas implicadas tiene columna `type`, así que heredar
**no activa STI**.

Reglas:
1. App y engine equivalentes → borrar la copia de `app/`.
2. La app tiene lógica que el engine no → moverla al engine y borrar.
3. Lógica específica de esta instalación → subclase en `app/` solo con esa parte.
4. El engine está incompleto → **completar el engine primero**, nunca al revés.

`bin/check_engine_duplication` es la condición 9 de la puerta de despliegue.

---

## 5. Patrones que se repiten en los specs de engines

Casi ningún fallo era del código de test en sí: los specs se escribieron contra
comportamiento que **nunca se ejecutaba**.

- **Stub sobre la instancia equivocada**: `allow(user).to receive(...)` no aplica porque
  `current_user` es otra instancia cargada de la sesión. Usar `allow_any_instance_of(User)`
  o datos reales.
- **Expectativa acotada sin stub permisivo debajo**: con `expect(X).to receive(:m).with(...)`,
  cualquier otra llamada a `:m` falla. Hace falta `allow(X).to receive(:m)` antes.
  Afectó a `Rails.logger` (BroadcastLogger en Rails 8) y a `EventBus#subscribe`.
- **Desajuste de clase**: las consultas devuelven la clase del engine y las factories la de
  la app; `ActiveRecord#==` exige `instance_of?`. Comparar por `id`.
  Apuntar factories al engine funciona en `cms` y `verification`, **rompe** en
  `collaborations` (35→65) y en `votes` (no cargan). Aplicar solo donde mejora, midiendo.
- **Datos que no pasan validación**: teléfonos que no son móviles españoles,
  `terms_of_service: true` cuando la validación admite `[true, '1']`, adjuntos obligatorios
  ausentes, `payment_type: 3` sin IBAN válido.
- **Locale**: el arnés fija `I18n.locale = :es`; los mensajes de validación van en
  castellano y los redirects de la app llevan el prefijo `/es`.
- **`main_app.` en specs de engine**: incluir `url_helpers` no basta, porque `_routes`
  apunta al route set del engine.

---

## 6. Documentos relacionados

- `RAILS_8_UPGRADE_PLAN.md` — plan original, con las secciones desmentidas marcadas
- `RAILS_8_UPGRADE_LOG.md` — registro de ejecución, resultados y desviaciones
- `RAILS_8_REMAINING_WORK_PLAN.md` — las 9 condiciones que habilitan el despliegue
