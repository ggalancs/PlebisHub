# GUÍA MAESTRA DE MODULARIZACIÓN PLEBISHUB
## Transformación de Monolito a Arquitectura de Engines Pluggables

**Versión:** 1.0
**Fecha:** 2025-11-10
**Objetivo:** Dividir PlebisHub en un núcleo principal + gemas/engines activables desde admin

---

## TABLA DE CONTENIDOS

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Análisis de Situación Actual](#análisis-de-situación-actual)
3. [Arquitectura Objetivo](#arquitectura-objetivo)
4. [Estrategia de Migración](#estrategia-de-migración)
5. [Sistema de Activación desde Admin](#sistema-de-activación-desde-admin)
6. [Planes Detallados por Engine](#planes-detallados-por-engine)
7. [Preparación del Core](#preparación-del-core)
8. [Checklist de Implementación](#checklist-de-implementación)

---

## 1. RESUMEN EJECUTIVO

### 1.1 Situación Actual
- **Aplicación monolítica** Rails 7.2 con 118 archivos Ruby
- **27 controladores**, **37 modelos**, **151 archivos de test**
- Dominio: Participación democrática, votaciones, crowdfunding, propuestas ciudadanas
- Sin modularización actual (0 engines Rails)
- Modelo User central con **alto acoplamiento** a todos los dominios

### 1.2 Visión Objetivo
Transformar PlebisHub en una **plataforma modular** donde:
- **Core mínimo**: Autenticación, autorización, usuarios, admin base
- **8-10 engines pluggables** activables desde consola admin
- **Configuración dinámica** sin redespliegue
- **Base de datos compartida** con aislamiento lógico
- **Tests por engine** con suite independiente
- **Consolidación a RSpec** (eliminar Minitest)

### 1.3 Beneficios Esperados
- ✅ **Mantenibilidad**: Equipos trabajando en engines aislados
- ✅ **Reutilización**: Engines usables en otros proyectos (ej: sistema de votaciones)
- ✅ **Flexibilidad**: Activar/desactivar funcionalidades por cliente
- ✅ **Escalabilidad**: Posibilidad futura de extraer a microservicios
- ✅ **Testing**: Suites independientes, más rápidas
- ✅ **Deploy**: Menos riesgo al cambiar un engine específico

### 1.4 Duración Estimada
- **Fase 0 (Preparación)**: 2-3 semanas
- **Fase 1 (Engines simples)**: 2-3 meses
- **Fase 2 (Engines medios)**: 3-4 meses
- **Fase 3 (Engines complejos)**: 6-9 meses
- **Total**: 12-18 meses para completar toda la modularización

---

## 2. ANÁLISIS DE SITUACIÓN ACTUAL

### 2.1 Inventario Completo

#### Controladores por Área Funcional (27 total)
```
AUTENTICACIÓN (5):
  - sessions_controller.rb
  - registrations_controller.rb
  - passwords_controller.rb
  - confirmations_controller.rb
  - legacy_password_controller.rb

VOTACIONES (1):
  - vote_controller.rb → 500+ líneas, complejo

MICROCREDITOS (1):
  - microcredit_controller.rb

COLABORACIONES (2):
  - collaborations_controller.rb
  - orders_controller.rb

IMPULSA (1):
  - impulsa_controller.rb → Wizard multi-paso

VERIFICACIÓN (2):
  - user_verifications_controller.rb
  - sms_validator_controller.rb

PROPUESTAS (2):
  - proposals_controller.rb
  - supports_controller.rb

EQUIPOS PARTICIPACIÓN (1):
  - participation_teams_controller.rb

CONTENIDO (3):
  - blog_controller.rb
  - page_controller.rb
  - notice_controller.rb

MILITANCIA (1):
  - militant_controller.rb

UTILIDADES (7):
  - application_controller.rb
  - api/v1_controller.rb
  - api/v2_controller.rb
  - audio_captcha_controller.rb
  - open_id_controller.rb
  - tools_controller.rb
  - errors_controller.rb
```

#### Modelos por Área Funcional (37 total)
```
CORE:
  - User (central)
  - Ability (CanCanCan)
  - ApplicationRecord

VOTACIONES (6):
  - Election
  - ElectionLocation
  - ElectionLocationQuestion
  - Vote
  - VoteCircle
  - VoteCircleType

MICROCREDITOS (3):
  - Microcredit
  - MicrocreditLoan
  - MicrocreditOption

COLABORACIONES (2):
  - Collaboration
  - Order

IMPULSA (6):
  - ImpulsaEdition
  - ImpulsaEditionCategory
  - ImpulsaEditionTopic
  - ImpulsaProject
  - ImpulsaProjectStateTrans
  - ImpulsaProjectTopic

PROPUESTAS (2):
  - Proposal
  - Support

VERIFICACIÓN (1):
  - UserVerification

CONTENIDO (5):
  - Post
  - Category
  - Page
  - Notice
  - NoticeRegistrar

MILITANCIA (1):
  - MilitantRecord

EQUIPOS (1):
  - ParticipationTeam

REPORTES (3):
  - Report
  - ReportGroup
  - SpamFilter
```

#### Tests por Área (151 archivos)
```
RSpec (119 specs):
  - Votaciones: 25 tests (7 factories)
  - Impulsa: 19 tests (6 factories)
  - Auth/User: 18 tests
  - Verificación: 15 tests (3 servicios)
  - Microcreditos: 13 tests (3 factories)
  - Colaboraciones: 13 tests
  - Blog/Contenido: 17 tests
  - Notice: 6 tests
  - Militant: 5 tests
  - Teams: 4 tests
  - API: 3 tests
  - Otros: 12 tests

Minitest (32 tests) → MIGRAR A RSPEC
```

### 2.2 Dependencias Críticas

#### Diagrama de Acoplamiento
```
                    ┌─────────────┐
                    │    USER     │
                    │  (Central)  │
                    └──────┬──────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
       ▼                   ▼                   ▼
┌────────────┐      ┌────────────┐      ┌────────────┐
│  VOTING    │      │ MICROCREDIT│      │   IMPULSA  │
│            │      │            │      │            │
│ depends on │      │ depends on │      │ depends on │
│ VERIFICATION│     │   ORDER    │      │    User    │
└────────────┘      └────────────┘      └────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌────────────┐      ┌────────────┐      ┌────────────┐
│VERIFICATION│      │COLLABORATION│     │    CMS     │
│            │      │            │      │            │
│ depends on │      │ depends on │      │ independent│
│    User    │      │   MILITANT │      │            │
└────────────┘      └────────────┘      └────────────┘
```

#### Matriz de Dependencias
| Engine            | Depende de        | Es requerido por  |
|-------------------|-------------------|-------------------|
| CMS               | User (autor)      | -                 |
| ParticipationTeams| User (HABTM)      | -                 |
| Proposals         | User              | -                 |
| Impulsa           | User              | -                 |
| Verification      | User              | Voting            |
| Microcredit       | User, Order       | -                 |
| Collaboration     | User, Order       | Militant          |
| Voting            | User, Verification| -                 |
| Militant          | User, Collaboration| -               |

### 2.3 Problemas Identificados

#### Anti-patrones Actuales
1. **Fat User Model**: Probablemente 500+ líneas con 15+ asociaciones
2. **God Controller**: vote_controller.rb muy extenso
3. **Lógica en Controladores**: Poca extracción a servicios
4. **Acoplamiento Directo**: Asociaciones AR directas entre dominios
5. **Sin Eventos**: Comunicación síncrona entre dominios
6. **Tests Mixtos**: RSpec + Minitest en paralelo

#### Riesgos de la Migración
1. **Refactorización del User**: Tarea más compleja y arriesgada
2. **Rutas Complejas**: Sistema de locales (es/ca/eu)
3. **Migraciones BD**: Coordinación entre engines
4. **Autorización**: CanCanCan distribuido en engines
5. **Assets Compartidos**: JS/CSS entre engines
6. **Background Jobs**: Resque/Sidekiq desde engines

---

## 3. ARQUITECTURA OBJETIVO

### 3.1 Estructura de Directorios

```
PlebisHub/
├── app/                          # Core application
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── api/                  # APIs remain in core
│   │   ├── admin/                # ActiveAdmin base
│   │   └── users/                # Devise controllers
│   ├── models/
│   │   ├── user.rb              # Core user model
│   │   ├── ability.rb           # Base abilities
│   │   └── concerns/
│   │       └── engine_user.rb   # Interface for engines
│   ├── services/
│   │   └── engine_manager.rb    # Engine activation service
│   └── views/
│       └── layouts/             # Shared layouts
│
├── engines/                      # Rails Engines
│   ├── plebis_cms/
│   │   ├── app/
│   │   │   ├── controllers/plebis_cms/
│   │   │   ├── models/plebis_cms/
│   │   │   └── views/plebis_cms/
│   │   ├── config/routes.rb
│   │   ├── db/migrate/
│   │   ├── lib/plebis_cms.rb
│   │   ├── lib/plebis_cms/engine.rb
│   │   ├── spec/               # Engine tests
│   │   ├── plebis_cms.gemspec
│   │   └── README.md
│   │
│   ├── plebis_participation/
│   ├── plebis_proposals/
│   ├── plebis_impulsa/
│   ├── plebis_verification/
│   ├── plebis_voting/
│   ├── plebis_microcredit/
│   ├── plebis_collaborations/
│   └── plebis_militant/
│
├── lib/
│   ├── plebis_core/            # Core utilities
│   │   ├── event_bus.rb        # Event system
│   │   ├── engine_interface.rb # Engine base
│   │   └── configuration.rb
│   └── tasks/
│
├── gems/                        # Standalone gems
│   ├── plebis_payments/        # Payment processing
│   ├── plebis_sms/             # SMS validation
│   └── plebis_validators/      # Spanish validators
│
├── db/
│   └── migrate/
│       ├── 001_create_users.rb
│       ├── 050_create_engine_activations.rb
│       ├── 100_cms/            # CMS migrations
│       ├── 200_voting/         # Voting migrations
│       └── ...
│
├── spec/
│   ├── spec_helper.rb
│   ├── rails_helper.rb
│   ├── support/                # Shared test utilities
│   │   ├── factory_bot.rb
│   │   ├── devise.rb
│   │   └── engine_helpers.rb
│   └── factories/
│       └── users.rb            # Shared user factory
│
├── Gemfile
└── config/
    ├── application.rb
    ├── routes.rb              # Core + dynamic engine routes
    └── initializers/
        └── engine_loader.rb   # Dynamic engine loading
```

### 3.2 Engine Base Template

Cada engine seguirá esta estructura estándar:

```ruby
# engines/plebis_cms/lib/plebis_cms/engine.rb
module PlebisCms
  class Engine < ::Rails::Engine
    isolate_namespace PlebisCms

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer "plebis_cms.load_abilities" do
      config.to_prepare do
        Ability.register_abilities(PlebisCms::Ability)
      end
    end

    # Hook para verificar activación
    initializer "plebis_cms.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('plebis_cms')
        Rails.logger.info "[PlebisCms] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end
  end
end
```

### 3.3 Modelo Core: User Refactorizado

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Core associations only
  has_one :vote_circle
  has_many :engine_activations

  # Engine concerns (loaded when engine active)
  include EngineUser::Votable if EngineActivation.enabled?('plebis_voting')
  include EngineUser::Collaborator if EngineActivation.enabled?('plebis_collaborations')
  include EngineUser::Verifiable if EngineActivation.enabled?('plebis_verification')
  # ... etc

  # Core methods
  def superadmin?
    flags & FLAG_SUPERADMIN > 0
  end

  def can_access_engine?(engine_name)
    EngineActivation.user_can_access?(self, engine_name)
  end
end

# app/models/concerns/engine_user.rb
module EngineUser
  extend ActiveSupport::Concern

  # Interface methods that engines can rely on
  included do
    # Standard interface for all engines
  end

  # Módulos por engine
  module Votable
    extend ActiveSupport::Concern
    included do
      has_many :votes, class_name: 'PlebisVoting::Vote'
      has_many :elections, through: :votes
    end
  end

  module Collaborator
    extend ActiveSupport::Concern
    included do
      has_many :collaborations, class_name: 'PlebisCollaborations::Collaboration'
      has_many :orders, as: :parent
    end
  end

  # ... más módulos
end
```

### 3.4 Sistema de Activación de Engines

#### Modelo: EngineActivation

```ruby
# db/migrate/XXX_create_engine_activations.rb
class CreateEngineActivations < ActiveRecord::Migration[7.2]
  def change
    create_table :engine_activations do |t|
      t.string :engine_name, null: false, index: { unique: true }
      t.boolean :enabled, default: false, null: false
      t.jsonb :configuration, default: {}
      t.text :description
      t.integer :load_priority, default: 100
      t.timestamps
    end
  end
end

# app/models/engine_activation.rb
class EngineActivation < ApplicationRecord
  validates :engine_name, presence: true, uniqueness: true

  # Cache para evitar queries repetidas
  def self.enabled?(engine_name)
    Rails.cache.fetch("engine_activation:#{engine_name}", expires_in: 5.minutes) do
      exists?(engine_name: engine_name, enabled: true)
    end
  end

  def self.enable!(engine_name)
    find_or_create_by!(engine_name: engine_name).update!(enabled: true)
    clear_cache(engine_name)
    reload_routes!
  end

  def self.disable!(engine_name)
    find_by(engine_name: engine_name)&.update!(enabled: false)
    clear_cache(engine_name)
    reload_routes!
  end

  private

  def self.clear_cache(engine_name)
    Rails.cache.delete("engine_activation:#{engine_name}")
  end

  def self.reload_routes!
    # Forzar recarga de rutas sin restart
    Rails.application.reload_routes!
  rescue => e
    Rails.logger.error "Failed to reload routes: #{e.message}"
  end
end
```

#### ActiveAdmin Resource

```ruby
# app/admin/engine_activations.rb
ActiveAdmin.register EngineActivation do
  permit_params :engine_name, :enabled, :description, :configuration, :load_priority

  index do
    selectable_column
    id_column
    column :engine_name
    column :enabled do |ea|
      status_tag(ea.enabled ? "Active" : "Inactive", ea.enabled ? :ok : :warning)
    end
    column :description
    column :load_priority
    actions defaults: true do |ea|
      if ea.enabled
        link_to 'Disable', disable_admin_engine_activation_path(ea), method: :post, class: 'button'
      else
        link_to 'Enable', enable_admin_engine_activation_path(ea), method: :post, class: 'button'
      end
    end
  end

  member_action :enable, method: :post do
    resource.update!(enabled: true)
    EngineActivation.clear_cache(resource.engine_name)
    redirect_to admin_engine_activations_path, notice: "Engine '#{resource.engine_name}' enabled. Reload may be required."
  end

  member_action :disable, method: :post do
    resource.update!(enabled: false)
    EngineActivation.clear_cache(resource.engine_name)
    redirect_to admin_engine_activations_path, notice: "Engine '#{resource.engine_name}' disabled. Reload may be required."
  end

  form do |f|
    f.inputs do
      f.input :engine_name, as: :select, collection: PlebisCore::EngineRegistry.available_engines
      f.input :enabled
      f.input :description
      f.input :load_priority, hint: "Lower numbers load first (default: 100)"
      f.input :configuration, as: :jsonb
    end
    f.actions
  end
end
```

#### Dynamic Routes Loading

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Core routes
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }

  ActiveAdmin.routes(self)

  # Locale wrapper
  scope "/:locale", locale: /es|ca|eu/ do
    # Core application routes
    root 'page#index'

    get 'pages/:id', to: 'page#show', as: :page

    # Dynamic engine mounting
    PlebisCore::EngineLoader.mount_enabled_engines(self)
  end

  # API routes (no locale)
  namespace :api do
    namespace :v1 do
      # ...
    end
    namespace :v2 do
      # ...
    end
  end
end

# lib/plebis_core/engine_loader.rb
module PlebisCore
  class EngineLoader
    def self.mount_enabled_engines(router)
      EngineActivation.where(enabled: true).order(:load_priority).each do |activation|
        engine_class = activation.engine_name.camelize.constantize::Engine rescue next

        Rails.logger.info "[EngineLoader] Mounting #{activation.engine_name}"

        # Montar rutas del engine
        router.mount engine_class => "/", as: activation.engine_name
      rescue => e
        Rails.logger.error "[EngineLoader] Failed to mount #{activation.engine_name}: #{e.message}"
      end
    end
  end
end
```

### 3.5 Event Bus para Desacoplamiento

```ruby
# lib/plebis_core/event_bus.rb
module PlebisCore
  class EventBus
    def self.publish(event_name, payload = {})
      ActiveSupport::Notifications.instrument("plebis.#{event_name}", payload)
    end

    def self.subscribe(event_name, &block)
      ActiveSupport::Notifications.subscribe("plebis.#{event_name}", &block)
    end
  end
end

# Ejemplo de uso:

# En engine de Collaborations (publicador)
class Collaboration < ApplicationRecord
  after_commit :publish_collaboration_created, on: :create

  def publish_collaboration_created
    PlebisCore::EventBus.publish('collaboration.created', {
      user_id: user_id,
      amount: amount,
      frequency: frequency
    })
  end
end

# En engine de Militant (suscriptor)
# lib/plebis_militant/engine.rb
initializer "plebis_militant.subscribe_events" do
  PlebisCore::EventBus.subscribe('collaboration.created') do |event|
    payload = event.payload
    PlebisMilitant::MilitantStatusUpdater.call(user_id: payload[:user_id])
  end
end
```

---

## 4. ESTRATEGIA DE MIGRACIÓN

### 4.1 Principios Guía

1. **Incremental**: Extraer un engine a la vez
2. **No-Downtime**: Aplicación funcional en cada paso
3. **Tests First**: Suite de tests pasando antes y después
4. **Database Last**: Cambios de BD al final (engines comparten BD inicialmente)
5. **Feature Flags**: Sistema de activación ANTES de extraer
6. **Documentation**: README actualizado con cada engine

### 4.2 Orden de Extracción (Priorizado)

#### FASE 0: PREPARACIÓN DEL CORE (2-3 semanas)

**Objetivo**: Preparar base para engines

1. **Refactorizar User Model**
   - Extraer concerns por dominio
   - Crear módulos EngineUser::*
   - Tests: Verificar que User mantiene funcionalidad

2. **Implementar Sistema de Activación**
   - Crear modelo EngineActivation
   - ActiveAdmin resource
   - Middleware de verificación
   - Tests: Activación/desactivación

3. **Crear Event Bus**
   - Implementar PlebisCore::EventBus
   - Tests: Publicación y suscripción

4. **Consolidar Tests a RSpec**
   - Migrar 32 Minitest a RSpec
   - Eliminar test/
   - Actualizar CI

5. **Preparar Shared Test Utilities**
   - spec/support/engine_helpers.rb
   - spec/factories/users.rb (compartido)
   - Documentar convenciones

6. **Generator para Engines**
   - rails generate plebis:engine nombre
   - Template con estructura estándar

**Entregables**:
- ✅ User model refactorizado
- ✅ Sistema de activación funcionando
- ✅ Event bus implementado
- ✅ Tests 100% en RSpec
- ✅ Generator de engines
- ✅ Documentación del proceso

---

#### FASE 1: ENGINES SIMPLES (2-3 meses)

##### Engine 1: PLEBIS_CMS (Semanas 1-3)

**Complejidad**: Baja
**Modelos**: 5 (Post, Category, Page, Notice, NoticeRegistrar)
**Controladores**: 3 (blog, page, notice)
**Tests**: 17 specs + 6 de notice
**Dependencias**: User (solo autor)

**Plan Detallado**:

1. **Crear estructura del engine** (Día 1-2)
   ```bash
   rails generate plebis:engine cms
   ```
   - Estructura de directorios
   - plebis_cms.gemspec
   - lib/plebis_cms/engine.rb
   - spec/spec_helper.rb
   - README.md

2. **Mover modelos** (Día 3-5)
   ```ruby
   # De: app/models/post.rb
   # A: engines/plebis_cms/app/models/plebis_cms/post.rb

   module PlebisCms
     class Post < ApplicationRecord
       self.table_name = 'posts' # Mantener tabla existente
       belongs_to :user # Referencia al core
     end
   end
   ```
   - Actualizar namespaces
   - Mantener nombres de tabla existentes
   - Tests de modelo

3. **Mover controladores** (Día 6-8)
   ```ruby
   # De: app/controllers/blog_controller.rb
   # A: engines/plebis_cms/app/controllers/plebis_cms/blog_controller.rb

   module PlebisCms
     class BlogController < ApplicationController
       # ...
     end
   end
   ```
   - Actualizar rutas en engine
   - Tests de controlador

4. **Mover vistas** (Día 9-10)
   - Mantener nombres de vistas
   - Actualizar paths en controladores
   - Tests de vistas

5. **ActiveAdmin resources** (Día 11-12)
   ```ruby
   # engines/plebis_cms/app/admin/posts.rb
   ActiveAdmin.register PlebisCms::Post do
     # ...
   end
   ```

6. **Integración con sistema de activación** (Día 13-14)
   ```ruby
   # engines/plebis_cms/lib/plebis_cms/engine.rb
   initializer "plebis_cms.check_activation" do
     unless EngineActivation.enabled?('plebis_cms')
       config.paths["config/routes.rb"].skip_if { true }
     end
   end
   ```

7. **Migración de tests** (Día 15-17)
   - Copiar 23 archivos de test
   - Actualizar factories
   - Suite pasando al 100%

8. **Documentación** (Día 18)
   - README del engine
   - Guía de activación
   - API docs

9. **Revisión y QA** (Día 19-21)
   - Code review
   - Testing manual
   - Performance check

**Criterios de Éxito**:
- ✅ Engine montado y accesible
- ✅ Activación/desactivación desde admin
- ✅ Tests pasando (23 specs)
- ✅ No regresiones en core
- ✅ Documentación completa

---

##### Engine 2: PLEBIS_PARTICIPATION (Semanas 4-5)

**Complejidad**: Muy Baja
**Modelos**: 1 (ParticipationTeam)
**Controladores**: 1
**Tests**: 4 specs
**Dependencias**: User (HABTM)

**Plan Detallado**:

1. **Crear engine** (Día 1)
2. **Mover modelo ParticipationTeam** (Día 2)
   - HABTM con User
   - Tabla join: `participation_teams_users`
3. **Mover controlador** (Día 3)
4. **Mover vistas** (Día 4)
5. **ActiveAdmin resource** (Día 5)
6. **Tests** (Día 6-7)
7. **Documentación** (Día 8)
8. **QA** (Día 9-10)

**Criterios de Éxito**:
- ✅ Engine funcionando
- ✅ Tests pasando (4 specs)
- ✅ Documentación

---

##### Engine 3: PLEBIS_PROPOSALS (Semanas 6-8)

**Complejidad**: Baja-Media
**Modelos**: 2 (Proposal, Support)
**Controladores**: 2
**Tests**: ~10 specs
**Dependencias**: User, Reddit API

**Plan Detallado**:

1. **Crear engine** (Día 1)
2. **Mover modelos** (Día 2-4)
   - Proposal
   - Support
   - Relaciones User
3. **Mover controladores** (Día 5-7)
4. **Integración Reddit API** (Día 8-9)
   - Mover lib/reddit.rb al engine
5. **Vistas** (Día 10-11)
6. **ActiveAdmin** (Día 12)
7. **Tests** (Día 13-15)
8. **Documentación** (Día 16)
9. **QA** (Día 17-21)

**Notas**:
- Feature actualmente deshabilitada en rutas
- Oportunidad para reactivarla tras migración

**Criterios de Éxito**:
- ✅ Engine funcionando
- ✅ Tests pasando
- ✅ Integración Reddit OK
- ✅ Documentación

---

#### FASE 2: ENGINES DE COMPLEJIDAD MEDIA (3-4 meses)

##### Engine 4: PLEBIS_IMPULSA (Semanas 9-14)

**Complejidad**: Media-Alta
**Modelos**: 6
**Controladores**: 1 (complejo, wizard)
**Tests**: 19 specs + 6 factories
**Dependencias**: User, File uploads, State machine

**Plan Detallado**:

**Semana 1-2: Preparación y modelos**
1. Crear engine
2. Mover modelos:
   - ImpulsaEdition
   - ImpulsaEditionCategory
   - ImpulsaEditionTopic
   - ImpulsaProject (+ concerns)
   - ImpulsaProjectStateTrans
   - ImpulsaProjectTopic
3. Mover concerns:
   - ImpulsaProjectStates (state machine)
   - ImpulsaProjectWizard
   - ImpulsaProjectEvaluation

**Semana 3: Controlador y wizard**
4. Mover impulsa_controller.rb
5. Refactorizar wizard multi-paso
6. Tests de controlador

**Semana 4: File uploads y vistas**
7. Configurar Paperclip en engine
8. Mover vistas del wizard
9. Mover mailers

**Semana 5: Admin y validaciones**
10. ActiveAdmin resources (múltiples)
11. Validaciones complejas
12. Autorización (CanCanCan)

**Semana 6: Tests y QA**
13. Migrar 19 specs
14. Migrar 6 factories
15. Suite completa pasando
16. Documentación
17. QA exhaustivo

**Criterios de Éxito**:
- ✅ Wizard funcionando
- ✅ State machine operativa
- ✅ File uploads OK
- ✅ Tests pasando (19 specs)
- ✅ Evaluación de proyectos funcional
- ✅ Documentación completa

---

##### Engine 5: PLEBIS_VERIFICATION (Semanas 15-20)

**Complejidad**: Media
**Modelos**: 1 (UserVerification)
**Controladores**: 2 (user_verifications, sms_validator)
**Tests**: 15 specs (3 servicios)
**Dependencias**: User, SMS provider, File uploads

**Plan Detallado**:

**Semana 1-2: Modelos y servicios**
1. Crear engine
2. Mover UserVerification
3. Mover servicios:
   - user_verification_report_service.rb
   - exterior_verification_report_service.rb
   - town_verification_report_service.rb
   - url_signature_service.rb (compartido)

**Semana 3: SMS validation**
4. Mover sms_validator_controller.rb
5. Integrar lib/sms.rb
6. Configurar Esendex provider

**Semana 4: Verificación con documentos**
7. Mover user_verifications_controller.rb
8. File uploads (fotos DNI)
9. Lógica de aprobación/rechazo

**Semana 5: Admin y reportes**
10. ActiveAdmin resources
11. Reportes de verificación
12. Exportación de datos

**Semana 6: Tests y QA**
13. Migrar 15 specs
14. Tests de servicios
15. Tests de integración SMS
16. Documentación
17. QA

**Criterios de Éxito**:
- ✅ Verificación SMS funcionando
- ✅ Verificación con DNI OK
- ✅ Reportes generándose
- ✅ Tests pasando (15 specs)
- ✅ Documentación

---

##### Engine 6: PLEBIS_MICROCREDIT (Semanas 21-26)

**Complejidad**: Media
**Modelos**: 3
**Controladores**: 1
**Tests**: 13 specs + 3 factories
**Dependencias**: User, Order (renovaciones), Email

**Plan Detallado**:

**Semana 1-2: Modelos**
1. Crear engine
2. Mover modelos:
   - Microcredit
   - MicrocreditLoan
   - MicrocreditOption (jerárquico)
3. Relaciones con User

**Semana 3: Controlador y lógica de negocio**
4. Mover microcredit_controller.rb
5. Mover loan_renewal_service.rb
6. Lógica de campañas múltiples

**Semana 4: Configuración y brands**
7. Configuración por marca (brand-specific)
8. Validaciones IBAN/BIC
9. Emails de confirmación

**Semana 5: Admin y reportes**
10. ActiveAdmin resources
11. Reportes de préstamos
12. Exportación

**Semana 6: Tests y QA**
13. Migrar 13 specs
14. Migrar 3 factories
15. Tests de renovación
16. Documentación
17. QA

**Criterios de Éxito**:
- ✅ Campañas de microcréditos OK
- ✅ Préstamos gestionados
- ✅ Renovaciones automáticas
- ✅ Tests pasando (13 specs)
- ✅ Documentación

---

#### FASE 3: ENGINES COMPLEJOS (6-9 meses)

##### Engine 7: PLEBIS_COLLABORATIONS (Meses 7-9)

**Complejidad**: Alta
**Modelos**: 2 (Collaboration, Order)
**Controladores**: 2
**Tests**: 13 specs
**Dependencias**: User, Payment gateways, SEPA, Militant

**Plan Detallado**:

**Mes 1: Preparación y análisis**
1. Crear engine
2. Analizar dependencias complejas:
   - Order (polymorphic parent)
   - Redsys integration
   - SEPA direct debit
   - Militant status calculation

**Mes 2: Modelos y payment processing**
3. Mover Collaboration
4. Mover Order (mantener polymorphic)
5. Extraer payment processing a gem:
   - Crear plebis_payments gem
   - Mover redsys_payment_processor.rb
   - Mover norma43 integration
   - Tests del gem

**Mes 3: Controladores e integración**
6. Mover collaborations_controller.rb
7. Mover orders_controller.rb
8. Configurar Redsys callbacks
9. SEPA XML generation
10. Mailers
11. ActiveAdmin resources
12. Tests completos
13. Documentación
14. QA exhaustivo

**Criterios de Éxito**:
- ✅ Donaciones recurrentes OK
- ✅ Donaciones one-time OK
- ✅ Redsys integration funcionando
- ✅ SEPA funcionando
- ✅ Gem plebis_payments extraído
- ✅ Tests pasando (13 specs + gem)
- ✅ Documentación completa

---

##### Engine 8: PLEBIS_VOTING (Meses 10-14)

**Complejidad**: Muy Alta
**Modelos**: 6
**Controladores**: 1 (500+ líneas)
**Tests**: 25 specs + 7 factories
**Dependencias**: User, Verification, nVotes API, SMS

**Plan Detallado**:

**Mes 1: Análisis y planificación**
1. Documentar sistema actual completo
2. Mapear integraciones externas:
   - nVotes/Agora Voting
   - SMS verification
   - Census files
3. Identificar puntos críticos de seguridad

**Mes 2: Modelos y data layer**
4. Crear engine
5. Mover modelos:
   - Election
   - ElectionLocation
   - ElectionLocationQuestion
   - Vote
   - VoteCircle
   - VoteCircleType
6. Tests de modelo

**Mes 3: Servicios y lógica de negocio**
7. Mover servicios:
   - census_file_parser.rb
   - paper_vote_service.rb
8. Refactorizar vote_controller.rb:
   - Extraer a servicios
   - Reducir complejidad
   - Mejorar testabilidad

**Mes 4: Integraciones externas**
9. Integración nVotes API
10. SMS verification para votaciones
11. Paper voting (autoridad presencial)
12. Generación de HMAC tokens
13. Voter ID generation

**Mes 5: Admin, reportes y exportación**
14. ActiveAdmin resources
15. Reportes de participación
16. Exportación de censo
17. Verificación de resultados

**Mes 6: Tests y QA crítico**
18. Migrar 25 specs
19. Migrar 7 factories
20. Tests de integración con nVotes (mocked)
21. Tests de seguridad
22. Audit de logging
23. Performance testing
24. Documentación exhaustiva
25. QA con equipo de seguridad
26. Penetration testing

**Criterios de Éxito**:
- ✅ Votaciones electrónicas OK
- ✅ Votaciones presenciales OK
- ✅ Integración nVotes funcionando
- ✅ Census management OK
- ✅ Security audit passed
- ✅ Tests pasando (25 specs)
- ✅ Performance acceptable
- ✅ Documentación completa

---

##### Engine 9: PLEBIS_MILITANT (Meses 15-16)

**Complejidad**: Media (acoplado a Collaborations)
**Modelos**: 1 (MilitantRecord)
**Controladores**: 1 (API externo)
**Tests**: 5 specs
**Dependencias**: User, Collaboration, External API (Participa)

**Plan Detallado**:

**Mes 1: Integración y lógica**
1. Crear engine
2. Mover MilitantRecord
3. Subscriber a eventos de Collaboration:
   ```ruby
   PlebisCore::EventBus.subscribe('collaboration.created') do |event|
     PlebisMilitant::StatusUpdater.call(event.payload[:user_id])
   end
   ```
4. Mover militant_controller.rb (API HMAC-authenticated)
5. Integración con Participa platform

**Mes 2: Tests y finalización**
6. Migrar 5 specs
7. Tests de integración con Collaborations (vía eventos)
8. Tests de API externo
9. Documentación
10. QA

**Criterios de Éxito**:
- ✅ Cálculo de status militante OK
- ✅ Eventos de Collaboration procesados
- ✅ API externo funcionando
- ✅ Tests pasando (5 specs)
- ✅ Documentación

---

##### GEMS STANDALONE (Paralelo a Fase 3)

###### Gem 1: PLEBIS_PAYMENTS

**Contenido**:
- Redsys payment processor
- SEPA XML generation
- Norma43 integration
- IBAN/BIC validators
- Order management logic (sin AR)

**Tests**: Suite propia con RSpec

**Uso**:
```ruby
# Gemfile
gem 'plebis_payments', path: 'gems/plebis_payments'

# En engine
class Order < ApplicationRecord
  include PlebisPayments::RedsysIntegration
  include PlebisPayments::SepaIntegration
end
```

---

###### Gem 2: PLEBIS_SMS

**Contenido**:
- SMS provider abstraction
- Esendex integration
- Phone validation
- SMS verification logic

**Tests**: Suite propia

**Uso**:
```ruby
gem 'plebis_sms', path: 'gems/plebis_sms'

# Configuration
PlebisSms.configure do |config|
  config.provider = :esendex
  config.account_reference = ENV['ESENDEX_ACCOUNT']
end

# Usage
PlebisSms.send_verification_code(phone_number, code)
```

---

###### Gem 3: PLEBIS_VALIDATORS

**Contenido**:
- Spanish VAT validators (NIF/NIE/CIF)
- IBAN validation
- CCC (Código Cuenta Cliente) validation
- Postal code validation
- Phone validation (Spanish formats)

**Tests**: Suite exhaustiva

**Uso**:
```ruby
gem 'plebis_validators', path: 'gems/plebis_validators'

class User < ApplicationRecord
  validates :document_vatid, spanish_vat: true
  validates :iban, iban: true
  validates :postal_code, spanish_postal_code: true
end
```

---

### 4.3 Checklist por Engine

Usar esta checklist para cada engine:

```markdown
## Engine: [NOMBRE]

### 1. Preparación
- [ ] Crear estructura con generator
- [ ] Configurar gemspec
- [ ] Configurar engine.rb
- [ ] README inicial

### 2. Migración de Código
- [ ] Mover modelos (namespace actualizado)
- [ ] Mover controladores
- [ ] Mover vistas
- [ ] Mover servicios
- [ ] Mover concerns
- [ ] Mover mailers
- [ ] Mover jobs

### 3. Configuración
- [ ] Routes.rb del engine
- [ ] Initializers necesarios
- [ ] Assets (JS/CSS si aplica)
- [ ] Locales (i18n)
- [ ] ActiveAdmin resources

### 4. Integración
- [ ] Registrar en EngineActivation
- [ ] Configurar carga dinámica
- [ ] Event subscribers (si aplica)
- [ ] API contracts documentados

### 5. Testing
- [ ] Migrar specs de modelo
- [ ] Migrar specs de controlador
- [ ] Migrar specs de request/integration
- [ ] Migrar factories
- [ ] Tests pasando al 100%
- [ ] Coverage > 80%

### 6. Documentación
- [ ] README.md completo
- [ ] API documentation
- [ ] Configuration guide
- [ ] Integration examples
- [ ] CHANGELOG.md

### 7. QA
- [ ] Code review
- [ ] Manual testing
- [ ] Performance check
- [ ] Security review
- [ ] Activación/desactivación verificada

### 8. Deployment
- [ ] Gemfile actualizado
- [ ] Migraciones (si aplica)
- [ ] Seeds (si aplica)
- [ ] Staging deployment
- [ ] Production deployment
```

---

## 5. PREPARACIÓN DEL CORE (DETALLADO)

Esta fase es crítica. Sin ella, la extracción de engines será caótica.

### 5.1 Refactorización del User Model

**Problema actual**: User tiene 15+ asociaciones directas a todos los dominios.

**Objetivo**: User con concerns por engine, cargados dinámicamente.

#### Paso 1: Auditar User Model

```bash
# Contar líneas
wc -l app/models/user.rb

# Analizar asociaciones
grep "has_many\|belongs_to\|has_one\|has_and_belongs_to_many" app/models/user.rb

# Analizar métodos
grep "def " app/models/user.rb
```

#### Paso 2: Crear Concerns Base

```ruby
# app/models/concerns/engine_user.rb
module EngineUser
  extend ActiveSupport::Concern

  # Interface común para todos los engines
  included do
    # Hooks disponibles para engines
  end

  class_methods do
    def register_engine_concern(engine_name, concern_module)
      include concern_module if EngineActivation.enabled?(engine_name)
    end
  end
end
```

#### Paso 3: Extraer Concerns por Dominio

```ruby
# app/models/concerns/engine_user/votable.rb
module EngineUser
  module Votable
    extend ActiveSupport::Concern

    included do
      has_many :votes, dependent: :destroy
      belongs_to :vote_circle, optional: true
    end

    def can_vote_in?(election)
      verified? && vote_circle.present?
    end
  end
end

# app/models/concerns/engine_user/collaborator.rb
module EngineUser
  module Collaborator
    extend ActiveSupport::Concern

    included do
      has_many :collaborations, dependent: :destroy
      has_many :orders, as: :parent
    end

    def active_collaborations
      collaborations.where(deleted_at: nil, status: 'active')
    end
  end
end

# ... similar para Verifiable, Microcreditor, ImpulsaAuthor, etc.
```

#### Paso 4: Refactorizar User

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include EngineUser # Base concern

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Soft delete
  acts_as_paranoid

  # Auditing
  has_paper_trail

  # CORE associations only
  belongs_to :vote_circle, optional: true

  # Engine concerns (loaded dynamically)
  register_engine_concern('plebis_voting', EngineUser::Votable)
  register_engine_concern('plebis_collaborations', EngineUser::Collaborator)
  register_engine_concern('plebis_verification', EngineUser::Verifiable)
  register_engine_concern('plebis_microcredit', EngineUser::Microcreditor)
  register_engine_concern('plebis_impulsa', EngineUser::ImpulsaAuthor)
  register_engine_concern('plebis_proposals', EngineUser::Proposer)
  register_engine_concern('plebis_participation', EngineUser::TeamMember)

  # Core validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true

  # Flags (usar bitfield en producción)
  def superadmin?
    flags & FLAG_SUPERADMIN > 0
  end

  def verified?
    flags & FLAG_VERIFIED > 0
  end

  # ... más flags

  # Core methods (no dependen de engines)
  def full_name
    "#{first_name} #{last_name}"
  end

  def to_s
    full_name
  end
end
```

#### Paso 5: Tests de User Refactorizado

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'core functionality' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    it 'returns full name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe 'engine concerns' do
    context 'when voting engine is enabled' do
      before { allow(EngineActivation).to receive(:enabled?).with('plebis_voting').and_return(true) }

      it { should have_many(:votes) }
      it { should belong_to(:vote_circle).optional }

      it 'responds to voting methods' do
        user = build(:user)
        expect(user).to respond_to(:can_vote_in?)
      end
    end

    context 'when voting engine is disabled' do
      before { allow(EngineActivation).to receive(:enabled?).with('plebis_voting').and_return(false) }

      it 'does not have votes association' do
        user = build(:user)
        expect(user).not_to respond_to(:votes)
      end
    end

    # Similar para otros engines
  end

  describe 'flags' do
    it 'checks superadmin flag' do
      user = build(:user, flags: User::FLAG_SUPERADMIN)
      expect(user.superadmin?).to be true
    end

    it 'checks verified flag' do
      user = build(:user, flags: User::FLAG_VERIFIED)
      expect(user.verified?).to be true
    end
  end
end
```

### 5.2 Implementar Sistema de Activación

Ya documentado en sección 3.4. Implementar en este orden:

1. Migración `create_engine_activations`
2. Modelo `EngineActivation`
3. ActiveAdmin resource
4. Cache layer
5. Tests de activación/desactivación

### 5.3 Crear Event Bus

```ruby
# spec/lib/plebis_core/event_bus_spec.rb
require 'rails_helper'

RSpec.describe PlebisCore::EventBus do
  describe '.publish' do
    it 'publishes event' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('plebis.test.event', { data: 'value' })

      PlebisCore::EventBus.publish('test.event', { data: 'value' })
    end
  end

  describe '.subscribe' do
    it 'subscribes to event' do
      received_payload = nil

      PlebisCore::EventBus.subscribe('test.event') do |event|
        received_payload = event.payload
      end

      PlebisCore::EventBus.publish('test.event', { foo: 'bar' })

      expect(received_payload).to eq({ foo: 'bar' })
    end
  end
end
```

### 5.4 Consolidar Tests a RSpec

**Estrategia**:

1. **Identificar Minitest tests**: 32 archivos en `test/`
2. **Migrar uno por uno**:
   ```ruby
   # De: test/models/user_test.rb
   require 'test_helper'

   class UserTest < ActiveSupport::TestCase
     test "should not save user without email" do
       user = User.new
       assert_not user.save
     end
   end

   # A: spec/models/user_spec.rb
   require 'rails_helper'

   RSpec.describe User, type: :model do
     it 'does not save without email' do
       user = User.new
       expect(user.save).to be false
       expect(user.errors[:email]).to be_present
     end
   end
   ```

3. **Fixtures → FactoryBot**:
   ```ruby
   # De: test/fixtures/users.yml
   john:
     email: john@example.com
     first_name: John

   # A: spec/factories/users.rb
   FactoryBot.define do
     factory :user do
       email { Faker::Internet.email }
       first_name { 'John' }
       password { 'password123' }
     end
   end
   ```

4. **Actualizar CI**:
   ```yaml
   # .github/workflows/test.yml
   - name: Run tests
     run: bundle exec rspec  # Era: rake test
   ```

5. **Eliminar Minitest**:
   ```bash
   rm -rf test/
   # Gemfile: eliminar minitest gems
   ```

### 5.5 Generator de Engines

```ruby
# lib/generators/plebis/engine/engine_generator.rb
module Plebis
  module Generators
    class EngineGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_engine_structure
        @module_name = name.camelize
        @engine_name = "plebis_#{name}"

        # Directorios
        empty_directory "engines/#{@engine_name}/app/controllers/#{@engine_name}"
        empty_directory "engines/#{@engine_name}/app/models/#{@engine_name}"
        empty_directory "engines/#{@engine_name}/app/views/#{@engine_name}"
        empty_directory "engines/#{@engine_name}/app/admin"
        empty_directory "engines/#{@engine_name}/config"
        empty_directory "engines/#{@engine_name}/db/migrate"
        empty_directory "engines/#{@engine_name}/lib/#{@engine_name}"
        empty_directory "engines/#{@engine_name}/spec/factories"
        empty_directory "engines/#{@engine_name}/spec/models"
        empty_directory "engines/#{@engine_name}/spec/controllers"

        # Archivos template
        template "engine.rb.tt", "engines/#{@engine_name}/lib/#{@engine_name}/engine.rb"
        template "lib.rb.tt", "engines/#{@engine_name}/lib/#{@engine_name}.rb"
        template "gemspec.tt", "engines/#{@engine_name}/#{@engine_name}.gemspec"
        template "routes.rb.tt", "engines/#{@engine_name}/config/routes.rb"
        template "README.md.tt", "engines/#{@engine_name}/README.md"
        template "spec_helper.rb.tt", "engines/#{@engine_name}/spec/spec_helper.rb"
      end

      def add_to_gemfile
        append_to_file "Gemfile", "\ngem '#{@engine_name}', path: 'engines/#{@engine_name}'\n"
      end

      def create_activation_record
        say "Engine created. Don't forget to:"
        say "1. Run: bundle install"
        say "2. Create activation record in admin: EngineActivation.create!(engine_name: '#{@engine_name}', enabled: false)"
        say "3. Implement your models, controllers, views"
        say "4. Write tests"
      end
    end
  end
end

# lib/generators/plebis/engine/templates/engine.rb.tt
module <%= @module_name %>
  class Engine < ::Rails::Engine
    isolate_namespace <%= @module_name %>

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer "<%= @engine_name %>.load_abilities" do
      config.to_prepare do
        if defined?(Ability)
          Ability.register_abilities(<%= @module_name %>::Ability) if defined?(<%= @module_name %>::Ability)
        end
      end
    end

    initializer "<%= @engine_name %>.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('<%= @engine_name %>')
        Rails.logger.info "[<%= @module_name %>] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end
  end
end

# Uso:
# rails generate plebis:engine cms
# rails generate plebis:engine voting
```

---

## 6. SISTEMA DE ACTIVACIÓN DESDE ADMIN (DETALLADO)

### 6.1 Interface de Usuario

#### ActiveAdmin Dashboard

```ruby
# app/admin/dashboard.rb
ActiveAdmin.register_page "Dashboard" do
  content title: "PlebisHub Admin" do
    columns do
      column do
        panel "Engines Activos" do
          table_for EngineActivation.where(enabled: true).order(:load_priority) do
            column :engine_name
            column :load_priority
            column "Status" do |ea|
              status_tag "Active", :ok
            end
            column "Actions" do |ea|
              link_to "Configure", edit_admin_engine_activation_path(ea), class: 'button'
            end
          end
        end
      end

      column do
        panel "Engines Disponibles" do
          table_for EngineActivation.where(enabled: false).order(:engine_name) do
            column :engine_name
            column :description
            column "Actions" do |ea|
              link_to "Enable", enable_admin_engine_activation_path(ea), method: :post, class: 'button'
            end
          end
        end
      end
    end

    panel "System Info" do
      attributes_table_for ApplicationRecord do
        row("Rails Version") { Rails.version }
        row("Ruby Version") { RUBY_VERSION }
        row("Active Engines") { EngineActivation.where(enabled: true).count }
        row("Total Engines") { EngineActivation.count }
      end
    end
  end
end
```

#### Formulario de Configuración

```ruby
# app/admin/engine_activations.rb (extendido)
ActiveAdmin.register EngineActivation do
  permit_params :engine_name, :enabled, :description, :configuration, :load_priority

  form do |f|
    f.semantic_errors

    f.inputs "Engine Details" do
      if f.object.new_record?
        f.input :engine_name, as: :select,
                collection: PlebisCore::EngineRegistry.available_engines,
                include_blank: false
      else
        f.input :engine_name, input_html: { disabled: true }
      end

      f.input :enabled, as: :boolean,
              hint: "Enable this engine to load it on next application reload"

      f.input :description, as: :text,
              hint: "Describe what this engine does"

      f.input :load_priority, as: :number,
              hint: "Lower numbers load first (default: 100)"
    end

    f.inputs "Configuration (JSON)", class: 'json-config' do
      f.input :configuration, as: :jsonb,
              hint: "Engine-specific configuration in JSON format"
    end

    f.actions do
      f.action :submit
      f.cancel_link
    end
  end

  show do
    attributes_table do
      row :id
      row :engine_name
      row :enabled do |ea|
        status_tag(ea.enabled ? "Active" : "Inactive", ea.enabled ? :ok : :warning)
      end
      row :description
      row :load_priority
      row :configuration do |ea|
        pre JSON.pretty_generate(ea.configuration)
      end
      row :created_at
      row :updated_at
    end

    panel "Engine Details" do
      engine_info = PlebisCore::EngineRegistry.info(resource.engine_name)

      attributes_table_for engine_info do
        row("Version") { engine_info[:version] }
        row("Models") { engine_info[:models].join(', ') }
        row("Controllers") { engine_info[:controllers].join(', ') }
        row("Routes") { engine_info[:routes_count] }
        row("Dependencies") { engine_info[:dependencies].join(', ') }
      end
    end

    active_admin_comments
  end
end
```

### 6.2 Engine Registry

```ruby
# lib/plebis_core/engine_registry.rb
module PlebisCore
  class EngineRegistry
    ENGINES = {
      'plebis_cms' => {
        name: 'Content Management',
        description: 'Blog posts, pages, and notifications',
        version: '1.0.0',
        models: %w[Post Category Page Notice],
        controllers: %w[BlogController PageController NoticeController],
        dependencies: ['User'],
        default_config: {
          wordpress_api_enabled: false,
          push_notifications_enabled: true
        }
      },
      'plebis_voting' => {
        name: 'Electronic Voting',
        description: 'Democratic voting system with electronic and paper ballots',
        version: '1.0.0',
        models: %w[Election Vote VoteCircle],
        controllers: %w[VoteController],
        dependencies: ['User', 'plebis_verification'],
        default_config: {
          nvotes_api_url: '',
          allow_paper_voting: true,
          sms_verification_required: true
        }
      },
      'plebis_impulsa' => {
        name: 'Impulsa Projects',
        description: 'Citizen project submission and evaluation platform',
        version: '1.0.0',
        models: %w[ImpulsaEdition ImpulsaProject],
        controllers: %w[ImpulsaController],
        dependencies: ['User'],
        default_config: {
          max_file_size_mb: 10,
          allowed_file_types: ['pdf', 'doc', 'docx'],
          evaluation_enabled: true
        }
      },
      # ... más engines
    }.freeze

    def self.available_engines
      ENGINES.keys
    end

    def self.info(engine_name)
      ENGINES[engine_name] || {}
    end

    def self.dependencies_for(engine_name)
      info(engine_name)[:dependencies] || []
    end

    def self.can_enable?(engine_name)
      deps = dependencies_for(engine_name)

      # Verificar que dependencias estén activas
      deps.all? do |dep|
        dep == 'User' || EngineActivation.enabled?(dep)
      end
    end

    def self.default_config(engine_name)
      info(engine_name)[:default_config] || {}
    end
  end
end
```

### 6.3 Validaciones y Seguridad

```ruby
# app/models/engine_activation.rb (extendido)
class EngineActivation < ApplicationRecord
  validates :engine_name, presence: true, uniqueness: true
  validate :engine_exists
  validate :dependencies_met, if: :enabled?

  before_save :merge_default_config
  after_commit :notify_change

  def engine_exists
    unless PlebisCore::EngineRegistry.available_engines.include?(engine_name)
      errors.add(:engine_name, "is not a valid engine")
    end
  end

  def dependencies_met
    return unless enabled?

    deps = PlebisCore::EngineRegistry.dependencies_for(engine_name)
    unmet = deps.reject do |dep|
      dep == 'User' || EngineActivation.enabled?(dep)
    end

    if unmet.any?
      errors.add(:enabled, "requires engines to be enabled first: #{unmet.join(', ')}")
    end
  end

  def merge_default_config
    defaults = PlebisCore::EngineRegistry.default_config(engine_name)
    self.configuration = defaults.merge(configuration || {})
  end

  def notify_change
    if previous_changes.key?('enabled')
      Rails.logger.info "[EngineActivation] #{engine_name} #{enabled? ? 'enabled' : 'disabled'}"

      # Broadcast a channels (ActionCable)
      ActionCable.server.broadcast(
        'engine_activations',
        { engine: engine_name, enabled: enabled?, timestamp: Time.current }
      )
    end
  end

  def self.seed_all
    PlebisCore::EngineRegistry.available_engines.each do |engine_name|
      find_or_create_by!(engine_name: engine_name) do |ea|
        info = PlebisCore::EngineRegistry.info(engine_name)
        ea.description = info[:description]
        ea.enabled = false # Disabled por defecto
      end
    end
  end
end
```

### 6.4 Semillas (Seeds)

```ruby
# db/seeds.rb
puts "Seeding EngineActivations..."
EngineActivation.seed_all

# Activar engines básicos
['plebis_cms', 'plebis_participation'].each do |engine|
  EngineActivation.find_by(engine_name: engine)&.update!(enabled: true)
  puts "  ✓ #{engine} enabled"
end

puts "EngineActivations seeded: #{EngineActivation.count} total"
```

### 6.5 Rake Tasks

```ruby
# lib/tasks/engines.rake
namespace :engines do
  desc "List all available engines"
  task list: :environment do
    puts "\nAvailable Engines:"
    puts "-" * 80

    EngineActivation.order(:engine_name).each do |ea|
      status = ea.enabled? ? "✓ ACTIVE" : "✗ inactive"
      puts sprintf("%-30s %s", ea.engine_name, status)
      puts "  #{ea.description}" if ea.description.present?
    end

    puts "-" * 80
    puts "Total: #{EngineActivation.count} engines"
  end

  desc "Enable an engine"
  task :enable, [:engine_name] => :environment do |t, args|
    engine_name = args[:engine_name]

    if EngineActivation.can_enable?(engine_name)
      EngineActivation.enable!(engine_name)
      puts "✓ Engine '#{engine_name}' enabled"
    else
      deps = PlebisCore::EngineRegistry.dependencies_for(engine_name)
      puts "✗ Cannot enable '#{engine_name}'. Missing dependencies: #{deps.join(', ')}"
    end
  end

  desc "Disable an engine"
  task :disable, [:engine_name] => :environment do |t, args|
    engine_name = args[:engine_name]
    EngineActivation.disable!(engine_name)
    puts "✓ Engine '#{engine_name}' disabled"
  end

  desc "Show engine info"
  task :info, [:engine_name] => :environment do |t, args|
    engine_name = args[:engine_name]
    info = PlebisCore::EngineRegistry.info(engine_name)

    puts "\nEngine: #{engine_name}"
    puts "-" * 80
    puts "Name:        #{info[:name]}"
    puts "Description: #{info[:description]}"
    puts "Version:     #{info[:version]}"
    puts "Models:      #{info[:models].join(', ')}"
    puts "Controllers: #{info[:controllers].join(', ')}"
    puts "Dependencies: #{info[:dependencies].join(', ')}"
    puts "-" * 80
  end

  desc "Verify engine dependencies"
  task verify: :environment do
    puts "\nVerifying Engine Dependencies:"
    puts "-" * 80

    EngineActivation.where(enabled: true).each do |ea|
      deps = PlebisCore::EngineRegistry.dependencies_for(ea.engine_name)
      missing = deps.reject { |d| d == 'User' || EngineActivation.enabled?(d) }

      if missing.any?
        puts "✗ #{ea.engine_name}: MISSING #{missing.join(', ')}"
      else
        puts "✓ #{ea.engine_name}: OK"
      end
    end

    puts "-" * 80
  end
end
```

---

## 7. CONSOLIDACIÓN A RSPEC

### 7.1 Análisis de Tests Minitest

```bash
# Listar todos los Minitest tests
find test/ -name "*_test.rb" -type f

# Output esperado (32 archivos):
test/controllers/...
test/models/...
test/integration/...
```

### 7.2 Estrategia de Migración

1. **Mapeo de convenciones**:

| Minitest | RSpec |
|----------|-------|
| `test "description"` | `it 'description'` |
| `assert x` | `expect(x).to be_truthy` |
| `assert_equal a, b` | `expect(b).to eq(a)` |
| `assert_not x` | `expect(x).to be_falsey` |
| `assert_nil x` | `expect(x).to be_nil` |
| `assert_raises(Error)` | `expect { }.to raise_error(Error)` |
| `setup` | `before(:each)` |
| `teardown` | `after(:each)` |

2. **Script de migración automática** (parcial):

```ruby
# lib/tasks/migrate_minitest.rake
namespace :test do
  desc "Migrate Minitest to RSpec"
  task :migrate_minitest do
    Dir.glob("test/**/*_test.rb").each do |test_file|
      puts "Migrating #{test_file}..."

      # Leer contenido
      content = File.read(test_file)

      # Transformaciones básicas
      content.gsub!(/require ['"]test_helper['"]/, "require 'rails_helper'")
      content.gsub!(/class (\w+) < ActiveSupport::TestCase/, 'RSpec.describe \1, type: :model do')
      content.gsub!(/class (\w+) < ActionDispatch::IntegrationTest/, 'RSpec.describe \1, type: :request do')
      content.gsub!(/test ['"](.+?)['"] do/, "it '\\1' do")
      content.gsub!(/assert_equal (.+?), (.+?)$/, 'expect(\2).to eq(\1)')
      content.gsub!(/assert (.+?)$/, 'expect(\1).to be_truthy')
      content.gsub!(/assert_not (.+?)$/, 'expect(\1).to be_falsey')
      content.gsub!(/assert_nil (.+?)$/, 'expect(\1).to be_nil')

      # Nuevo path
      spec_file = test_file.sub('test/', 'spec/').sub('_test.rb', '_spec.rb')
      FileUtils.mkdir_p(File.dirname(spec_file))

      # Escribir
      File.write(spec_file, content)
      puts "  ✓ Created #{spec_file}"
    end

    puts "\nMigration complete. Review and fix manually!"
  end
end
```

3. **Revisión manual**: El script no puede convertir todo. Revisar cada archivo.

4. **Migrar fixtures a FactoryBot**:

```ruby
# test/fixtures/users.yml
one:
  email: user1@example.com
  first_name: User
  last_name: One
  password_digest: <%= BCrypt::Password.create('password') %>

# →

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { 'User' }
    last_name { Faker::Name.last_name }
    password { 'password' }
  end
end
```

5. **Actualizar configuración**:

```ruby
# spec/rails_helper.rb (ya existente, asegurar que tiene)
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # Devise
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
end
```

6. **Eliminar Minitest**:

```ruby
# Gemfile (eliminar)
group :test do
  gem "minitest"
  gem "minitest-reporters"
end

# Ejecutar
rm -rf test/
bundle install
```

### 7.3 Verificación

```bash
# Ejecutar suite completa
bundle exec rspec

# Verificar coverage
open coverage/index.html

# Debe ser > 80% y pasar todos los tests
```

---

## 8. CHECKLIST GENERAL DE IMPLEMENTACIÓN

### 8.1 Fase 0: Preparación (2-3 semanas)

```markdown
- [ ] **Semana 1: User Model & Activación**
  - [ ] Auditar User model actual
  - [ ] Crear concerns EngineUser::*
  - [ ] Refactorizar User con concerns dinámicos
  - [ ] Tests de User refactorizado (100%)
  - [ ] Crear migración engine_activations
  - [ ] Implementar modelo EngineActivation
  - [ ] ActiveAdmin resource básico
  - [ ] Tests de activación

- [ ] **Semana 2: Event Bus & Registry**
  - [ ] Implementar PlebisCore::EventBus
  - [ ] Tests de EventBus
  - [ ] Implementar PlebisCore::EngineRegistry
  - [ ] Documentar engines disponibles
  - [ ] Dynamic route loading
  - [ ] Tests de integración

- [ ] **Semana 3: Tests & Generator**
  - [ ] Migrar 32 Minitest a RSpec
  - [ ] Verificar suite completa pasando
  - [ ] Shared test helpers
  - [ ] Generator de engines
  - [ ] Template de engine estándar
  - [ ] Documentación del proceso
  - [ ] Seed de EngineActivations
```

### 8.2 Fase 1: Engines Simples (2-3 meses)

```markdown
- [ ] **Engine: plebis_cms (Semanas 1-3)**
  - [ ] Crear estructura
  - [ ] Migrar 5 modelos
  - [ ] Migrar 3 controladores
  - [ ] Migrar vistas
  - [ ] ActiveAdmin resources
  - [ ] Migrar 23 tests
  - [ ] Integración WordPress API
  - [ ] Push notifications
  - [ ] Documentación
  - [ ] QA completo

- [ ] **Engine: plebis_participation (Semanas 4-5)**
  - [ ] Crear estructura
  - [ ] Migrar modelo ParticipationTeam
  - [ ] Migrar controlador
  - [ ] Migrar vistas
  - [ ] ActiveAdmin resource
  - [ ] Migrar 4 tests
  - [ ] Documentación
  - [ ] QA

- [ ] **Engine: plebis_proposals (Semanas 6-8)**
  - [ ] Crear estructura
  - [ ] Migrar 2 modelos
  - [ ] Migrar 2 controladores
  - [ ] Integración Reddit
  - [ ] Migrar vistas
  - [ ] ActiveAdmin resources
  - [ ] Migrar tests
  - [ ] Documentación
  - [ ] QA
```

### 8.3 Fase 2: Engines Medios (3-4 meses)

```markdown
- [ ] **Engine: plebis_impulsa (Semanas 9-14)**
  - [ ] Crear estructura
  - [ ] Migrar 6 modelos + concerns
  - [ ] Migrar wizard controller
  - [ ] Migrar vistas multi-paso
  - [ ] State machine config
  - [ ] File uploads
  - [ ] ActiveAdmin resources
  - [ ] Migrar 19 tests + 6 factories
  - [ ] Documentación
  - [ ] QA exhaustivo

- [ ] **Engine: plebis_verification (Semanas 15-20)**
  - [ ] Crear estructura
  - [ ] Migrar UserVerification
  - [ ] Migrar 4 servicios
  - [ ] SMS validation
  - [ ] Document verification
  - [ ] Reportes
  - [ ] ActiveAdmin resources
  - [ ] Migrar 15 tests
  - [ ] Documentación
  - [ ] QA

- [ ] **Engine: plebis_microcredit (Semanas 21-26)**
  - [ ] Crear estructura
  - [ ] Migrar 3 modelos
  - [ ] Migrar controlador
  - [ ] Loan renewal service
  - [ ] Brand configurations
  - [ ] Email templates
  - [ ] ActiveAdmin resources
  - [ ] Migrar 13 tests + 3 factories
  - [ ] Documentación
  - [ ] QA
```

### 8.4 Fase 3: Engines Complejos (6-9 meses)

```markdown
- [ ] **Gem: plebis_payments (Mes 7)**
  - [ ] Crear estructura gem
  - [ ] Extraer Redsys integration
  - [ ] Extraer SEPA generation
  - [ ] Norma43 parsing
  - [ ] IBAN/BIC validators
  - [ ] Suite de tests completa
  - [ ] Documentación API
  - [ ] Ejemplos de uso

- [ ] **Engine: plebis_collaborations (Meses 7-9)**
  - [ ] Crear estructura
  - [ ] Migrar Collaboration
  - [ ] Migrar Order (polymorphic)
  - [ ] Integración plebis_payments
  - [ ] Migrar controladores
  - [ ] Redsys callbacks
  - [ ] SEPA generation
  - [ ] Mailers
  - [ ] ActiveAdmin resources
  - [ ] Migrar 13 tests
  - [ ] Documentación
  - [ ] QA exhaustivo

- [ ] **Engine: plebis_voting (Meses 10-14)**
  - [ ] Documentación sistema actual
  - [ ] Análisis de seguridad
  - [ ] Crear estructura
  - [ ] Migrar 6 modelos
  - [ ] Refactorizar vote_controller
  - [ ] Extraer servicios
  - [ ] Census management
  - [ ] nVotes integration
  - [ ] SMS verification
  - [ ] Paper voting
  - [ ] ActiveAdmin resources
  - [ ] Migrar 25 tests + 7 factories
  - [ ] Security audit
  - [ ] Performance testing
  - [ ] Penetration testing
  - [ ] Documentación exhaustiva
  - [ ] QA crítico

- [ ] **Engine: plebis_militant (Meses 15-16)**
  - [ ] Crear estructura
  - [ ] Migrar MilitantRecord
  - [ ] Event subscribers (Collaboration)
  - [ ] API externo (Participa)
  - [ ] HMAC authentication
  - [ ] Migrar 5 tests
  - [ ] Documentación
  - [ ] QA

- [ ] **Gems Adicionales (Paralelo)**
  - [ ] plebis_sms
    - [ ] Abstracción providers
    - [ ] Esendex integration
    - [ ] Phone validation
    - [ ] Tests
  - [ ] plebis_validators
    - [ ] Spanish VAT
    - [ ] IBAN/CCC
    - [ ] Postal codes
    - [ ] Tests exhaustivos
```

### 8.5 Post-Migración

```markdown
- [ ] **Optimización**
  - [ ] Review performance
  - [ ] Optimize N+1 queries
  - [ ] Cache strategies
  - [ ] Background jobs optimization

- [ ] **Documentación Final**
  - [ ] Architecture overview
  - [ ] Engine integration guide
  - [ ] API documentation
  - [ ] Deployment guide
  - [ ] Troubleshooting guide

- [ ] **Training**
  - [ ] Team training sessions
  - [ ] Video tutorials
  - [ ] Best practices guide
  - [ ] Code review checklist

- [ ] **Monitoreo**
  - [ ] Setup error tracking (Sentry/Rollbar)
  - [ ] Performance monitoring (New Relic/Scout)
  - [ ] Log aggregation (Papertrail/Loggly)
  - [ ] Metrics dashboard

- [ ] **CI/CD**
  - [ ] Update CI pipelines
  - [ ] Engine-specific test runs
  - [ ] Parallel testing
  - [ ] Automated deployments

- [ ] **Future Considerations**
  - [ ] Microservices extraction plan
  - [ ] API Gateway setup
  - [ ] Service mesh evaluation
  - [ ] Event sourcing consideration
```

---

## 9. RIESGOS Y MITIGACIONES

### 9.1 Riesgos Técnicos

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Regresiones en core | Alto | Media | Suite de tests exhaustiva antes de cada engine |
| User model breaks | Crítico | Baja | Tests de integración continuos, rollback plan |
| Performance degradation | Alto | Media | Benchmarks antes/después, optimization passes |
| Database migrations fail | Crítico | Baja | Dry-run en staging, backups frecuentes |
| Engine dependencies circular | Alto | Media | Dependency graph monitoring, architecture reviews |
| ActiveAdmin conflicts | Medio | Alta | Namespace isolation, testing |
| Route conflicts | Medio | Alta | Careful routing, tests de integración |

### 9.2 Riesgos de Negocio

| Riesgo | Impacto | Probabilidad | Mitigación |
|--------|---------|--------------|------------|
| Downtime durante migración | Alto | Baja | Feature flags, incremental rollout |
| Loss of functionality | Crítico | Baja | Exhaustive QA, user acceptance testing |
| Team velocity decrease | Medio | Alta | Training, documentation, support |
| Cost overrun | Medio | Media | Iterative approach, stop-gates |

### 9.3 Plan de Rollback

Para cada engine:

1. **Mantener código legacy** hasta QA completo
2. **Feature flag** para activar/desactivar
3. **Database backups** antes de migraciones
4. **Documented rollback procedure**:
   ```ruby
   # En caso de problemas con un engine
   EngineActivation.disable!('plebis_voting')

   # Revertir migración si necesario
   rake db:rollback STEP=1

   # Restaurar código legacy
   git revert <commit-hash>

   # Deploy
   cap production deploy
   ```

---

## 10. MÉTRICAS DE ÉXITO

### 10.1 KPIs Técnicos

- **Test Coverage**: Mantener > 80% en core y cada engine
- **Build Time**: No incrementar > 20% respecto a monolito
- **Code Complexity**: Reducir complejidad ciclomática promedio en 30%
- **Lines of Code per File**: Reducir promedio de 200 → 100 LOC
- **Dependencies**: Grafo de dependencias claro y acíclico
- **Performance**: Response times no degradar > 10%

### 10.2 KPIs de Proceso

- **Deployment Frequency**: Aumentar de 1/semana → 2-3/semana
- **Lead Time**: Reducir tiempo de feature → production en 20%
- **Change Failure Rate**: Mantener < 5%
- **Time to Restore**: < 1 hora en caso de issues
- **Team Velocity**: Mantener o incrementar story points/sprint

### 10.3 Entregables por Fase

| Fase | Entregable | Criterio de Aceptación |
|------|-----------|------------------------|
| Fase 0 | Core preparado | Tests pasando, sistema de activación funcionando |
| Fase 1 | 3 engines simples | Activables desde admin, tests pasando, documentados |
| Fase 2 | 3 engines medios | Idem + integrations funcionando |
| Fase 3 | 3 engines complejos + gems | Idem + security audit passed |
| Post | Documentación final | Architecture docs, training materials |

---

## 11. CONCLUSIÓN

Esta guía proporciona un plan completo y detallado para transformar PlebisHub de un monolito Rails a una arquitectura modular basada en engines pluggables.

### 11.1 Resumen de la Estrategia

1. **Preparación sólida** (Fase 0): Sistema de activación + User refactorizado
2. **Extracción incremental**: De engines simples → complejos
3. **Testing continuo**: Suite pasando en cada paso
4. **Documentación paralela**: Cada engine documentado
5. **QA exhaustivo**: Especialmente para engines críticos

### 11.2 Próximos Pasos Inmediatos

1. ✅ **Revisar esta guía** con el equipo
2. ✅ **Aprobar el plan** y prioridades
3. ✅ **Asignar recursos** y equipo
4. ✅ **Crear proyecto** de seguimiento (Jira/GitHub Projects)
5. ✅ **Comenzar Fase 0**: Refactorización del core

### 11.3 Soporte y Actualizaciones

Esta guía es un documento vivo. Actualizar conforme:
- Se descubran nuevos desafíos
- Se refinen estimaciones
- Se completen fases
- Se aprendan lecciones

### 11.4 Contacto

Para dudas, consultas o feedback sobre esta guía:
- Documentación: `GUIA_MAESTRA_MODULARIZACION.md`
- Análisis arquitectónico: Ver sección 2
- Análisis de tests: `TEST_STRUCTURE_ANALYSIS.md`

---

**¡Buena suerte con la modularización de PlebisHub!**

---

## APÉNDICE A: COMANDOS ÚTILES

```bash
# Crear un nuevo engine
rails generate plebis:engine nombre

# Listar engines disponibles
rake engines:list

# Activar un engine
rake engines:enable[plebis_cms]

# Desactivar un engine
rake engines:disable[plebis_cms]

# Ver info de un engine
rake engines:info[plebis_cms]

# Verificar dependencias
rake engines:verify

# Ejecutar tests de un engine específico
bundle exec rspec engines/plebis_cms/spec

# Ejecutar tests de todos los engines
rake engines:test:all

# Benchmarking
rake benchmark:engines

# Generar documentación
rake doc:engines
```

## APÉNDICE B: ESTRUCTURA DE UN ENGINE COMPLETO

```
engines/plebis_cms/
├── app/
│   ├── admin/
│   │   └── plebis_cms/
│   │       ├── posts.rb
│   │       └── pages.rb
│   ├── controllers/
│   │   └── plebis_cms/
│   │       ├── application_controller.rb
│   │       ├── blog_controller.rb
│   │       └── page_controller.rb
│   ├── models/
│   │   └── plebis_cms/
│   │       ├── post.rb
│   │       ├── category.rb
│   │       └── page.rb
│   ├── views/
│   │   └── plebis_cms/
│   │       ├── blog/
│   │       └── page/
│   ├── mailers/
│   │   └── plebis_cms/
│   ├── services/
│   │   └── plebis_cms/
│   └── abilities/
│       └── plebis_cms/
│           └── ability.rb
├── config/
│   ├── routes.rb
│   └── initializers/
├── db/
│   └── migrate/
├── lib/
│   ├── plebis_cms.rb
│   ├── plebis_cms/
│   │   ├── engine.rb
│   │   └── version.rb
│   └── tasks/
│       └── plebis_cms_tasks.rake
├── spec/
│   ├── controllers/
│   ├── models/
│   ├── requests/
│   ├── factories/
│   ├── support/
│   ├── spec_helper.rb
│   └── rails_helper.rb
├── plebis_cms.gemspec
├── Gemfile
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## APÉNDICE C: RECURSOS Y REFERENCIAS

- **Rails Engines Guide**: https://guides.rubyonrails.org/engines.html
- **Modular Monoliths**: https://www.fullstackruby.dev/modular-rails/
- **Component-Based Rails**: https://cbra.info/
- **CanCanCan in Engines**: https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities-in-Engines
- **RSpec Best Practices**: https://rspec.info/documentation/
- **FactoryBot**: https://github.com/thoughtbot/factory_bot

---

**FIN DE LA GUÍA MAESTRA**
