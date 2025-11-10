# Plan de Acción: Corrección de Problemas Fase 0

**Objetivo:** Corregir los 8 problemas CRÍTICOS antes de continuar con Fase 1

---

## PROBLEMA 1: Sistema NO es Dinámico (CRÍTICO)

### Tarea 1.1: Actualizar Documentación
**Archivos:**
- `doc/PHASE_0_COMPLETION_REPORT.md`
- `GUIA_MAESTRA_MODULARIZACION.md`
- `README` (si existe)

**Cambios:**
```markdown
# ANTES
- "Activación dinámica sin reinicio"
- "Dynamic loading without restart"

# DESPUÉS
- "Activación de engines (requiere reinicio de aplicación)"
- "Engine activation (requires application restart)"
```

### Tarea 1.2: Actualizar Mensajes en Código
**Archivo:** `lib/tasks/engines.rake:40,73`

```ruby
# ANTES
puts "\n⚠ Note: You may need to restart the application for changes to take effect"

# DESPUÉS
puts "\n⚠️ IMPORTANT: You MUST restart the application for changes to take effect"
puts "   Run: touch tmp/restart.txt  (Passenger)"
puts "   Or restart your Rails server"
```

### Tarea 1.3: Actualizar EngineActivation
**Archivo:** `app/models/engine_activation.rb:74`

```ruby
# ANTES
# This allows dynamic engine loading without server restart

# DESPUÉS
# Routes are reloaded, but concerns require application restart
# Run: touch tmp/restart.txt after enabling/disabling engines
```

---

## PROBLEMA 2: Duplicación de Asociaciones (CRÍTICO)

### Tarea 2.1: Eliminar Asociaciones del User Model
**Archivo:** `app/models/user.rb:44-50`

```ruby
# ELIMINAR ESTAS LÍNEAS:
# has_many :votes, dependent: :destroy
# has_many :paper_authority_votes, dependent: :nullify, class_name: "Vote", inverse_of: :paper_authority
# has_many :supports, dependent: :destroy
# has_many :collaborations, dependent: :destroy
# has_and_belongs_to_many :participation_teams
# has_many :microcredit_loans
# has_many :user_verifications
# has_many :militant_records

# MANTENER SOLO:
belongs_to :vote_circle  # Esta no está en concerns
```

### Tarea 2.2: Activar Todos los Engines por Defecto (Temporal)
**Archivo:** `db/seeds.rb:103`

```ruby
# CAMBIAR:
basic_engines = ['plebis_cms', 'plebis_participation']

# A:
all_engines = PlebisCore::EngineRegistry.available_engines

all_engines.each do |engine|
  activation = EngineActivation.find_by(engine_name: engine)
  if activation && !activation.enabled?
    activation.update!(enabled: true)
    puts "  ✓ #{engine} enabled"
  end
end
```

**Justificación:** Dado que User tiene dependencias en todos los concerns, todos deben estar activos para que funcione. Hasta que se refactoricen las dependencias, es más seguro tenerlos todos activos.

---

## PROBLEMA 3: Dependencias Cruzadas (CRÍTICO)

### Tarea 3.1: Agregar Validación de Dependencias
**Archivo:** `app/models/concerns/engine_user.rb:35-45`

```ruby
def register_engine_concern(engine_name, concern_module)
  return unless defined?(EngineActivation)
  return unless EngineActivation.table_exists?

  # Verificar que el engine está activo
  return unless EngineActivation.enabled?(engine_name)

  # NUEVO: Verificar dependencias antes de incluir
  deps = PlebisCore::EngineRegistry.dependencies_for(engine_name)
  missing_deps = deps.reject do |dep|
    dep == 'User' || EngineActivation.enabled?(dep)
  end

  if missing_deps.any?
    Rails.logger.error "[EngineUser] Cannot load #{engine_name}: missing dependencies #{missing_deps.join(', ')}"
    return
  end

  include concern_module
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
  Rails.logger.warn "[EngineUser] Database not ready: #{e.message}"
end
```

### Tarea 3.2: Documentar Orden de Registro
**Archivo:** `app/models/user.rb:27-35`

```ruby
# Register engine-specific concerns
# IMPORTANT: Order matters! Dependencies must be registered first
register_engine_concern('plebis_verification', EngineUser::Verifiable)     # No dependencies
register_engine_concern('plebis_collaborations', EngineUser::Collaborator) # No dependencies
register_engine_concern('plebis_voting', EngineUser::Votable)             # Needs verification
register_engine_concern('plebis_militant', EngineUser::Militant)          # Needs verification + collaborations
register_engine_concern('plebis_microcredit', EngineUser::Microcreditor)
register_engine_concern('plebis_impulsa', EngineUser::ImpulsaAuthor)
register_engine_concern('plebis_proposals', EngineUser::Proposer)
register_engine_concern('plebis_participation', EngineUser::TeamMember)
```

