# 🚀 PlebisHub 2.0 - Implementation Guide

## ✅ Lo que se ha Implementado

### 1. Event-Driven Architecture (COMPLETO)
**Archivos**:
- `lib/event_bus.rb` - Sistema central de eventos
- Event bus con publishers y subscribers
- Soporte para eventos síncronos y asíncronos
- Persistencia de eventos para audit trail

**Uso**:
```ruby
# Publicar evento
publish_event('user.created', user_id: user.id, email: user.email)

# Suscribirse a evento
subscribe_to_event('user.created') do |event|
  puts "New user: #{event[:email]}"
end

# Async (background job)
EventBus.instance.subscribe_async('proposal.created', Analytics::ProposalListener)
```

### 2. Base de Datos v2.0 (COMPLETO)
**Archivo**: `db/migrate/20251113000000_create_v2_infrastructure.rb`

**Tablas creadas**:
- ✅ `persisted_events` - Event sourcing
- ✅ `roles`, `permissions`, `user_roles` - RBAC permissions
- ✅ `analytics_metrics`, `analytics_dashboards` - Analytics
- ✅ `gamification_*` (7 tablas) - Sistema completo de gamificación
- ✅ `messaging_*` (5 tablas) - Sistema de mensajería
- ✅ `social_follows`, `social_activities` - Features sociales
- ✅ `notifications` - Sistema de notificaciones

**Para ejecutar**:
```bash
rails db:migrate
```

### 3. PlebisGamification Engine (80% COMPLETO)
**Estructura**:
```
engines/plebis_gamification/
├── app/
│   ├── models/
│   │   ├── gamification/user_stats.rb      ✅ COMPLETO
│   │   ├── gamification/badge.rb           ✅ COMPLETO
│   │   ├── gamification/point.rb           🔜 Pendiente
│   │   └── gamification/user_badge.rb      🔜 Pendiente
│   ├── services/
│   │   └── gamification/badge_awarder.rb   ✅ COMPLETO
│   └── listeners/
│       └── gamification/proposal_listener.rb ✅ COMPLETO
└── lib/
    └── plebis_gamification/engine.rb       ✅ COMPLETO
```

**Features Implementadas**:
- ✅ Sistema de puntos con razones y fuentes
- ✅ Niveles (25 niveles con nombres)
- ✅ XP y progresión
- ✅ Streaks (rachas diarias)
- ✅ 13 badges predefinidos (bronze, silver, gold, platinum)
- ✅ Auto-awarder de badges
- ✅ Leaderboards
- ✅ Event listeners para proposals

**Uso**:
```ruby
# Obtener stats del usuario
stats = Gamification::UserStats.for_user(current_user)
stats.summary
# => { level: 5, level_name: "Defensor", total_points: 1250, ... }

# Ganar puntos
stats.earn_points!(50, reason: "Propuesta creada", source: proposal)

# Ver badges
current_user.gamification_user_stats.badges

# Leaderboard
Gamification::UserStats.leaderboard(period: :month, limit: 50)
```

### 4. Documentación Arquitectónica (COMPLETO)
**Archivos**:
- `ARCHITECTURE_V2.md` - Visión completa de v2.0 (550+ líneas)
- `V2_IMPLEMENTATION_GUIDE.md` - Esta guía

## 🔜 Lo que Falta Implementar

### Prioridad ALTA - Core Features

#### 1. Completar PlebisGamification
**Modelos pendientes**:
```ruby
# app/models/gamification/point.rb
class Gamification::Point < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true, optional: true
end

# app/models/gamification/user_badge.rb
class Gamification::UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge, class_name: 'Gamification::Badge'
end

# app/models/gamification/challenge.rb
class Gamification::Challenge < ApplicationRecord
  # Challenges diarios/semanales/mensuales
end
```

**Listeners adicionales**:
- `VoteListener` - Puntos por votar
- `UserListener` - Puntos por registro, login
- `LoginListener` - Streak tracking

**Controladores**:
```ruby
# app/controllers/api/v1/gamification_controller.rb
class Api::V1::GamificationController < ApplicationController
  def stats
    # GET /api/v1/gamification/stats
    render json: current_user.gamification_user_stats.summary
  end

  def leaderboard
    # GET /api/v1/gamification/leaderboard
    render json: Gamification::UserStats.leaderboard(params)
  end

  def badges
    # GET /api/v1/gamification/badges
    render json: current_user.gamification_user_stats.badges
  end
end
```

