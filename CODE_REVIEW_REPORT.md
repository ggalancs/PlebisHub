# 🔍 Code Review Report - PlebisHub 2.0 Phase 1

**Fecha de Revisión:** 2025-11-12
**Revisor:** Claude (Anthropic) - Expert Code Reviewer
**Código Revisado:** Phase 1 Foundation Implementation
**Severidad de Errores:** 🔴 CRÍTICO | 🟡 MODERADO | 🟢 MENOR

---

## 📊 Resumen Ejecutivo

**Total de Errores Encontrados: 23**
- 🔴 Críticos: 12
- 🟡 Moderados: 8
- 🟢 Menores: 3

**Estado General:** ❌ **NO PRODUCTION READY** - Requiere correcciones antes de deployment

---

## 🔴 ERRORES CRÍTICOS

### ERROR #1: User Model - Asociaciones Faltantes para Social Features
**Archivo:** `app/graphql/types/user_type.rb`
**Líneas:** 72-83

**Descripción del Error:**
```ruby
def followers_count
  object.followers.count  # ❌ Association 'followers' no existe
end

def following_count
  object.following.count  # ❌ Association 'following' no existe
end

def is_following
  context[:current_user].following?(object)  # ❌ Método no existe
end
```

**Causa:**
El modelo `User` no tiene las asociaciones `followers` y `following` definidas. La tabla `social_follows` existe en la migración pero las asociaciones no están en el modelo.

**Solución:**
Agregar al modelo `User`:
```ruby
# app/models/user.rb
has_many :follower_relationships,
         class_name: 'SocialFollow',
         foreign_key: :followee_id,
         dependent: :destroy

has_many :followers,
         through: :follower_relationships,
         source: :follower

has_many :following_relationships,
         class_name: 'SocialFollow',
         foreign_key: :follower_id,
         dependent: :destroy

has_many :following,
         through: :following_relationships,
         source: :followee

def following?(user)
  following.include?(user)
end

def follow!(user)
  following << user unless following?(user)
end

def unfollow!(user)
  following.delete(user)
end
```

Y crear el modelo `SocialFollow`:
```ruby
# app/models/social_follow.rb
class SocialFollow < ApplicationRecord
  self.table_name = 'social_follows'

  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followee_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:base, "Cannot follow yourself") if follower_id == followee_id
  end
end
```

---

### ERROR #2: User Model - Concern HasPermissions No Incluido
**Archivo:** `app/models/user.rb`
**Líneas:** 1-200

**Descripción del Error:**
El concern `HasPermissions` fue creado pero nunca se incluyó en el modelo `User`, por lo tanto los métodos `can?()`, `has_role?()`, etc. no están disponibles.

**Causa:**
Falta incluir el concern en el modelo User.

**Solución:**
Agregar al modelo `User` después de las otras inclusiones:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  # ... código existente ...

  # V2.0 features
  include Gamifiable
  include HasPermissions  # ✅ AGREGAR ESTA LÍNEA

  # ... resto del código ...
end
```

---

### ERROR #3: Proposal Model - Atributos y Asociaciones Incompatibles
**Archivo:** `app/graphql/types/proposal_type.rb`
**Líneas:** 9-59

**Descripción del Error:**
```ruby
field :body, String, null: true           # ❌ Proposal tiene 'description', no 'body'
field :category, String, null: true       # ❌ Atributo no existe
field :status, String, null: false        # ❌ Atributo no existe
field :author, Types::UserType            # ❌ Association 'author' no existe
field :votes, ...                         # ❌ Association 'votes' no existe (tiene 'supports')
field :comments, ...                      # ❌ Association 'comments' no existe
```

**Causa:**
El modelo `PlebisProposals::Proposal` tiene una estructura diferente:
- Usa `description` en lugar de `body`
- No tiene `category` ni `status`
- No tiene `author_id`, solo asociación implícita via `supports`
- Usa `supports` en lugar de `votes`
- No tiene asociación `comments`

**Solución:**
Opción 1 - Adaptar el GraphQL Type al modelo existente:
```ruby
# app/graphql/types/proposal_type.rb
field :body, String, null: true do
  description "Proposal description (mapped from 'description' field)"
end

def body
  object.description
end

field :supports_count, Integer, null: false
field :reddit_threshold, Boolean, null: false

