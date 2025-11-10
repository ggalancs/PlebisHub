# Análisis de Tests Fallidos - PlebisHub

**Fecha:** 2025-11-10
**Test Suite:** Minitest
**Resumen:** 1183 tests, 2255 assertions, 33 failures, 144 errors, 26 skips

## Categorización de Errores

### Grupo 1: Mocha Gem No Configurada (~20 errors)
**Prioridad:** ALTA - Fácil de solucionar

**Problema:**
Tests usando `.stub` y `.expects` fallan con `NoMethodError: undefined method 'stub/expects'`

**Archivos Afectados:**
- `test/models/election_test.rb` (~13 tests)
- `test/models/report_group_test.rb` (~6 tests)
- `test/models/concerns/safe_condition_evaluator_test.rb` (~1 test)

**Solución:**
1. Agregar al `Gemfile` en grupo :test:
   ```ruby
   gem 'mocha', require: false
   ```
2. Agregar a `test/test_helper.rb`:
   ```ruby
   require 'mocha/minitest'
   ```
3. Ejecutar `bundle install`

---

### Grupo 2: SafeConditionEvaluator No Implementado (31 errors)
**Prioridad:** MEDIA - Requiere implementación

**Problema:**
El módulo `SafeConditionEvaluator` existe pero los métodos principales no están implementados:
- `evaluate` - Método principal para evaluar condiciones
- `tokenize` - Método para tokenizar expresiones
- `validate_tokens!` - Método para validar tokens de seguridad

**Archivos Afectados:**
- `test/models/concerns/safe_condition_evaluator_test.rb` (31 tests)

**Ubicación del Código:**
- `app/models/concerns/safe_condition_evaluator.rb` (probablemente vacío o stub)

**Solución:**
1. Revisar el archivo del concern
2. Implementar los métodos faltantes según la especificación en los tests
3. El concern debe evaluar condiciones booleanas de forma segura (sin eval)
4. Debe soportar operadores: &&, ||, !, paréntesis
5. Debe tener whitelist de métodos permitidos

---

### Grupo 3: ImpulsaProjectTopic - Asociación Faltante (4 errors)
**Prioridad:** MEDIA

**Problema:**
`NoMethodError: undefined method 'impulsa_project_topics' for an instance of ImpulsaEditionTopic`

**Archivos Afectados:**
- `test/models/impulsa_project_topic_test.rb` (4 tests)

**Modelo Afectado:**
- `app/models/impulsa_edition_topic.rb`

**Solución:**
Agregar asociación `has_many :impulsa_project_topics` al modelo `ImpulsaEditionTopic`

---

### Grupo 4: Order - Config Nil (1 error)
**Prioridad:** BAJA

**Problema:**
`NoMethodError: undefined method '[]' for nil` en `app/models/order.rb:116:in 'payment_day'`

**Test Afectado:**
- `test/models/order_test.rb:372` - `test_payment_day_should_return_configured_payment_day`

**Solución:**
1. Revisar `app/models/order.rb` línea 116
2. El método `payment_day` intenta acceder a un config que es nil
3. Agregar validación o configuración faltante

---

### Grupo 5: ImpulsaProject - Mensajes en Español (7 failures)
**Prioridad:** BAJA - Solo afecta mensajes de error

**Problema:**
Tests esperan mensajes de validación en español pero Rails devuelve en inglés

**Tests Afectados:**
- `test_should_require_content_rights_acceptance` - Espera "debe ser aceptado" recibe "must be accepted"
- `test_should_require_impulsa_edition_category_id` - Espera "no puede estar en blanco" recibe "can't be blank"
- `test_should_require_data_truthfulness_acceptance`
- `test_factory_creates_valid_impulsa_project`
- `test_should_require_status`
- `test_should_require_terms_of_service_acceptance`
- `test_should_require_name`

**Solución:**
1. Verificar configuración I18n en `config/application.rb`
2. Asegurar que `config.i18n.default_locale = :es` está configurado
3. Verificar que los archivos de traducción existen en `config/locales/es.yml`

---

### Grupo 6: Election - Lógica de Métodos/Scopes (4 failures)
**Prioridad:** MEDIA

