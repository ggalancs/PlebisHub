# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Theme Customization', class: 'theme-panel' do
          active_setting = BrandSetting.find_by(active: true, scope: 'global')
          if active_setting
            div style: 'display: flex; align-items: center; gap: 20px; margin-bottom: 15px;' do
              # Color preview
              colors = active_setting.theme_colors
              div style: 'display: flex; gap: 8px;' do
                div style: "width: 40px; height: 40px; border-radius: 8px; background: #{colors[:primary]}; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
                div style: "width: 40px; height: 40px; border-radius: 8px; background: #{colors[:secondary]}; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
              end
              div do
                div active_setting.name, style: 'font-weight: 600; font-size: 14px;'
                div "Theme: #{active_setting.theme_name || active_setting.theme_id || 'Custom'}", style: 'color: #666; font-size: 12px;'
              end
            end
            div style: 'display: flex; gap: 10px;' do
              span do
                link_to 'Edit Theme', edit_admin_brand_setting_path(active_setting), class: 'button'
              end
              span do
                link_to 'Preview', preview_admin_brand_setting_path(active_setting), class: 'button', target: '_blank', rel: 'noopener'
              end
              span do
                link_to 'All Themes', admin_brand_settings_path, class: 'button'
              end
            end
          else
            para 'No active theme configured.', style: 'color: #666;'
            div do
              link_to 'Create Theme', new_admin_brand_setting_path, class: 'button'
            end
          end
        end
      end
    end

    columns do
      column do
        panel 'Información importante' do
          div 'Condiciones de uso y aviso legal'
          div 'Manual de uso de la aplicación'
          div do
            link_to 'Manual de uso de datos de carácter personal',
                    '/pdf/PLEBISBRAND_LOPD_-_MANUAL_DE_USUARIO_DE_BASES_DE_DATOS_DE_PLEBISBRAND_v.2014.09.10.pdf', target: '_blank', rel: 'noopener'
          end
          div 'Documento de seguridad'
          div 'Funciones y obligaciones del personal'
          div 'Relación de administradores'
          div 'Relación de usuarios autorizados'
        end
      end
    end
    columns do
      column do
        panel 'Últimos usuarios dados de alta' do
          ul do
            User.limit(30).map do |user|
              li link_to(user.full_name, admin_user_path(user)) + "- #{user.created_at}"
            end
          end
        end
      end
      column do
        # Notice panel - only show if Notice admin resource is available
        if respond_to?(:admin_notice_path) || respond_to?(:new_admin_notice_path)
          div do
            panel 'Avisos' do
              ul do
                Notice.limit(5).map do |notice|
                  li link_to(notice.title, admin_notice_path(notice)) + "- #{notice.created_at}"
                end
              end
              div do
                link_to('Enviar aviso a todos', new_admin_notice_path, class: 'button')
              end
            end
          end
        end
        # Election panel - only show if Election admin resource is available
        if respond_to?(:admin_election_path) || respond_to?(:new_admin_election_path)
          div do
            panel 'Elecciones' do
              ul do
                Election.limit(5).map do |election|
                  li link_to(election.title, admin_election_path(election)) + "- #{election.created_at}"
                end
              end
              div do
                link_to('Dar de alta nueva elección', new_admin_election_path, class: 'button')
              end
            end
          end
          # panel "Cambios" do
          #  table_for PaperTrail::Version.order('id desc').limit(20) do # Use PaperTrail::Version if this throws an error
          #    column "Item" do |v| link_to v.item, v.item.admin_permalink end
          #    # column ("Item") { |v| link_to v.item, [:admin, v.item] } # Uncomment to display as link
          #    column ("Type") { |v| v.item_type.underscore.humanize }
          #    column ("Modified at") { |v| v.created_at.to_s :long }
          #  end
          # end
        end
      end
    end
  end
end