# NO incluir: category, status, author, votes, comments hasta que el modelo los soporte
```

Opción 2 (RECOMENDADA) - Extender el modelo Proposal con migraciones:
```ruby
# db/migrate/XXXXXX_extend_proposals_for_v2.rb
class ExtendProposalsForV2 < ActiveRecord::Migration[7.2]
  def change
    add_column :proposals, :author_id, :bigint
    add_column :proposals, :category, :string
    add_column :proposals, :status, :string, default: 'draft'
    add_column :proposals, :body, :text
    add_column :proposals, :organization_id, :bigint

    add_index :proposals, :author_id
    add_index :proposals, :category
    add_index :proposals, :status
    add_index :proposals, :organization_id

    add_foreign_key :proposals, :users, column: :author_id
    add_foreign_key :proposals, :organizations, column: :organization_id
  end
end

# Luego extender el modelo:
# engines/plebis_proposals/app/models/plebis_proposals/proposal.rb
belongs_to :author, class_name: 'User', foreign_key: :author_id, optional: true
belongs_to :organization, optional: true
has_many :proposal_votes, class_name: 'ProposalVote', dependent: :destroy
has_many :comments, class_name: 'ProposalComment', dependent: :destroy

# Alias para compatibilidad
alias_attribute :body, :description
```

---

### ERROR #4: Vote Model - Conflicto de Nombres
**Archivo:** `app/graphql/types/vote_type.rb`, `app/models/vote.rb`

**Descripción del Error:**
El modelo `Vote` existente es para elections/agora voting, NO para votos en propuestas. El GraphQL API asume que hay un modelo `Vote` para propuestas con estructura diferente.

```ruby
# Vote existente (para elections)
belongs_to :election
has_attribute :voter_id

# Vote esperado (para proposals)
belongs_to :proposal  # ❌ No existe
has_attribute :option # ❌ No existe
```

**Causa:**
Conflicto de nombres entre dos conceptos diferentes de "voto".

**Solución:**
Crear un nuevo modelo `ProposalVote` separado:
```ruby
# app/models/proposal_vote.rb
class ProposalVote < ApplicationRecord
  self.table_name = 'proposal_votes'

  belongs_to :user
  belongs_to :proposal, class_name: 'PlebisProposals::Proposal'

  validates :user_id, uniqueness: { scope: :proposal_id }
  validates :option, presence: true, inclusion: { in: %w[yes no abstain] }

  # Publish events
  after_create { publish_event('vote.cast', vote_payload) }
  after_update { publish_event('vote.changed', vote_payload) }

  private

  def vote_payload
    { vote_id: id, user_id: user_id, proposal_id: proposal_id, option: option }
  end
end

# Migration
class CreateProposalVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :proposal_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :proposal, null: false, foreign_key: { to_table: :proposals }
      t.string :option, null: false
      t.text :comment

      t.timestamps

      t.index [:user_id, :proposal_id], unique: true
    end
  end
end
```

Actualizar GraphQL:
```ruby
# app/graphql/types/proposal_vote_type.rb (renombrar de vote_type.rb)
module Types
  class ProposalVoteType < Types::BaseObject
    description "A vote on a proposal"
    # ... rest of implementation
  end
end
```

---

### ERROR #5: Comment Model No Existe
**Archivo:** `app/graphql/types/comment_type.rb`, `app/graphql/types/proposal_type.rb`

**Descripción del Error:**
Se referencia un modelo `Comment` que no existe en la aplicación.

**Causa:**
El modelo nunca fue creado.

**Solución:**
Crear el modelo `ProposalComment`:
```ruby
# app/models/proposal_comment.rb
class ProposalComment < ApplicationRecord
  self.table_name = 'proposal_comments'

  belongs_to :proposal, class_name: 'PlebisProposals::Proposal'
  belongs_to :author, class_name: 'User'
  belongs_to :parent, class_name: 'ProposalComment', optional: true
  has_many :replies, class_name: 'ProposalComment', foreign_key: :parent_id

  validates :body, presence: true
  validates :author, presence: true
  validates :proposal, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :top_level, -> { where(parent_id: nil) }
end

# Migration
class CreateProposalComments < ActiveRecord::Migration[7.2]
  def change
    create_table :proposal_comments do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :proposals }
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :parent, foreign_key: { to_table: :proposal_comments }
      t.text :body, null: false
      t.boolean :flagged, default: false
      t.integer :upvotes_count, default: 0

      t.timestamps

      t.index [:proposal_id, :created_at]
    end
  end
