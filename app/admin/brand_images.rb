# frozen_string_literal: true

ActiveAdmin.register BrandImage do
  menu parent: 'Branding', priority: 2, label: 'Brand Images'

  permit_params :name, :key, :category, :description, :alt_text,
                :brand_setting_id, :organization_id, :active, :position, :image

  # ========================================
  # INDEX
  # ========================================
  index do
    selectable_column
    id_column
    column :image do |brand_image|
      if brand_image.image.attached?
        begin
          image_tag url_for(brand_image.image), style: 'max-height: 40px; max-width: 80px; object-fit: contain;'
        rescue StandardError
          status_tag 'Error', class: 'error'
        end
      else
        status_tag 'No image', class: 'warning'
      end
    end
    column :name
    column :key do |bi|
      code bi.key
    end
    column :category do |bi|
      status_tag bi.category, class: category_tag_class(bi.category)
    end
    column :scope do |bi|
      if bi.brand_setting_id
        status_tag 'Theme', class: 'blue'
      elsif bi.organization_id
        status_tag 'Org', class: 'warning'
      else
        status_tag 'Global', class: 'yes'
      end
    end
    column :active do |bi|
      status_tag bi.active ? 'Yes' : 'No', class: bi.active ? 'yes' : 'no'
    end
    column 'Size' do |bi|
      if bi.metadata['width'] && bi.metadata['height']
        "#{bi.metadata['width']}x#{bi.metadata['height']}"
      elsif bi.metadata['byte_size']
        number_to_human_size(bi.metadata['byte_size'])
      else
        '-'
      end
    end
    column :position
    column :updated_at
    actions
  end

  # ========================================
  # FILTERS
  # ========================================
  filter :name
  filter :key, as: :select, collection: -> { BrandImage::IMAGE_DEFINITIONS.keys.sort }
  filter :category, as: :select, collection: BrandImage::CATEGORIES
  filter :brand_setting, collection: -> { BrandSetting.all.map { |bs| [bs.name, bs.id] } }
  filter :organization
  filter :active
  filter :created_at
  filter :updated_at

  # ========================================
  # SCOPES
  # ========================================
  scope :all, default: true
  scope :active
  scope :logos, -> { BrandImage.logos }
  scope :favicons, -> { BrandImage.favicons }
  scope :social_icons, -> { BrandImage.social_icons }
  scope :banners, -> { BrandImage.banners }
  scope :icons, -> { BrandImage.icons }
  scope :backgrounds, -> { BrandImage.backgrounds }
  scope :global, -> { BrandImage.global }

  # ========================================
  # SHOW
  # ========================================
  show do
    attributes_table do
      row :id
      row :name
      row :key do |bi|
        code bi.key
      end
      row :category do |bi|
        status_tag bi.category, class: category_tag_class(bi.category)
      end
      row :description
      row :alt_text
      row :brand_setting
      row :organization
      row :active do |bi|
        status_tag bi.active ? 'Active' : 'Inactive', class: bi.active ? 'yes' : 'no'
      end
      row :position
      row :recommended_size do |bi|
        bi.recommended_size || 'Not specified'
      end
      row :created_at
      row :updated_at
    end

    panel 'Image Preview' do
      if brand_image.image.attached?
        div class: 'image-preview-container', style: 'text-align: center; padding: 30px;' do
          # Light background preview
          div style: 'display: inline-block; margin: 20px;' do
            h4 'Light Background', style: 'margin-bottom: 10px; color: #555;'
            div style: 'background: #f5f5f5; padding: 30px; border-radius: 8px; display: inline-block; min-width: 200px;' do
              image_tag url_for(brand_image.image),
                        style: 'max-height: 150px; max-width: 300px;',
                        alt: brand_image.alt_text || brand_image.name
            end
          end

          # Dark background preview
          div style: 'display: inline-block; margin: 20px;' do
            h4 'Dark Background', style: 'margin-bottom: 10px; color: #555;'
            div style: 'background: #333; padding: 30px; border-radius: 8px; display: inline-block; min-width: 200px;' do
              image_tag url_for(brand_image.image),
                        style: 'max-height: 150px; max-width: 300px;',
                        alt: brand_image.alt_text || brand_image.name
            end
          end
        end
      else
        div class: 'no-image', style: 'text-align: center; padding: 40px; color: #999;' do
          para 'No image uploaded yet'
          para link_to('Upload Image', edit_admin_brand_image_path(brand_image), class: 'button')
        end
      end
    end

    panel 'Image Details' do
      if brand_image.image.attached?
        attributes_table_for brand_image do
          row 'Filename' do
            brand_image.image.filename
          end
          row 'Content Type' do
            brand_image.image.content_type
          end
          row 'File Size' do
            number_to_human_size(brand_image.image.byte_size)
          end
          row 'Dimensions' do
            if brand_image.metadata['width'] && brand_image.metadata['height']
              "#{brand_image.metadata['width']} x #{brand_image.metadata['height']} pixels"
            else
              'Not analyzed'
            end
          end
          row 'Direct URL' do
            url = url_for(brand_image.image)
            link_to url, url, target: '_blank', rel: 'noopener'
          end
        end
      else
        para 'No image details available', style: 'padding: 20px; color: #999;'
      end
    end

    panel 'Metadata' do
      pre JSON.pretty_generate(brand_image.metadata), style: 'background: #f5f5f5; padding: 15px; border-radius: 4px;'
    end

    active_admin_comments
  end

  # ========================================
  # FORM
  # ========================================
  form html: { multipart: true } do |f|
    f.semantic_errors

    f.inputs 'Image Selection' do
      f.input :key,
              as: :select,
              collection: BrandImage::IMAGE_DEFINITIONS.map { |k, v|
                ["#{v[:category].titleize}: #{v[:name]} (#{k})", k]
              }.sort,
              prompt: 'Select image type',
              hint: 'Select a predefined image type. This determines where the image is used.',
              input_html: { id: 'brand_image_key_select' }

      # Show recommended size based on selection
      text_node '<div id="recommended_size_info" style="margin: 10px 0 20px 20%; padding: 12px 15px; background: #e3f2fd; border-radius: 8px; display: none;">
        <strong>Recommended size:</strong> <span id="recommended_size_value"></span>
        <div style="color: #666; font-size: 12px; margin-top: 5px;" id="recommended_size_description"></div>
      </div>'.html_safe
    end

    f.inputs 'Basic Information' do
      f.input :name,
              hint: 'Display name for this image (auto-filled from key selection)'
      f.input :category,
              as: :select,
              collection: BrandImage::CATEGORIES,
              hint: 'Category is auto-filled based on key selection'
      f.input :description,
              as: :text,
              input_html: { rows: 2 },
              hint: 'Optional description of this image'
      f.input :alt_text,
              hint: 'Accessibility text for screen readers (important for logos and icons)'
    end

    f.inputs 'Scope' do
      f.input :brand_setting,
              as: :select,
              collection: BrandSetting.all.map { |bs| ["#{bs.name} (#{bs.scope})", bs.id] },
              include_blank: 'Global (no specific theme)',
              hint: 'Associate this image with a specific brand theme'
      f.input :organization,
              as: :select,
              collection: Organization.all.map { |o| [o.name, o.id] },
              include_blank: 'All organizations',
              hint: 'Associate this image with a specific organization'
    end

    f.inputs 'Upload Image' do
      if f.object.image.attached?
        div class: 'current-image', style: 'margin-bottom: 20px; padding: 15px; background: #f5f5f5; border-radius: 8px;' do
          div style: 'font-weight: 600; margin-bottom: 10px; color: #333;' do
            text_node 'Current Image:'
          end
          image_tag url_for(f.object.image), style: 'max-height: 100px; max-width: 200px;'
          div style: 'margin-top: 10px; font-size: 12px; color: #666;' do
            text_node "#{f.object.image.filename} (#{number_to_human_size(f.object.image.byte_size)})"
          end
        end
      end

      f.input :image,
              as: :file,
              hint: 'Accepted formats: PNG, JPEG, GIF, SVG, WebP, ICO. Max size: 5MB.'
    end

    f.inputs 'Settings' do
      f.input :active,
              hint: 'Only active images are used in the application'
      f.input :position,
              as: :number,
              hint: 'Order within category (lower numbers appear first)'
    end

    # JavaScript to auto-fill fields based on key selection
    text_node '<script type="text/javascript">
