# frozen_string_literal: true

# ================================================================
# Current - Thread-safe storage for request context
# ================================================================
# Stores request-scoped data like current user, IP, user agent, etc.
# Used by event system to enrich event payloads with context
# ================================================================

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :ip, :user_agent, :request_id, :organization
end
