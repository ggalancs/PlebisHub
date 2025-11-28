# http://codeconnoisseur.org/ramblings/creating-dynamic-routes-at-runtime-in-rails-4
class DynamicRouter

  def self.load
    return unless database_ready?

    if ActiveRecord::Base.connection.table_exists? 'pages'
      Rails.application.routes.draw do
        scope "/(:locale)", locale: /es|ca|eu/ do
          Page.all.each do |pag|
            get "#{pag.slug}", :to => "page#show_form", defaults: { id: pag.id }
          end
        end
      end
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad
    Rails.logger.warn "[DynamicRouter] Database not ready, skipping dynamic routes"
  end

  def self.database_ready?
    ActiveRecord::Base.connection
    true
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad
    false
  end

  def self.reload
    Rails.application.routes_reloader.reload!
  end
end