end
```

---

### ERROR #6: User Model - Organization Association Missing
**Archivo:** `app/models/concerns/has_permissions.rb`, `app/graphql/types/user_type.rb`

**Descripción del Error:**
El código asume que `User` tiene `organization_id` y `belongs_to :organization`, pero el modelo usa `vote_circle_id` en su lugar.

**Causa:**
Diferencia entre arquitectura V1 (vote_circle) y V2 (organization).

**Solución:**
Opción 1 - Migrar de vote_circle a organization:
```ruby
# db/migrate/XXXXXX_migrate_vote_circles_to_organizations.rb
class MigrateVoteCirclesToOrganizations < ActiveRecord::Migration[7.2]
  def up
    # Renombrar columna
    rename_column :users, :vote_circle_id, :organization_id

    # Renombrar tabla
    rename_table :vote_circles, :organizations

    # Actualizar referencias
    # ... (código para actualizar foreign keys, etc.)
  end

  def down
    rename_column :users, :organization_id, :vote_circle_id
    rename_table :organizations, :vote_circles
  end
end
```

Opción 2 (TEMPORAL) - Alias para compatibilidad:
```ruby
# app/models/user.rb
belongs_to :vote_circle, optional: true
alias_attribute :organization_id, :vote_circle_id
alias_method :organization, :vote_circle
```

---

### ERROR #7: Event System - Conflicto con EventBus Existente
**Archivo:** `lib/plebis_hub/events/application_event.rb`

**Descripción del Error:**
Se creó un sistema de eventos usando `Dry::Events` pero ya existe un `EventBus` custom funcionando en `lib/event_bus.rb`. Hay duplicación y conflicto.

**Causa:**
No se revisó el código existente antes de crear el nuevo sistema.

**Solución:**
Usar el EventBus existente en lugar de crear uno nuevo:
```ruby
# Eliminar: lib/plebis_hub/events/application_event.rb (ya no se necesita)

# Usar EventBus existente en publishers:
# lib/plebis_hub/events/publishers/user_events.rb
module PlebisHub
  module Events
    module Publishers
      module UserEvents
        class << self
          def user_created(user)
            EventBus.instance.publish('user.created', user_payload(user))
          end

          # ... resto de métodos
        end
      end
    end
  end
end
```

---

### ERROR #8: HasPermissions - Método super_admin? No Existe
**Archivo:** `app/models/concerns/has_permissions.rb`
**Línea:** 105

**Descripción del Error:**
```ruby
def superadmin?
  has_role?('superadmin') || super_admin?  # ❌ Método 'super_admin?' no existe
end
```

**Causa:**
Se intentó hacer compatible con un método `super_admin?` que no existe. El User model tiene `superadmin?` (flag) pero no `super_admin?`.

**Solución:**
```ruby
# app/models/concerns/has_permissions.rb
def superadmin?
  has_role?('superadmin') || superadmin  # ✅ Usar flag directamente
end
```

---

### ERROR #9: GraphQL Schema - Falta Incluir Pundit en Controller
**Archivo:** `app/controllers/graphql_controller.rb`

**Descripción del Error:**
El controller GraphQL no incluye Pundit, pero las mutations intentan usar `authorize` y `policy`.

**Causa:**
Falta incluir Pundit::Authorization.

**Solución:**
```ruby
# app/controllers/graphql_controller.rb
class GraphqlController < ApplicationController
  include Pundit::Authorization  # ✅ AGREGAR

  skip_before_action :verify_authenticity_token

  # ... resto del código ...