**Problema:**
Scopes y métodos con lógica incorrecta

**Tests Afectados:**
- `test_available_servers_should_return_server_list_from_config` - Espera Hash, recibe Array
- `test_recently_finished?_should_return_false_for_old_finished_election` - Lógica invertida
- `test_upcoming_finished_scope_should_return_recent_elections` - Scope devuelve elecciones incorrectas
- `test_should_accept_valid_CSV_content_type` - `NoMethodError: undefined method 'fixture_file_upload'`

**Solución:**
1. Revisar método `available_servers` en modelo Election
2. Revisar método `recently_finished?`
3. Revisar scope `upcoming_finished`
4. Agregar helper `fixture_file_upload` al test

---

### Grupo 7: ReportGroup - ArgumentError (2 errors)
**Prioridad:** BAJA

**Problema:**
`ArgumentError: unknown keyword: :aliases` en `app/models/report_group.rb:104:in 'unserialize'`

**Tests Afectados:**
- `test_self.unserialize_should_unserialize_array_of_groups`
- `test_self.unserialize_should_unserialize_single_group`

**Solución:**
Revisar método `unserialize` en `ReportGroupl.rb` línea 104 - keyword argument inválido

---

### Grupo 8: Proposal - Lógica de Cálculos (2 failures)
**Prioridad:** MEDIA

**Problema:**
Métodos de cálculo devuelven valores incorrectos

**Tests Afectados:**
- `test_support_percentage_should_calculate_correctly` - Espera 20.0, recibe 0.0
- `test_agoravoting_required_votes?_should_return_true_when_threshold_met` - Devuelve false en lugar de true

**Solución:**
1. Revisar método `support_percentage` en modelo Proposal
2. Revisar método `agoravoting_required_votes?`

---

### Grupo 9: Skipped Tests (26 skips)
**Prioridad:** BAJA - Tests marcados para skip intencionalmente

**Tipos:**
- `OrderTest` - 6 skips por problemas de configuración de mailer y métodos application code
- `VoteCircleTypeTest` - 1 skip por tabla legacy no existente
- `ElectionLocationTest` - 1 skip

**Solución:**
Revisar cada skip y determinar si debe ser habilitado o si el skip es legítimo

---

## Plan de Acción Recomendado

### Fase 1: Quick Wins (Máximo impacto, mínimo esfuerzo)
1. **Configurar Mocha** - Resuelve ~20 errors
2. **Agregar asociación ImpulsaProjectTopic** - Resuelve 4 errors
3. **Configurar I18n para español** - Resuelve 7 failures

**Impacto:** ~31 tests arreglados

### Fase 2: Implementaciones Medianas
1. **Implementar SafeConditionEvaluator** - Resuelve 31 errors
2. **Fix Order.payment_day** - Resuelve 1 error
3. **Fix Election métodos/scopes** - Resuelve 4 failures
4. **Fix ReportGroup.unserialize** - Resuelve 2 errors
5. **Fix Proposal cálculos** - Resuelve 2 failures

**Impacto:** ~40 tests arreglados

### Fase 3: Revisión de Skips
1. Revisar y habilitar skipped tests donde sea apropiado

---

## Comandos Útiles

```bash
# Ejecutar todos los tests
RBENV_VERSION=3.3.10 RAILS_ENV=test rails test

# Ejecutar tests de un archivo específico
RBENV_VERSION=3.3.10 RAILS_ENV=test rails test test/models/election_test.rb

# Ejecutar un test específico
RBENV_VERSION=3.3.10 RAILS_ENV=test rails test test/models/election_test.rb:249

# Ver solo errores y failures
RBENV_VERSION=3.3.10 RAILS_ENV=test rails test 2>&1 | grep -E "(ERROR|FAIL)"
```

---

## Notas

- Los tests ahora se ejecutan completamente (antes fallaban inmediatamente)
- El sistema de engine concerns está funcionando correctamente
- La mayoría de los errores son pre-existentes, no relacionados con la modularización de Phase 0
- Total de trabajo estimado para fix completo: ~4-6 horas de desarrollo
