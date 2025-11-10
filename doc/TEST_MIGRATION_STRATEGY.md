# Estrategia de Migración de Tests: Minitest → RSpec

**Fecha:** 2025-11-10
**Estado:** Pendiente de completar
**Fase:** Fase 0 - Preparación del Core

## Resumen

Actualmente el proyecto tiene **32 archivos de tests en Minitest** que deben ser migrados a RSpec para mantener consistencia con el resto de la suite de tests (119 specs RSpec existentes).

## Inventario de Tests Minitest

### Modelos (15 tests)
```
test/models/
├── election_location_question_test.rb
├── user_verification_test.rb
├── report_test.rb
├── microcredit_option_test.rb
├── notice_registrar_test.rb
├── election_test.rb
├── microcredit_loan_test.rb
├── election_location_test.rb
├── impulsa_edition_topic_test.rb
├── order_test.rb
├── vote_test.rb
├── vote_circle_test.rb
├── impulsa_project_topic_test.rb
├── post_test.rb
└── concerns/
    └── safe_condition_evaluator_test.rb
```

### Otros (17 tests)
- Controladores
- Integración
- Helpers
- Servicios

## Estrategia de Migración

### Fase 1: Tests Críticos (Prioridad Alta)
Migrar primero los tests de modelos core y concerns:

1. **User-related tests** - Tests de lógica de usuario
2. **EngineActivation tests** - Tests del nuevo modelo
3. **Concerns tests** - Tests de EngineUser concerns
4. **Modelo core tests** - Vote, Election, Collaboration

### Fase 2: Tests de Engines (Prioridad Media)
Migrar tests que serán movidos a engines:

1. **Voting**: election_test, vote_test, vote_circle_test
2. **Verification**: user_verification_test
3. **Impulsa**: impulsa_*_test
4. **Microcredit**: microcredit_*_test
5. **CMS**: post_test, notice_registrar_test
6. **Collaborations**: order_test

### Fase 3: Tests Auxiliares (Prioridad Baja)
- Helpers
- Servicios
- Tests de integración

## Mapeo de Sintaxis

### Assertions Básicas
```ruby
# Minitest → RSpec
assert x              → expect(x).to be_truthy
assert_not x          → expect(x).to be_falsey
assert_nil x          → expect(x).to be_nil
assert_equal a, b     → expect(b).to eq(a)
assert_includes x, y  → expect(x).to include(y)
assert_raises(E) {}   → expect {}.to raise_error(E)
```

### Estructura de Test
```ruby
# Minitest
class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "should not save without email" do
    user = User.new
    assert_not user.save
  end
end

# RSpec
RSpec.describe User, type: :model do
  describe 'validations' do
    it 'does not save without email' do
      user = User.new
      expect(user.save).to be false
      expect(user.errors[:email]).to be_present
    end
  end
end
```

### Fixtures → FactoryBot
```yaml
# test/fixtures/users.yml
one:
  email: user@example.com
  first_name: User
```

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { 'User' }
    password { 'password123' }
  end
end
```

## Script de Migración Semi-Automática

```bash
# lib/tasks/migrate_tests.rake
namespace :test do
  desc "Migrate one Minitest file to RSpec"
  task :migrate, [:file] => :environment do |t, args|
    # Script para ayudar en la migración
    # No es completamente automático, requiere revisión manual
  end
end
```

## Checklist de Migración

Por cada archivo:

- [ ] Convertir class a RSpec.describe
- [ ] Convertir setup/teardown a before/after
- [ ] Convertir assertions a expectations
- [ ] Convertir fixtures a FactoryBot
- [ ] Ejecutar el test para verificar
- [ ] Revisar coverage
- [ ] Eliminar archivo Minitest original

## Tests Prioritarios para Migrar Ahora

### 1. Concerns Test (CRÍTICO)
```
test/models/concerns/safe_condition_evaluator_test.rb
→ spec/models/concerns/safe_condition_evaluator_spec.rb
```

Este test es crítico porque valida un concern de seguridad.

### 2. Modelo Core Tests
- election_test.rb → Será movido a plebis_voting
- vote_test.rb → Será movido a plebis_voting
- order_test.rb → Será movido a plebis_collaborations

## Comandos Útiles

```bash
# Ejecutar tests Minitest actuales
rake test

# Ejecutar tests RSpec actuales
bundle exec rspec

# Ejecutar ambos (temporalmente)
rake test && bundle exec rspec

# Ver coverage
open coverage/index.html
```

## Notas Importantes

1. **No eliminar Minitest hasta que todos estén migrados**
2. **Mantener CI ejecutando ambos frameworks temporalmente**
3. **Migrar tests al mismo tiempo que se migra el código a engines**
4. **Priorizar tests que validan funcionalidad crítica**

## Estado Actual

- ✅ Infraestructura RSpec configurada
- ✅ FactoryBot configurado
- ✅ Shared helpers creados
- ⏳ Migración de 32 tests pendiente
- ⏳ Eliminación de Minitest pendiente

## Siguiente Paso

Cuando se comience con la Fase 1 (extracción de engines), migrar los tests correspondientes **antes** de mover el código. Por ejemplo:

1. Antes de crear plebis_cms engine:
   - Migrar post_test.rb a spec/models/post_spec.rb
   - Verificar que pasa
   - Luego mover el código al engine

## Recursos

- [RSpec Rails Docs](https://rspec.info/documentation/)
- [FactoryBot Getting Started](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
- [Minitest to RSpec Guide](https://www.fullstackruby.dev/ruby-rspec/2021/01/11/testing-ruby-with-rspec-and-minitest/)

---

**Documento de trabajo - Actualizar conforme se avanza**