---

## PROBLEMA 4: reload_routes! Engañoso (CRÍTICO)

### Tarea 4.1: Simplificar enable!/disable!
**Archivo:** `app/models/engine_activation.rb:42-62`

```ruby
def self.enable!(engine_name)
  activation = find_or_initialize_by(engine_name: engine_name)
  activation.enabled = true
  activation.save!
  clear_cache(engine_name)
  activation
rescue ActiveRecord::RecordNotUnique
  retry
end

def self.disable!(engine_name)
  activation = find_by(engine_name: engine_name)
  return nil unless activation

  activation.update!(enabled: false)
  clear_cache(engine_name)
  activation
end

# ELIMINAR reload_routes! - No aporta valor y es confuso
```

---

## PROBLEMA 5: Race Condition (CRÍTICO)

### Ya resuelto en Tarea 4.1
Ver cambio de `find_or_create_by!` a `find_or_initialize_by` con `rescue retry`

---

## PROBLEMA 6: Template con Método Inexistente (CRÍTICO)

### Tarea 6.1: Eliminar register_abilities
**Archivo:** `lib/generators/plebis/engine/templates/engine.rb.tt:18-25`

```ruby
# ELIMINAR TODO ESTE BLOQUE:
# # Load abilities when the engine is loaded
# initializer "<%= @engine_name %>.load_abilities" do
#   config.to_prepare do
#     if defined?(Ability) && defined?(<%= @module_name %>::Ability)
#       Ability.register_abilities(<%= @module_name %>::Ability)
#     end
#   end
# end
```

### Tarea 6.2: Documentar Abilities en README
**Archivo:** `lib/generators/plebis/engine/templates/README.md.tt`

```markdown
## Abilities (CanCanCan)

This engine includes an Ability class at `app/abilities/<%= @engine_name %>/ability.rb`.

To use it, manually include it in your main Ability class:

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    # ... other abilities

    # Include engine abilities
    include_engine_abilities(user) if EngineActivation.enabled?('<%= @engine_name %>')
  end

  private

  def include_engine_abilities(user)
    <%= @module_name %>::Ability.new(user).tap do |ability|
      @rules.merge!(ability.rules)
    end
  end
end
```
```

---

## PROBLEMA 7: Test Helpers Rotos (CRÍTICO)

### Tarea 7.1: Documentar Limitaciones
**Archivo:** `spec/support/engine_helpers.rb:7-17`

```ruby
# Engine Test Helpers
#
# IMPORTANT LIMITATIONS:
# - These helpers only change database state and cache
# - They do NOT reload concerns in the User model
# - The User model's concerns are loaded once when the test suite starts
# - To test with different engine configurations, you must restart the test suite
#
# Use these helpers only for testing:
# - Route availability
# - Cache behavior
# - Database state changes
#
# Do NOT use for testing:
# - Model associations (concerns are already loaded)
# - Model methods from concerns (already present or absent)
#
module EngineHelpers
```

### Tarea 7.2: Agregar Helper para Mock
**Archivo:** `spec/support/engine_helpers.rb` (al final)

```ruby
# Mock engine activation without changing database
# Use this to test conditional behavior based on engine state
#
# Example:
#   mock_engine_state('plebis_cms', true) do
#     expect(some_method_that_checks_engine).to work
#   end
#
def mock_engine_state(engine_name, enabled)
  allow(EngineActivation).to receive(:enabled?)
    .with(engine_name)
    .and_return(enabled)
  yield
end
```

---

## PROBLEMA 8: Falta Validación de engine_name (CRÍTICO)

### Tarea 8.1: Agregar Validación Custom
**Archivo:** `app/models/engine_activation.rb:22-23`

```ruby
# ANTES
validates :engine_name, presence: true, uniqueness: true

# DESPUÉS
validates :engine_name, presence: true, uniqueness: true
validate :engine_name_must_be_valid

private

def engine_name_must_be_valid
  return if engine_name.blank? # Handled by presence validation
  return if PlebisCore::EngineRegistry.exists?(engine_name)

  errors.add(:engine_name, "is not a valid engine. Valid engines: #{PlebisCore::EngineRegistry.available_engines.join(', ')}")
end
```

---

## PROBLEMAS ALTOS (Quick Wins)

### N+1 Query Fixes

**Archivo:** `app/models/concerns/engine_user/votable.rb:43`
```ruby
# ANTES
Vote.where(election_id: election_id).where(user_id: self.id).present?

