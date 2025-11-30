# Rails 7.2: Monkey patches in lib/ are not automatically loaded
# Must explicitly require them in an initializer
require Rails.root.join('lib', 'add_unique_month_to_dates')
