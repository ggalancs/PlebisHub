# frozen_string_literal: true

module PlebisHub
  module Events
    module Publishers
      # ================================================================
      # UserEvents - Publisher for user-related domain events
      # ================================================================
      # Emits events for user lifecycle:
      # - user.created
      # - user.updated
      # - user.verified
      # - user.banned
      # - user.deleted
      # ================================================================

      module UserEvents
        extend ApplicationEvent

        # Register all user events
        register_event('user.created')
        register_event('user.updated')
        register_event('user.verified')
        register_event('user.banned')
        register_event('user.unbanned')
        register_event('user.deleted')
        register_event('user.logged_in')
        register_event('user.logged_out')
        register_event('user.password_changed')
        register_event('user.email_changed')

        class << self
          def user_created(user)
            publish_event('user.created', user_payload(user))
          end

          def user_updated(user, changes = {})
            publish_event('user.updated', user_payload(user).merge(changes: changes))
          end

          def user_verified(user)
            publish_event('user.verified', user_payload(user))
          end

          def user_banned(user, reason:, banned_by:)
            publish_event('user.banned', user_payload(user).merge(
              reason: reason,
              banned_by_id: banned_by&.id
            ))
          end

          def user_unbanned(user, unbanned_by:)
            publish_event('user.unbanned', user_payload(user).merge(
              unbanned_by_id: unbanned_by&.id
            ))
          end

          def user_deleted(user)
            publish_event('user.deleted', user_payload(user))
          end

          def user_logged_in(user)
            publish_event('user.logged_in', user_payload(user))
          end

          def user_logged_out(user)
            publish_event('user.logged_out', user_payload(user))
          end

          def user_password_changed(user)
            publish_event('user.password_changed', user_payload(user))
          end

          def user_email_changed(user, old_email:)
            publish_event('user.email_changed', user_payload(user).merge(
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