(function() {
  var definitions = ' + BrandImage::IMAGE_DEFINITIONS.to_json + ';

  function updateFieldsFromKey(key) {
    var def = definitions[key];
    if (!def) return;

    var nameField = document.getElementById("brand_image_name");
    var categoryField = document.getElementById("brand_image_category");
    var descField = document.getElementById("brand_image_description");
    var sizeInfo = document.getElementById("recommended_size_info");
    var sizeValue = document.getElementById("recommended_size_value");
    var sizeDesc = document.getElementById("recommended_size_description");

    if (nameField && !nameField.value) nameField.value = def.name;
    if (categoryField) categoryField.value = def.category;
    if (descField && !descField.value) descField.value = def.description || "";

    if (sizeInfo && sizeValue) {
      sizeValue.textContent = def.recommended_size || "Not specified";
      if (sizeDesc) sizeDesc.textContent = def.description || "";
      sizeInfo.style.display = "block";
    }
  }

  var keySelect = document.getElementById("brand_image_key_select");
  if (keySelect) {
    keySelect.addEventListener("change", function() {
      updateFieldsFromKey(this.value);
    });
    // Initial update if value is set
    if (keySelect.value) updateFieldsFromKey(keySelect.value);
  }
})();
</script>'.html_safe

    f.actions
  end

  # ========================================
  # CONTROLLER
  # ========================================
  controller do
    def create
      @brand_image = BrandImage.new(permitted_params[:brand_image])

      if @brand_image.save
        redirect_to admin_brand_image_path(@brand_image),
                    notice: 'Brand image created successfully!'
      else
        flash.now[:error] = @brand_image.errors.full_messages.join(', ')
        render :new
      end
    end

    def update
      @brand_image = BrandImage.find(params[:id])

      if @brand_image.update(permitted_params[:brand_image])
        redirect_to admin_brand_image_path(@brand_image),
                    notice: 'Brand image updated successfully!'
      else
        flash.now[:error] = @brand_image.errors.full_messages.join(', ')
        render :edit
      end
    end
  end

  # ========================================
  # COLLECTION ACTIONS
  # ========================================
  collection_action :create_defaults, method: :post do
    brand_setting_id = params[:brand_setting_id].presence
    organization_id = params[:organization_id].presence

    brand_setting = BrandSetting.find(brand_setting_id) if brand_setting_id
    organization = Organization.find(organization_id) if organization_id

    BrandImage.create_defaults_for(brand_setting: brand_setting, organization: organization)

    scope_name = brand_setting&.name || organization&.name || 'global'
    redirect_to admin_brand_images_path,
                notice: "Default image entries created for #{scope_name}!"
  end

  action_item :create_defaults, only: :index do
    link_to 'Create Default Entries',
            create_defaults_admin_brand_images_path,
            method: :post,
            data: { confirm: 'This will create placeholder entries for all predefined image types. Continue?' },
            class: 'button'
  end

  # ========================================
  # MEMBER ACTIONS
  # ========================================
  member_action :duplicate, method: :post do
    original = BrandImage.find(params[:id])
    duplicated = original.dup
    duplicated.name = "#{original.name} (Copy)"
    duplicated.active = false

    # Duplicate the image attachment if present
    if original.image.attached?
      duplicated.image.attach(original.image.blob)
    end

    if duplicated.save
      redirect_to admin_brand_image_path(duplicated),
                  notice: 'Brand image duplicated successfully!'
    else
      redirect_to admin_brand_images_path,
                  alert: "Failed to duplicate: #{duplicated.errors.full_messages.join(', ')}"
    end
  end

  action_item :duplicate, only: %i[show edit] do
    link_to 'Duplicate',
            duplicate_admin_brand_image_path(brand_image),
            method: :post,
            data: { confirm: 'Create a copy of this image?' },
            class: 'button'
  end

  member_action :remove_image, method: :delete do
    brand_image = BrandImage.find(params[:id])
    brand_image.image.purge if brand_image.image.attached?
    redirect_to admin_brand_image_path(brand_image),
                notice: 'Image removed successfully!'
  end

  action_item :remove_image, only: :show, if: -> { brand_image.image.attached? } do
    link_to 'Remove Image',
            remove_image_admin_brand_image_path(brand_image),
            method: :delete,
            data: { confirm: 'Are you sure you want to remove this image?' },
            class: 'button'
  end

  # ========================================
  # BATCH ACTIONS
  # ========================================
  batch_action :activate do |ids|
    batch_action_collection.find(ids).each { |bi| bi.update(active: true) }
    redirect_to collection_path, notice: "#{ids.count} images activated!"
  end

  batch_action :deactivate do |ids|
    batch_action_collection.find(ids).each { |bi| bi.update(active: false) }
    redirect_to collection_path, notice: "#{ids.count} images deactivated!"
  end

  # ========================================
  # HELPER METHODS
  # ========================================
  controller do
    helper_method :category_tag_class
  end
end

def category_tag_class(category)
  case category
  when 'logo' then 'blue'
  when 'favicon' then 'orange'
  when 'social' then 'purple'
  when 'banner' then 'green'
  when 'icon' then 'grey'
  when 'background' then 'teal'
  else 'default'
  end
end
