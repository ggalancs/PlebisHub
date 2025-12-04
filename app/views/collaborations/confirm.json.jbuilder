# frozen_string_literal: true

json.success true
json.message I18n.t('collaborations.create.success')
json.collaboration_id @collaboration.id
json.confirmation_url confirm_collaboration_url(force_single: @collaboration.frequency.zero?)