# DESPUÉS
Vote.where(election_id: election_id, user_id: self.id).exists?
```

**Archivo:** `lib/tasks/engines.rake:17-18`
```ruby
# ANTES
puts "Total: #{EngineActivation.count} engines"
puts "  - Active: #{EngineActivation.where(enabled: true).count}"
puts "  - Inactive: #{EngineActivation.where(enabled: false).count}"

# DESPUÉS
counts = EngineActivation.group(:enabled).count
puts "Total: #{counts.values.sum} engines"
puts "  - Active: #{counts[true] || 0}"
puts "  - Inactive: #{counts[false] || 0}"
```

### Safe Navigation

**Archivo:** `app/admin/engine_activations.rb:70-71`
```ruby
# ANTES
row("Models") { engine_info[:models].join(', ') }
row("Controllers") { engine_info[:controllers].join(', ') }

# DESPUÉS
row("Models") { engine_info[:models]&.join(', ') || 'None' }
row("Controllers") { engine_info[:controllers]&.join(', ') || 'None' }
```

**Archivo:** `lib/plebis_core/engine_registry.rb:192`
```ruby
# ANTES
metadata[:dependencies].include?(engine_name)

# DESPUÉS
metadata[:dependencies]&.include?(engine_name)
```

### Generator Validation

**Archivo:** `lib/generators/plebis/engine/engine_generator.rb:23`
```ruby
def create_engine_structure
  # AGREGAR AL INICIO
  validate_engine_name!

  @module_name = name.camelize
  @engine_name = "plebis_#{name}"
  @engine_path = "engines/#{@engine_name}"
  # ... resto
end

private

def validate_engine_name!
  unless name =~ /\A[a-z][a-z0-9_]*\z/
    say "Error: Engine name must start with a letter and contain only lowercase letters, numbers, and underscores", :red
    say "Example: rails generate plebis:engine my_feature", :yellow
    exit 1
  end

  if File.exist?("engines/plebis_#{name}")
    say "Error: Engine 'plebis_#{name}' already exists!", :red
    exit 1
  end
end
```

---

## CHECKLIST DE VERIFICACIÓN

Después de hacer los cambios, verificar:

### Tests de Regresión
```bash
# 1. Bundle debe instalar sin errores
bundle install

# 2. Migraciones deben correr
rails db:migrate

# 3. Seeds deben ejecutar
rails db:seed

# 4. Tests deben pasar
bundle exec rspec

# 5. Rails console debe iniciar
rails console
```

### Validaciones Manuales
```ruby
# En rails console:

# 1. Validar que todos los engines están activos
EngineActivation.where(enabled: false).count # Debe ser 0

# 2. Validar que User tiene los métodos de concerns
u = User.first
u.respond_to?(:votes) # debe ser true
u.respond_to?(:collaborations) # debe ser true

# 3. Intentar crear engine activation inválida
EngineActivation.create!(engine_name: 'invalid_engine')
# Debe fallar con error de validación

# 4. Verificar cache
EngineActivation.enabled?('plebis_cms') # true
Rails.cache.read("engine_activation:plebis_cms") # debe existir
```

### Verificar Documentación
- [ ] Ningún documento menciona "dynamic loading without restart"
- [ ] Todos los lugares que mencionan reinicio usan "MUST" no "may"
- [ ] README del generator documenta cómo usar Abilities
- [ ] Test helpers documentan sus limitaciones

---

## TIEMPO ESTIMADO

- **Críticos (1-8):** 4-6 horas
- **N+1 Queries:** 1-2 horas
- **Safe Navigation:** 30 minutos
- **Generator Validation:** 1 hora
- **Testing:** 2-3 horas

**Total:** 8-12 horas (1-1.5 días)

---

## ORDEN DE EJECUCIÓN

1. ✅ **Documentación** (Problema 1) - 30 min
2. ✅ **Validaciones** (Problemas 5, 8, Generator) - 2 horas
3. ✅ **User Model** (Problema 2) - 1 hora
4. ✅ **Dependencias** (Problema 3) - 1.5 horas
5. ✅ **Simplificar EngineActivation** (Problema 4) - 30 min
6. ✅ **Template Fix** (Problema 6) - 30 min
7. ✅ **Test Helpers** (Problema 7) - 1 hora
8. ✅ **N+1 y Safe Navigation** - 2 horas
9. ✅ **Testing completo** - 3 horas

---

## DESPUÉS DE LOS FIXES

Una vez corregidos estos problemas:

1. **Commit:** Hacer un commit con todos los fixes
2. **Documentar:** Actualizar PHASE_0_COMPLETION_REPORT.md
3. **Review:** Pedir otra revisión de código
4. **Decidir:** ¿Vale la pena la complejidad del sistema de engines?
   - Si SÍ → Continuar con Fase 1
   - Si NO → Considerar simplificar a engines estáticos

---

**Prioridad:** ALTA - No continuar con Fase 1 hasta resolver críticos
