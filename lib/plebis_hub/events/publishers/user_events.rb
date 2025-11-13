# frozen_string_literal: true

module PlebisHub
  module Events
    module Publishers
      # ================================================================
      # UserEvents - Publisher for user-related domain events
      # ================================================================
      # Emits events for user lifecycle using existing EventBus
      # ================================================================

      module UserEvents
        class << self
          def user_created(user)
            EventBus.instance.publish('user.created', user_payload(user))
          end

          def user_updated(user, changes = {})
            EventBus.instance.publish('user.updated', user_payload(user).merge(changes: changes))
          end

          def user_verified(user)
            EventBus.instance.publish('user.verified', user_payload(user))
          end

          def user_banned(user, reason:, banned_by:)
            EventBus.instance.publish('user.banned', user_payload(user).merge(
              reason: reason,
              banned_by_id: banned_by&.id
            ))
          end

          def user_unbanned(user, unbanned_by:)
            EventBus.instance.publish('user.unbanned', user_payload(user).merge(
              unbanned_by_id: unbanned_by&.id
            ))
          end

          def user_deleted(user)
            EventBus.instance.publish('user.deleted', user_payload(user))
          end

          def user_logged_in(user)
            EventBus.instance.publish('user.logged_in', user_payload(user))
          end

          def user_logged_out(user)
            EventBus.instance.publish('user.logged_out', user_payload(user))
          end

          def user_password_changed(user)
            EventBus.instance.publish('user.password_changed', user_payload(user))
          end

          def user_email_changed(user, old_email:)
            EventBus.instance.publish('user.email_changed', user_payload(user).merge(
              old_email: old_email,
              new_email: user.email
            ))
          end

          private

          def user_payload(user)
            {
              user_id: user.id,
              email: user.email,
              full_name: user.full_name,
              created_at: user.created_at,
              organization_id: user.organization_id
            }
          end
        end
      end
    end
  end
end