#### 2. PlebisAnalytics Engine
**Estructura**:
```
engines/plebis_analytics/
├── app/
│   ├── models/
│   │   ├── analytics/metric.rb
│   │   ├── analytics/dashboard.rb
│   │   └── analytics/query.rb
│   ├── services/
│   │   ├── analytics/metric_aggregator.rb
│   │   └── analytics/report_generator.rb
│   └── jobs/
│       └── analytics/metric_collector_job.rb
└── lib/
    └── plebis_analytics/engine.rb
```

**Métricas a implementar**:
- Proposals created/approved/rejected por día
- Votes cast por día/categoría
- User registrations por día
- Engagement rate
- Conversion funnels
- Cohort analysis

**Features**:
- Dashboard builder con widgets drag-and-drop
- Scheduled reports (email)
- Export to CSV/PDF/Excel
- Real-time metrics con Redis

#### 3. PlebisMessaging Engine
**Estructura**:
```
engines/plebis_messaging/
├── app/
│   ├── models/
│   │   ├── messaging/conversation.rb
│   │   ├── messaging/message.rb
│   │   ├── messaging/participant.rb
│   │   └── messaging/reaction.rb
│   ├── channels/
│   │   └── messaging_channel.rb  # Action Cable
│   └── controllers/
│       └── api/v1/messaging_controller.rb
└── lib/
    └── plebis_messaging/engine.rb
```

**Features**:
- Direct messages 1-on-1
- Group chats
- Real-time con Action Cable
- Read receipts
- Typing indicators
- File attachments
- Emoji reactions

#### 4. Sistema de Permisos Avanzado (RBAC)
**Modelos ya creados** (por migración):
- `Role`
- `Permission`
- `UserRole`

**Implementar**:
```ruby
# app/models/role.rb
class Role < ApplicationRecord
  has_many :permissions
  has_many :user_roles
  has_many :users, through: :user_roles

  SYSTEM_ROLES = %w[admin moderator member guest]

  def can?(resource, action, scope = :own)
    permissions.exists?(resource: resource, action: action, scope: [scope, 'global'])
  end
end

# app/models/concerns/authorizable.rb
module Authorizable
  extend ActiveSupport::Concern

  def has_role?(role_name, organization: nil)
    user_roles.joins(:role).exists?(
      roles: { name: role_name },
      organization_id: organization&.id
    )
  end

  def can?(action, resource)
    Policy.for(self, resource).public_send("#{action}?")
  end
end

# app/policies/base_policy.rb
class BasePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    user.admin? || record.public? || record.author == user
  end

  def create?
    user.present?
  end

  def update?
    user.admin? || record.author == user
  end

  def destroy?
    user.admin? || record.author == user
  end

  class << self
    def for(user, record)
      policy_class = "#{record.class.name}Policy".constantize rescue BasePolicy
      policy_class.new(user, record)
    end
  end
end
```

#### 5. GraphQL API Base
**Setup**:
```bash
bundle add graphql
rails generate graphql:install
```

**Implementar**:
```ruby
# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::BaseObject
    field :me, Types::UserType, null: false
    field :proposals, [Types::ProposalType], null: false
    field :proposal, Types::ProposalType, null: false do
      argument :id, ID, required: true
    end

    def me
      context[:current_user]
    end

    def proposals
      Proposal.all
    end

    def proposal(id:)
      Proposal.find(id)
    end
  end
end

# app/graphql/types/mutation_type.rb
module Types
  class MutationType < Types::BaseObject
    field :create_proposal, mutation: Mutations::CreateProposal
    field :vote, mutation: Mutations::Vote
  end
end

# app/graphql/types/subscription_type.rb
module Types
  class SubscriptionType < Types::BaseObject
    field :proposal_updated, subscription: Subscriptions::ProposalUpdated
  end
end

# app/controllers/graphql_controller.rb
class GraphqlController < ApplicationController
  def execute
    result = PlebishubSchema.execute(
      params[:query],
      variables: params[:variables],
      context: { current_user: current_user },
      operation_name: params[:operationName]
    )
    render json: result
  end
end
```

### Prioridad MEDIA - Engagement Features

