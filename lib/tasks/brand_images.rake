# frozen_string_literal: true

namespace :brand do
  desc 'Seed brand images from the organized folder structure'
  task seed_images: :environment do
    puts 'Seeding brand images...'

    # Get or create the default global BrandSetting
    default_theme = BrandSetting.find_or_create_by!(scope: 'global') do |bs|
      bs.name = 'Default Theme'
      bs.description = 'Default global theme for PlebisHub'
      bs.active = true
      bs.theme_id = 'plebisbrand'
    end

    puts "Using BrandSetting: #{default_theme.name} (ID: #{default_theme.id})"

    # Define all images to seed with their metadata
    brand_images = [
      # Logos
      { key: 'logo_main', name: 'Main Logo', category: 'logo', path: 'brand/logos/logo-main.png',
        alt_text: 'PlebisHub main logo', description: 'Primary logo used in header and branding' },
      { key: 'logo_white', name: 'White Logo', category: 'logo', path: 'brand/logos/logo-white.png',
        alt_text: 'PlebisHub white logo', description: 'White/inverted logo for dark backgrounds' },
      { key: 'logo_horizontal', name: 'Horizontal Logo', category: 'logo', path: 'brand/logos/logo-horizontal.svg',
        alt_text: 'PlebisHub horizontal logo', description: 'Horizontal SVG logo' },
      { key: 'logo_vertical', name: 'Vertical Logo', category: 'logo', path: 'brand/logos/logo-vertical.svg',
        alt_text: 'PlebisHub vertical logo', description: 'Vertical stacked logo' },
      { key: 'logo_mark', name: 'Logo Mark', category: 'logo', path: 'brand/logos/logo-mark.svg',
        alt_text: 'PlebisHub logo mark', description: 'Icon/mark only version of logo' },
      { key: 'logo_inverted', name: 'Inverted Logo', category: 'logo', path: 'brand/logos/logo-inverted.svg',
        alt_text: 'PlebisHub inverted logo', description: 'Inverted colors logo for dark themes' },
      { key: 'logo_monochrome', name: 'Monochrome Logo', category: 'logo', path: 'brand/logos/logo-monochrome.svg',
        alt_text: 'PlebisHub monochrome logo', description: 'Single color version of logo' },
      { key: 'logo_admin', name: 'Admin Logo', category: 'logo', path: 'brand/logos/admin-logo.png',
        alt_text: 'Admin panel logo', description: 'Logo displayed in admin panel header' },

      # Favicons
      { key: 'favicon', name: 'Favicon', category: 'favicon', path: 'brand/favicons/favicon.png',
        alt_text: 'Site favicon', description: 'Browser tab icon (32x32)' },

      # Social icons
      { key: 'social_facebook', name: 'Facebook Icon', category: 'social', path: 'brand/social/facebook.png',
        alt_text: 'Facebook', description: 'Facebook social media icon' },
      { key: 'social_twitter', name: 'Twitter Icon', category: 'social', path: 'brand/social/twitter.png',
        alt_text: 'Twitter', description: 'Twitter/X social media icon' },
      { key: 'social_youtube', name: 'YouTube Icon', category: 'social', path: 'brand/social/youtube.png',
        alt_text: 'YouTube', description: 'YouTube social media icon' },

      # Banners
      { key: 'banner_landing', name: 'Landing Banner', category: 'banner', path: 'brand/banners/landing.jpg',
        alt_text: 'Landing page banner', description: 'Main landing page hero image' },
      { key: 'banner_collaborations', name: 'Collaborations Banner', category: 'banner', path: 'brand/banners/collaborations.png',
        alt_text: 'Collaborations section banner', description: 'Banner for collaborations section' },
      { key: 'banner_microcredits', name: 'Microcredits Banner', category: 'banner', path: 'brand/banners/microcredits.jpg',
        alt_text: 'Microcredits section banner', description: 'Banner for microcredits section' },
      { key: 'banner_impulsa', name: 'Impulsa Banner', category: 'banner', path: 'brand/banners/impulsa-bar.png',
        alt_text: 'Impulsa program banner', description: 'Banner for Impulsa program' },
      { key: 'banner_people', name: 'People Banner', category: 'banner', path: 'brand/banners/people.jpg',
        alt_text: 'Community image', description: 'Image showing community/people' },

      # Icons
      { key: 'icon_vote_box', name: 'Vote Box Icon', category: 'icon', path: 'brand/icons/vote-box.png',
        alt_text: 'Vote box', description: 'Icon for voting/elections' },
      { key: 'icon_proposal_check', name: 'Proposal Check Icon', category: 'icon', path: 'brand/icons/proposal-check.png',
        alt_text: 'Proposal approved', description: 'Icon for approved proposals' },
      { key: 'icon_proposal_time', name: 'Proposal Time Icon', category: 'icon', path: 'brand/icons/proposal-time-left.png',
        alt_text: 'Time remaining', description: 'Icon showing time remaining on proposals' },
      { key: 'icon_ropes_purple', name: 'Ropes Purple Icon', category: 'icon', path: 'brand/icons/ropes-purple.png',
        alt_text: 'Community connections', description: 'Purple ropes/connection icon' },
      { key: 'icon_ropes_white', name: 'Ropes White Icon', category: 'icon', path: 'brand/icons/ropes-white.png',
        alt_text: 'Community connections', description: 'White ropes/connection icon' },
      { key: 'icon_author_default', name: 'Default Author', category: 'icon', path: 'brand/icons/author-default.png',
        alt_text: 'Default author avatar', description: 'Default avatar for users without photo' },

      # Backgrounds
      { key: 'bg_purple_overlay', name: 'Purple Overlay', category: 'background', path: 'brand/backgrounds/bg.purple-op80.png',
        alt_text: 'Purple overlay', description: 'Semi-transparent purple overlay background' },
      { key: 'bg_dark_overlay', name: 'Dark Overlay', category: 'background', path: 'brand/backgrounds/bg.333-op55.png',
        alt_text: 'Dark overlay', description: 'Semi-transparent dark overlay background' },

      # Misc
      { key: 'misc_qr_background', name: 'QR Background', category: 'misc', path: 'brand/misc/qr-background.jpg',
        alt_text: 'QR code background', description: 'Background image for QR codes' },
      { key: 'misc_proposal_example', name: 'Proposal Example', category: 'misc', path: 'brand/misc/proposal-example.jpg',
        alt_text: 'Example proposal', description: 'Example image for proposals' },
      { key: 'misc_no_photo', name: 'No Photo Placeholder', category: 'misc', path: 'brand/misc/no-photo-impulsa.png',
        alt_text: 'No photo available', description: 'Placeholder when no photo is available' }
    ]

    created_count = 0
    updated_count = 0
    skipped_count = 0

    brand_images.each do |img_data|
      # Check if image file exists
      full_path = Rails.root.join('app', 'assets', 'images', img_data[:path])

      unless File.exist?(full_path)
        puts "  [SKIP] #{img_data[:key]} - File not found: #{img_data[:path]}"
        skipped_count += 1
        next
      end

      # Find or initialize the brand image
      brand_image = BrandImage.find_or_initialize_by(
        key: img_data[:key],
        brand_setting_id: default_theme.id
      )

      is_new = brand_image.new_record?

      # Update attributes
      brand_image.assign_attributes(
        name: img_data[:name],
        category: img_data[:category],
        alt_text: img_data[:alt_text],
        description: img_data[:description],
        active: true
      )

      # Store the asset path in metadata for reference
      brand_image.metadata ||= {}
      brand_image.metadata['asset_path'] = img_data[:path]

      # Attach the image file if not already attached or if it's a new record
      if is_new || !brand_image.image.attached?
        content_type = case File.extname(full_path).downcase
                       when '.png' then 'image/png'
                       when '.jpg', '.jpeg' then 'image/jpeg'
                       when '.gif' then 'image/gif'
                       when '.svg' then 'image/svg+xml'
                       when '.webp' then 'image/webp'
                       when '.ico' then 'image/x-icon'
                       else 'application/octet-stream'
                       end

        # Use create_and_upload! to ensure file is actually stored
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(full_path),
          filename: File.basename(full_path),
          content_type: content_type
        )
        brand_image.image.attach(blob)
      end

      if brand_image.save
        if is_new
          puts "  [CREATE] #{img_data[:key]} - #{img_data[:name]}"
          created_count += 1
        else
          puts "  [UPDATE] #{img_data[:key]} - #{img_data[:name]}"
          updated_count += 1
        end
      else
        puts "  [ERROR] #{img_data[:key]} - #{brand_image.errors.full_messages.join(', ')}"
        skipped_count += 1
      end
    end

    puts ''
    puts '=' * 50
    puts "Brand images seeding complete!"
    puts "  Created: #{created_count}"
    puts "  Updated: #{updated_count}"
    puts "  Skipped: #{skipped_count}"
    puts "  Total BrandImage records: #{BrandImage.count}"
    puts '=' * 50
  end

  desc 'List all brand images'
  task list_images: :environment do
    puts 'Brand Images:'
    puts '-' * 80

    BrandImage.includes(:brand_setting).order(:category, :key).each do |img|
      status = img.active ? 'Active' : 'Inactive'
      attached = img.image.attached? ? 'Yes' : 'No'
      theme = img.brand_setting&.name || 'Global'

      puts "  #{img.key.ljust(25)} | #{img.category.ljust(12)} | #{status.ljust(8)} | Attached: #{attached} | Theme: #{theme}"
    end

    puts '-' * 80
    puts "Total: #{BrandImage.count} images"
  end

  desc 'Clear all brand images'
  task clear_images: :environment do
    count = BrandImage.count
    BrandImage.destroy_all
    puts "Cleared #{count} brand images"
  end
end