end
```

---

### ERROR #10: Mutations - Método publish_event No Disponible
**Archivo:** `app/graphql/mutations/*.rb`

**Descripción del Error:**
Las mutations llaman a `publish_event()` pero ese método no está disponible en el contexto de BaseMutation.

**Causa:**
El método es una función global definida en `lib/event_bus.rb` pero no está incluida en las mutations.

**Solución:**
```ruby
# app/graphql/mutations/base_mutation.rb
class BaseMutation < GraphQL::Schema::RelayClassicMutation
  # ... código existente ...

  protected

  def publish_event(event_name, payload = {})
    EventBus.instance.publish(event_name, payload)
  end
end
```

---

### ERROR #11: Gamification - user_badges vs gamification_user_badges
**Archivo:** `app/graphql/types/user_type.rb`
**Línea:** 65

**Descripción del Error:**
```ruby
def badges
  object.user_badges.includes(:badge).map(&:badge)  # ❌ Debería ser gamification_user_badges
end
```

**Causa:**
El Gamifiable concern define `gamification_user_badges`, no `user_badges`.

**Solución:**
```ruby
# app/graphql/types/user_type.rb
def badges
  object.gamification_user_badges.includes(:badge).map(&:badge)
end

# O mejor aún, usar el método del concern:
def badges
  object.badges  # Ya está definido en Gamifiable concern
end
```

---

### ERROR #12: Missing GraphiQL Gem
**Archivo:** `config/routes.rb`
**Línea:** 52

**Descripción del Error:**
```ruby
mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
```

Pero la gema `graphiql-rails` no está en el Gemfile.

**Causa:**
Se olvidó agregar la dependencia.

**Solución:**
```ruby
# Gemfile
group :development, :staging do
  gem 'graphiql-rails'
end
```

---

## 🟡 ERRORES MODERADOS

### ERROR #13: Proposal Published Scope Missing
**Archivo:** `app/policies/proposal_policy.rb`
**Línea:** 57

**Descripción del Error:**
```ruby
scope.published  # ❌ Scope 'published' no existe en Proposal
```

**Causa:**
El modelo Proposal no tiene un scope `published`.

**Solución:**
```ruby
# engines/plebis_proposals/app/models/plebis_proposals/proposal.rb
scope :published, -> { where.not(published_at: nil) }

# O si no hay published_at:
scope :published, -> { where(status: 'published') }  # Requiere columna 'status'
```

---

### ERROR #14: Missing Notification Model
**Archivo:** `app/graphql/types/notification_type.rb`

**Descripción del Error:**
Se referencia un modelo `Notification` que probablemente no existe.

**Solución:**
Crear el modelo:
```ruby
# app/models/notification.rb
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :title, presence: true
  validates :notification_type, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def mark_as_read!
    update(read_at: Time.current)
  end
end
```

---

### ERROR #15: Missing Message/Conversation Models
**Archivos:** `app/graphql/types/message_type.rb`, `app/graphql/types/conversation_type.rb`

**Descripción del Error:**
Se referencian modelos `Messaging::Message` y `Messaging::Conversation` que necesitan ser creados.

**Solución:**
```ruby
# app/models/messaging/conversation.rb
module Messaging
  class Conversation < ApplicationRecord
    self.table_name = 'messaging_conversations'

    has_many :participants, class_name: 'Messaging::ConversationParticipant'
    has_many :users, through: :participants
    has_many :messages, class_name: 'Messaging::Message'
  end
end

# app/models/messaging/message.rb
module Messaging
  class Message < ApplicationRecord
    self.table_name = 'messaging_messages'

    belongs_to :conversation
    belongs_to :sender, class_name: 'User'
    has_many :message_reads, class_name: 'Messaging::MessageRead'
  end
end
```

---

### ERROR #16: BaseMutation context[:action] Undefined
**Archivo:** `app/graphql/mutations/base_mutation.rb`
**Línea:** 22

**Descripción del Error:**
```ruby
if record && !policy(record).send("#{context[:action]}?")
```

`context[:action]` nunca se define, causará error.

**Causa:**
Código copiado de ejemplo sin adaptar correctamente.

**Solución:**
```ruby
def authorize!(record = nil, action = nil)
  raise GraphQL::ExecutionError, "Authentication required" unless current_user

  if record
    action ||= infer_action  # Inferir acción del nombre de la mutation
    raise GraphQL::ExecutionError, "Not authorized" unless policy(record).send("#{action}?")
  end
end

private

def infer_action
  # CreateProposal -> :create
  # UpdateProposal -> :update
  # DeleteProposal -> :destroy
  self.class.name.demodulize.gsub(/Proposal|Vote|Comment/, '').underscore.to_sym
end
```

---

### ERROR #17: Missing Messaging Engine Models
**Archivo:** `app/graphql/mutations/send_message.rb`

**Descripción del Error:**
Se intenta usar `Messaging::Conversation` y `Messaging::Message` sin los modelos reales.

**Solución:**
Ver ERROR #15 o crear un engine PlebisMessaging completo.

---

### ERROR #18: Role.seed Methods - Missing Organization Parameter
**Archivo:** `app/models/role.rb`
**Líneas:** 85-180

**Descripción del Error:**
Los métodos `seed_*_role!` crean roles globales pero no validan que `organization_id` sea nil.

**Solución:**
```ruby
def self.seed_superadmin_role!
  role = find_or_create_by!(
    name: 'superadmin',
    scope: 'global',
    organization_id: nil  # ✅ Explícitamente nil
  ) do |r|
    r.description = 'Super Administrator - Full system access'
  end
  # ...
end
```

---

### ERROR #19: Permission ABAC Conditions - Context Building Issues
**Archivo:** `app/models/concerns/has_permissions.rb`
**Línea:** 155

**Descripción del Error:**
El método `build_permission_context` asume que `user.organization` existe pero puede ser nil.

**Solución:**
```ruby
def build_permission_context(resource, additional_context)
  {
    user: self,
    resource: resource,
    organization: organization  # Puede ser nil, está OK
  }.merge(additional_context)
end
```

---

### ERROR #20: GraphQL Subscription Implementation Incomplete
**Archivo:** `app/graphql/types/subscription_type.rb`

**Descripción del Error:**
Los subscription fields están definidos pero los métodos resolvers están vacíos.

**Causa:**
Stubs incompletos.

**Solución:**
Implementar correctamente o remover hasta que se implementen:
```ruby
# Opción 1: Remover subscriptions temporalmente
# Opción 2: Implementar con Action Cable
def proposal_updated(proposal_id:)
  # Triggered by:
  # PlebishubSchema.subscriptions.trigger('proposalUpdated', { id: proposal_id }, proposal)
end
```

---

## 🟢 ERRORES MENORES

### ERROR #21: EventStore - Tabla persisted_events vs events
**Archivo:** `lib/plebis_hub/events/event_store.rb`

**Descripción del Error:**
El modelo está configurado para usar `persisted_events` lo cual es correcto, pero hay referencias inconsistentes.

**Solución:**
Verificar que todas las referencias usen `persisted_events` consistentemente.

---

### ERROR #22: Missing require Statements
**Archivos:** Varios

**Descripción del Error:**
Algunos archivos referencian clases sin los `require` necesarios (aunque Rails autoload generalmente lo maneja).

**Solución:**
Asegurar que Rails autoload paths incluyen:
```ruby
# config/application.rb
config.autoload_paths += %W[
  #{config.root}/lib
  #{config.root}/lib/plebis_hub
]
```

---

### ERROR #23: GraphQL Schema - introspection_enabled? Method Position
**Archivo:** `app/graphql/plebishub_schema.rb`
**Línea:** 61

**Descripción del Error:**
`disable_introspection_entry_points` se llama condicionalmente pero puede causar problemas de configuración.

**Solución:**
```ruby
# Mejor práctica
if Rails.env.production? && ENV['GRAPHQL_INTROSPECTION'] != 'true'
  disable_introspection_entry_points
end
```

---

## 📋 Resumen de Correcciones Necesarias

### Prioridad ALTA (Antes de cualquier uso):
1. ✅ Crear modelos: `SocialFollow`, `ProposalVote`, `ProposalComment`
2. ✅ Agregar asociaciones sociales a `User` (followers/following)
3. ✅ Incluir `HasPermissions` concern en `User`
4. ✅ Corregir conflicto EventBus vs Dry::Events
5. ✅ Extender modelo `Proposal` con campos V2
6. ✅ Crear modelos `Messaging::*`
7. ✅ Agregar gem `graphiql-rails`

### Prioridad MEDIA (Antes de production):
8. ✅ Implementar scopes faltantes en Proposal
9. ✅ Corregir métodos de autorización en mutations
10. ✅ Implementar o remover subscriptions incompletas
11. ✅ Migrar de vote_circle a organization

### Prioridad BAJA (Mejoras):
12. ✅ Mejorar manejo de errores en GraphQL
13. ✅ Agregar tests unitarios
14. ✅ Documentar API con ejemplos

---

## 🎯 Conclusión

El código implementado tiene una **arquitectura sólida** pero requiere **correcciones críticas** antes de ser funcional. Los principales problemas son:

1. **Desconexión entre GraphQL API y modelos reales** - El API asume una estructura que no existe
2. **Modelos faltantes** - Vote, Comment, Social features no implementados
3. **Concerns no incluidos** - HasPermissions creado pero no usado
4. **Duplicación de event systems** - Conflicto entre Dry::Events y EventBus existente

**Recomendación:** Implementar las correcciones de Prioridad ALTA antes de continuar con Phase 2.

---

**Fin del Reporte**
**Próximo Paso Recomendado:** Implementar correcciones usando el plan detallado arriba
