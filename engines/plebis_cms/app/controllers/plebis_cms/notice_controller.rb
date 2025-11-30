# frozen_string_literal: true

module PlebisCms
  class NoticeController < ::ApplicationController
    before_action :authenticate_user!

    def index
      # MEDIUM PRIORITY FIX: Added default page value and safe parameter handling
      # LOW PRIORITY FIX: Added scoping to show only sent and active notices
      page_number = params[:page].presence || 1
      @notices = PlebisCms::Notice.sent.active.page(page_number)
    end
  end
end
