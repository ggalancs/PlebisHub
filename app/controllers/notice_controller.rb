# frozen_string_literal: true

# CRITICAL FIX: Added authentication requirement per TESTING_INVENTORY.md specification
class NoticeController < ApplicationController
  before_action :authenticate_user!

  def index
    # MEDIUM PRIORITY FIX: Added default page value and safe parameter handling
    # LOW PRIORITY FIX: Added scoping to show only sent and active notices
    page_number = params[:page].presence || 1
    @notices = Notice.sent.active.page(page_number)
  end
end