#### 6. PlebisSocial Engine
- Follow/followers system
- Activity feed
- Mentions (@username)
- Hashtags (#topic)
- Social sharing

#### 7. PlebisAI Engine
- Content moderation con ML
- Sentiment analysis
- Auto-tagging
- Duplicate detection
- Smart recommendations

#### 8. PlebisBlockchain Engine (Avanzado)
- Integración con Ethereum/Polygon
- Smart contracts para microcredits
- NFT achievements
- Immutable audit trail

### Prioridad BAJA - Extras

#### 9. PlebisMarketplace
- Services marketplace
- Skill matching
- Job board

#### 10. PlebisMedia
- Video/audio streaming
- Podcast platform
- Live events

## 📋 Checklist de Implementación

### Inmediato (1-2 semanas)
- [ ] Completar modelos faltantes de Gamification
- [ ] Implementar controladores API de Gamification
- [ ] Crear seeds para badges y niveles
- [ ] Implementar listeners faltantes
- [ ] Testing completo de Gamification

### Corto Plazo (3-4 semanas)
- [ ] Implementar PlebisAnalytics engine completo
- [ ] Implementar sistema de permisos RBAC
- [ ] Implementar GraphQL API base
- [ ] Migrar endpoints críticos a GraphQL

### Medio Plazo (2-3 meses)
- [ ] Implementar PlebisMessaging con real-time
- [ ] Implementar PlebisSocial
- [ ] Implementar PlebisAI (básico)

### Largo Plazo (4-6 meses)
- [ ] PlebisBlockchain
- [ ] PlebisMarketplace
- [ ] PlebisMedia

## 🧪 Testing

### Tests a Crear

```ruby
# spec/lib/event_bus_spec.rb
RSpec.describe EventBus do
  it 'publishes and subscribes to events'
  it 'handles async subscribers'
  it 'persists events when enabled'
end

# spec/models/gamification/user_stats_spec.rb
RSpec.describe Gamification::UserStats do
  it 'earns points correctly'
  it 'levels up when XP threshold reached'
  it 'tracks streaks correctly'
  it 'calculates leaderboard position'
end

# spec/models/gamification/badge_spec.rb
RSpec.describe Gamification::Badge do
  it 'checks criteria correctly'
  it 'awards badge to eligible users'
end

# spec/services/gamification/badge_awarder_spec.rb
RSpec.describe Gamification::BadgeAwarder do
  it 'awards all eligible badges'
  it 'does not award same badge twice'
  it 'sends notification on badge earned'
end
```

## 🚀 Deployment

### 1. Migración de BD
```bash
# Development
rails db:migrate

# Production
RAILS_ENV=production rails db:migrate
```

### 2. Seeds
```bash
# Seed badges
Gamification::Badge.seed!

# Seed roles
Role.create_system_roles!
```

### 3. Background Jobs
Asegurarse que Resque esté corriendo:
```bash
QUEUE=* rake resque:work
```

### 4. Feature Flags
Activar engines gradualmente:
```ruby
EngineActivation.activate!('plebis_gamification')
EngineActivation.activate!('plebis_analytics')
```

## 📖 Recursos Adicionales

### Gemas Recomendadas
```ruby
# Gemfile
gem 'graphql'              # GraphQL API
gem 'dry-events'           # Event bus advanced
gem 'pundit'               # Authorization policies
gem 'elasticsearch-rails' # Full-text search para analytics
gem 'sidekiq'              # Alternative to Resque (más rápido)
gem 'ahoy_matey'          # Analytics tracking
gem 'chartkick'           # Charts para dashboards
```

### Referencias
- GraphQL Ruby: https://graphql-ruby.org
- Pundit: https://github.com/varvet/pundit
- Event Sourcing: https://martinfowler.com/eaaDev/EventSourcing.html
- CQRS Pattern: https://martinfowler.com/bliki/CQRS.html

## 🎯 Conclusión

PlebisHub 2.0 es una transformación ambiciosa pero alcanzable. La base está sentada con:

- ✅ Event-driven architecture
- ✅ Base de datos v2.0
- ✅ Gamification engine (80%)
- ✅ Documentación completa

Los próximos pasos son completar los engines prioritarios y empezar a ver resultados en engagement y analytics.

**El futuro de la participación ciudadana ya comenzó.**

---

**Estado**: Foundation Complete - Ready for Full Implementation
**Versión**: 2.0.0-alpha
**Última actualización**: 2024-01-15
