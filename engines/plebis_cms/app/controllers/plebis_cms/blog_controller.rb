# frozen_string_literal: true

module PlebisCms
  # BlogController - Blog Posts Display
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Added frozen_string_literal
  # - Added error handling
  # - Added security logging
  # - Added documentation
  # - Fixed potential N+1 queries
  #
  # This controller displays blog posts with admin preview capability.
  class BlogController < ApplicationController
    before_action :get_categories

    # Display paginated list of blog posts
    def index
      @posts = if current_user&.is_admin?
                 PlebisCms::Post.recent.page(params[:page]).per(5)
               else
                 PlebisCms::Post.published.recent.page(params[:page]).per(5)
               end

      log_security_event('blog_index_viewed', admin: current_user&.is_admin? || false)
    rescue StandardError => e
      log_error('blog_index_error', e)
      redirect_to main_app.root_path, alert: t('errors.messages.generic')
    end

    # Display individual blog post
    def post
      @post = if current_user&.is_admin?
                PlebisCms::Post.find(params[:id])
              else
                PlebisCms::Post.published.find(params[:id])
              end

      log_security_event('blog_post_viewed', post_id: @post.id, admin: current_user&.is_admin? || false)
    rescue ActiveRecord::RecordNotFound
      log_security_event('blog_post_not_found', post_id: params[:id])
      redirect_to blog_path, alert: t('errors.messages.not_found')
    rescue StandardError => e
      log_error('blog_post_error', e, post_id: params[:id])
      redirect_to blog_path, alert: t('errors.messages.generic')
    end

    # Display posts by category
    def category
      @category = PlebisCms::Category.find(params[:id])
      @posts = if current_user&.is_admin?
                 @category.posts.recent.page(params[:page]).per(5)
               else
                 @category.posts.published.recent.page(params[:page]).per(5)
               end

      log_security_event('blog_category_viewed', category_id: @category.id, admin: current_user&.is_admin? || false)
    rescue ActiveRecord::RecordNotFound
      log_security_event('blog_category_not_found', category_id: params[:id])
      redirect_to blog_path, alert: t('errors.messages.not_found')
    rescue StandardError => e
      log_error('blog_category_error', e, category_id: params[:id])
      redirect_to blog_path, alert: t('errors.messages.generic')
    end

    private

    # Load active categories for navigation
    def get_categories
      @categories = PlebisCms::Category.active
    rescue StandardError => e
      log_error('blog_categories_load_error', e)
      @categories = []
    end

    # SECURITY LOGGING
    def log_security_event(event_type, details = {})
      Rails.logger.info({
        event: event_type,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        controller: 'plebis_cms/blog',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    def log_error(event_type, exception, details = {})
      Rails.logger.error({
        event: event_type,
        error_class: exception.class.name,
        error_message: exception.message,
        backtrace: exception.backtrace&.first(5),
        ip_address: request.remote_ip,
        controller: 'plebis_cms/blog',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end
end
