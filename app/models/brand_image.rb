# frozen_string_literal: true

class BrandImage < ApplicationRecord
  # == Associations ==
  belongs_to :brand_setting, optional: true
  belongs_to :organization, optional: true
  has_one_attached :image

  # == Constants ==
  CATEGORIES = %w[logo favicon social banner icon background misc].freeze

  # Predefined image keys with their categories and recommended dimensions
  IMAGE_DEFINITIONS = {
    # Logos
    'logo_main' => { category: 'logo', name: 'Main Logo', description: 'Primary logo for header (light background)', recommended_size: '260x64' },
    'logo_dark' => { category: 'logo', name: 'Dark Mode Logo', description: 'Logo for dark backgrounds', recommended_size: '260x64' },
    'logo_white' => { category: 'logo', name: 'White Logo', description: 'White/inverted logo for footer', recommended_size: '260x64' },
    'logo_square' => { category: 'logo', name: 'Square Logo', description: 'Square logo/mark for avatars', recommended_size: '128x128' },
    'logo_admin' => { category: 'logo', name: 'Admin Logo', description: 'Logo for admin panel', recommended_size: '200x50' },

    # Favicon
    'favicon' => { category: 'favicon', name: 'Favicon', description: 'Browser tab icon', recommended_size: '32x32' },
    'favicon_large' => { category: 'favicon', name: 'Large Favicon', description: 'Large favicon for bookmarks', recommended_size: '180x180' },

    # Social Media Icons
    'social_facebook' => { category: 'social', name: 'Facebook Icon', description: 'Facebook social icon', recommended_size: '45x45' },
    'social_twitter' => { category: 'social', name: 'Twitter/X Icon', description: 'Twitter/X social icon', recommended_size: '45x45' },
    'social_instagram' => { category: 'social', name: 'Instagram Icon', description: 'Instagram social icon', recommended_size: '45x45' },
    'social_youtube' => { category: 'social', name: 'YouTube Icon', description: 'YouTube social icon', recommended_size: '45x45' },
    'social_telegram' => { category: 'social', name: 'Telegram Icon', description: 'Telegram social icon', recommended_size: '45x45' },
    'social_linkedin' => { category: 'social', name: 'LinkedIn Icon', description: 'LinkedIn social icon', recommended_size: '45x45' },

    # Banners
    'banner_home' => { category: 'banner', name: 'Home Banner', description: 'Main landing page banner', recommended_size: '1920x600' },
    'banner_collaborations' => { category: 'banner', name: 'Collaborations Banner', description: 'Collaborations page banner', recommended_size: '1200x400' },
    'banner_microcredits' => { category: 'banner', name: 'Microcredits Banner', description: 'Microcredits page banner', recommended_size: '1200x400' },

    # Menu Icons
    'icon_menu_hamburger' => { category: 'icon', name: 'Hamburger Menu', description: 'Mobile menu icon', recommended_size: '24x24' },
    'icon_menu_profile' => { category: 'icon', name: 'Profile Icon', description: 'User profile menu icon', recommended_size: '24x24' },
    'icon_menu_economics' => { category: 'icon', name: 'Economics Icon', description: 'Economics menu icon', recommended_size: '24x24' },
    'icon_menu_teams' => { category: 'icon', name: 'Teams Icon', description: 'Teams menu icon', recommended_size: '24x24' },
    'icon_menu_tools' => { category: 'icon', name: 'Tools Icon', description: 'Tools menu icon', recommended_size: '24x24' },
    'icon_menu_notifications' => { category: 'icon', name: 'Notifications Icon', description: 'Notifications menu icon', recommended_size: '24x24' },

    # Backgrounds
    'bg_header' => { category: 'background', name: 'Header Background', description: 'Header background pattern/image', recommended_size: '1920x200' },
    'bg_footer' => { category: 'background', name: 'Footer Background', description: 'Footer background pattern/image', recommended_size: '1920x400' },
    'bg_login' => { category: 'background', name: 'Login Background', description: 'Login page background', recommended_size: '1920x1080' }
  }.freeze

  # == Validations ==
  validates :name, presence: true
  validates :key, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :key, uniqueness: { scope: [:brand_setting_id, :organization_id] } # rubocop:disable Rails/UniqueValidationWithoutIndex

  validate :image_format_validation
  validate :image_size_validation

  # == Scopes ==
  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :by_key, ->(key) { where(key: key) }
  scope :global, -> { where(brand_setting_id: nil, organization_id: nil) }
  scope :for_brand_setting, ->(bs_id) { where(brand_setting_id: bs_id) }
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :ordered, -> { order(:category, :position, :name) }
  scope :logos, -> { by_category('logo') }
  scope :favicons, -> { by_category('favicon') }
  scope :social_icons, -> { by_category('social') }
  scope :banners, -> { by_category('banner') }
  scope :icons, -> { by_category('icon') }
  scope :backgrounds, -> { by_category('background') }

  # == Callbacks ==
  before_validation :set_defaults_from_key
  after_save :update_metadata_from_image

  # == Class Methods ==

  # Find the most specific image for a given key
  # Priority: brand_setting > organization > global
  def self.find_for(key, brand_setting: nil, organization: nil)
    # Try brand_setting specific first
    if brand_setting
      image = active.by_key(key).for_brand_setting(brand_setting.id).first
      return image if image&.image&.attached?
    end

    # Try organization specific
    if organization
      image = active.by_key(key).for_organization(organization.id).first
      return image if image&.image&.attached?
    end

    # Fall back to global
    active.by_key(key).global.first
  end

  # Get URL for a specific image key with fallback
  def self.url_for(key, brand_setting: nil, organization: nil, fallback: nil)
    image = find_for(key, brand_setting: brand_setting, organization: organization)
    if image&.image&.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image.image, only_path: true)
    else
      fallback
    end
  end

  # Create default image entries for a brand setting
  def self.create_defaults_for(brand_setting: nil, organization: nil)
    IMAGE_DEFINITIONS.each do |key, definition|
      attrs = {
        key: key,
        name: definition[:name],
        category: definition[:category],
        description: definition[:description],
        brand_setting: brand_setting,
        organization: organization
      }

      find_or_create_by!(attrs.slice(:key, :brand_setting_id, :organization_id)) do |img|
        img.assign_attributes(attrs)
      end
    end
  end

  # List all available image keys grouped by category
  def self.available_keys_by_category
    IMAGE_DEFINITIONS.group_by { |_k, v| v[:category] }.transform_values do |pairs|
      pairs.map { |k, v| { key: k, name: v[:name], description: v[:description], recommended_size: v[:recommended_size] } }
    end
  end

  # == Instance Methods ==

  def image_url
    return nil unless image.attached?

    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  def recommended_size
    IMAGE_DEFINITIONS.dig(key, :recommended_size)
  end

  def definition
    IMAGE_DEFINITIONS[key] || {}
  end

  def global?
    brand_setting_id.nil? && organization_id.nil?
  end

  private

  def set_defaults_from_key
    return unless key.present? && IMAGE_DEFINITIONS.key?(key)

    definition = IMAGE_DEFINITIONS[key]
    self.name ||= definition[:name]
    self.category ||= definition[:category]
    self.description ||= definition[:description]
  end

  def update_metadata_from_image
    return unless image.attached? && image.blob.present?

    new_metadata = {
      content_type: image.blob.content_type,
      byte_size: image.blob.byte_size,
      filename: image.blob.filename.to_s
    }

    # Try to get dimensions if it's an image
    if image.blob.content_type.start_with?('image/')
      begin
        image.blob.analyze unless image.blob.analyzed?
        if image.blob.metadata.present?
          new_metadata[:width] = image.blob.metadata['width']
          new_metadata[:height] = image.blob.metadata['height']
        end
      rescue StandardError => e
        Rails.logger.warn("Could not analyze image dimensions: #{e.message}")
      end
    end

    update_column(:metadata, metadata.merge(new_metadata)) if new_metadata != metadata # rubocop:disable Rails/SkipsModelValidations
  end

  def image_format_validation
    return unless image.attached?

    allowed_types = %w[image/png image/jpeg image/gif image/svg+xml image/webp image/x-icon image/vnd.microsoft.icon]
    return if allowed_types.include?(image.blob.content_type)

    errors.add(:image, 'must be a PNG, JPEG, GIF, SVG, WebP, or ICO file')
  end

  def image_size_validation
    return unless image.attached?

    max_size = 5.megabytes
    errors.add(:image, 'must be less than 5MB') if image.blob.byte_size > max_size
  end
end
