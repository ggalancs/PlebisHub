# frozen_string_literal: true

require 'fileutils'
class Collaboration < ApplicationRecord
  include Rails.application.routes.url_helpers

  # Collaboration concerns - extracted for better organization
  include Collaboration::PaymentMethods

  # Provide default URL options for URL helpers when called from model context
  # This is needed for Redsys payment URLs generated in ok_url/ko_url methods
  def default_url_options
    ActionMailer::Base.default_url_options || { host: 'www.example.com' }
  end

  acts_as_paranoid
  has_paper_trail

  belongs_to :user, -> { with_deleted }, optional: true

  # FIXME: this should be orders for the inflextions
  # http://guides.rubyonrails.org/association_basics.html#the-has-many-association
  # should have a solid test base before doing this change and review where .order
  # is called.
  #
  # has_many :orders, as: :parent
  has_many :order, as: :parent

  attr_accessor :skip_queries_validations

  validates :payment_type, :amount, :frequency, presence: true
  validates :terms_of_service, acceptance: { accept: [true, '1'] }
  validates :minimal_year_old, acceptance: { accept: [true, '1'] }
  validates :user_id, uniqueness: { scope: :deleted_at }, allow_blank: true,
                      unless: :only_have_single_collaborations?
  validates :non_user_email, uniqueness: { case_sensitive: false, scope: :deleted_at },
                             allow_blank: true, unless: :skip_queries_validations
  validates :non_user_document_vatid, uniqueness: { case_sensitive: false, scope: :deleted_at },
                                      allow_blank: true, unless: :skip_queries_validations
  validates :non_user_email, :non_user_document_vatid, :non_user_data, presence: true, if: proc { |c| c.user.nil? }

  validate :validates_not_passport
  validate :validates_age_over
  validate :validates_has_user

  AMOUNTS = { '3 €' => 300, '5 €' => 500, '10 €' => 1000, '20 €' => 2000, '30 €' => 3000, '50 €' => 5000,
              '100 €' => 10_000, '200 €' => 20_000, '500 €' => 50_000 }.freeze
  FREQUENCIES = { 'Puntual' => 0, 'Mensual' => 1, 'Trimestral' => 3, 'Anual' => 12 }.freeze
  STATUS = { 'Sin pago' => 0, 'Error' => 1, 'Sin confirmar' => 2, 'OK' => 3, 'Alerta' => 4, 'Migración' => 9 }.freeze

  scope :created, -> { all }
  scope :live, -> { where(deleted_at: nil) }
  scope :credit_cards, -> { live.where(payment_type: 1) }
  scope :banks, -> { live.where.not(payment_type: 1) }
  scope :bank_nationals, lambda {
    live.where.not(payment_type: 1).where.not('collaborations.payment_type = 3 and iban_account NOT LIKE ?', 'ES%')
  }
  scope :bank_internationals, -> { live.where(payment_type: 3).where('iban_account NOT LIKE ?', 'ES%') }
  scope :frequency_single, -> { live.where(frequency: 0) }
  scope :frequency_month, -> { live.where(frequency: 1) }
  scope :frequency_quarterly, -> { live.where(frequency: 3) }
  scope :frequency_anual, -> { live.where(frequency: 12) }
  scope :amount_1, -> { live.where('amount < 1000') }
  scope :amount_2, -> { live.where('amount >= 1000 and amount < 2000') }
  scope :amount_3, -> { live.where('amount > 2000') }

  scope :incomplete, -> { live.where(status: 0) }
  scope :unconfirmed, -> { live.where(status: 2) }
  scope :active, -> { live.where(status: 3) }
  scope :warnings, -> { live.where(status: 4) }
  scope :errors, -> { live.where(status: 1) }
  scope :suspects, lambda {
    banks.active.where('(select count(*) from orders o where o.parent_id=collaborations.id and o.payable_at>? and o.status=5)>2', Time.zone.today - 8.months)
  }
  scope :legacy, -> { live.where.not(non_user_data: nil) }
  scope :non_user, -> { live.where(user_id: nil) }
  scope :deleted, -> { only_deleted }

  scope :full_view, -> { with_deleted.eager_load(:order) }

  scope :autonomy_cc, -> { live.where(for_autonomy_cc: true) }
  scope :town_cc, -> { live.where(for_town_cc: true) }
  scope :island_cc, -> { live.where(for_island_cc: true) }

  after_initialize :parse_non_user
  before_save :format_non_user
  # Rails 7.2: Changed from after_create to before_create so status is persisted
  before_create :set_initial_status
  before_save do
    iban_account.presence&.upcase!
    if payment_type != 1 && (redsys_identifier.present? || redsys_expiration.present?)
      self.redsys_identifier = nil
      self.redsys_expiration = nil
    end
  end
  after_commit :verify_user_militant_status

  def only_have_single_collaborations?
    frequency&.zero? || skip_queries_validations
  end

  def territorial_assignment=(value)
    self.for_town_cc = self.for_island_cc = self.for_autonomy_cc = false
    case value.to_sym
    when :town then self.for_town_cc = true
    when :island then self.for_island_cc = true
    when :autonomy then self.for_autonomy_cc = true
    end
  end

  def territorial_assignment
    if for_town_cc
      :town
    elsif for_island_cc
      :island
    elsif for_autonomy_cc
      :autonomy
    else
      :country
    end
  end

  def set_initial_status
    self.status = 0
  end

  def has_payment?
    status.positive?
  end

  def validates_not_passport
    return unless user&.is_passport?

    errors.add(:user, 'No puedes colaborar si no dispones de DNI o NIE.')
  end

  def validates_age_over
    return unless user&.born_at && (user.born_at > Time.zone.today - 18.years)

    errors.add(:user, 'No puedes colaborar si eres menor de edad.')
  end

  def frequency_name
    Collaboration::FREQUENCIES.invert[frequency]
  end

  def status_name
    Collaboration::STATUS.invert[status]
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def is_recurrent?
    true
  end

  def is_payable?
    [2, 3].include? status and deleted_at.nil? and valid? and (!user or user.deleted_at.nil?)
  end

  def is_active?
    status > 1 and deleted_at.nil?
  end

  def has_confirmed_payment?
    status > 2 and deleted_at.nil?
  end

  def admin_permalink
    admin_collaboration_path(self)
  end

  def first_order
    order.sort { |a, b| a.payable_at <=> b.payable_at }.detect { |o| o.is_payable? or o.is_paid? }
  end

  def last_order_for(date)
    order.sort do |a, b|
      b.payable_at <=> a.payable_at
    end.detect { |o| o.payable_at.unique_month <= date.unique_month and (o.is_payable? or o.is_paid?) }
  end

  def create_order(date, maybe_first = false, add_amount = true)
    is_first = false
    amount = 0
    reference_text = ''

    if maybe_first && !has_confirmed_payment?
      if first_order.nil?
        is_first = true
      elsif first_order.payable_at.unique_month == date.unique_month
        return first_order
      end
    end

    if frequency == 1
      date_aux = DateTime.now - 1.month
      month = date_aux.month
      year = date_aux.year
      min_date = DateTime.parse("#{year}-#{month}-01 00:00")
      last_returned_order = order.where('payed_at > ?',
                                        '2020-09-30').where(payed_at: min_date..).returned.order(payed_at: 'ASC').last

      if last_returned_order && add_amount
        amount = last_returned_order.amount if last_returned_order.present?
        reference_text = "#{last_returned_order.reference.strip}, "
      end
    end
    # Rails 7.2: Ensure payment day is valid for the month (clamp to last day if needed)
    unless is_first && is_credit_card?
      payment_day = Order.payment_day
      if payment_day&.positive?
        begin
          # Get the last day of the month to avoid invalid dates (e.g., Feb 30)
          last_day_of_month = Date.civil(date.year, date.month, -1).day
          valid_day = [payment_day, last_day_of_month].min
          date = date.change(day: valid_day)
        rescue Date::Error
          # If date change fails, keep the original date
          # This can happen with invalid dates or edge cases
        end
      end
    end
    reference_text += user.present? && user.militant? && frequency != 0 ? 'Cuota ' : 'Colaboración '

    reference_text += case frequency
                      when 0
                        'Puntual '
                      when 3
                        'Trimestral '
                      when 12
                        'Anual '
                      else
                        ''
                      end

    reference_text += I18n.l(date, format: '%B %Y')
    amount += frequency.zero? ? self.amount : self.amount * frequency
    autonomy_code_value = for_autonomy_cc.present? ? get_vote_autonomy_code : nil
    town_code_value = for_town_cc.present? ? get_vote_town : nil
    island_code_value = for_island_cc ? get_vote_island_code : nil
    vote_circle_autonomy_code_value = for_autonomy_cc.present? ? get_vote_circle_autonomy_code : nil
    vote_circle_town_code_value = for_town_cc.present? ? get_vote_circle_town : nil
    vote_circle_island_code_value = for_island_cc ? get_vote_circle_island_code : nil

    if user_id.present? && user.has_comarcal_circle?
      town_code_value = nil
      autonomy_code_value = get_vote_circle_autonomy_code
      vote_circle_town_code_value = nil
      vote_circle_autonomy_code_value = get_vote_circle_autonomy_code
    end

    order = Order.new user: user,
                      parent: self,
                      reference: reference_text,
                      first: is_first,
                      amount: amount,
                      payable_at: date,
                      payment_type: is_credit_card? ? 1 : 3,
                      payment_identifier: payment_identifier,
                      autonomy_code: autonomy_code_value,
                      town_code: town_code_value,
                      island_code: island_code_value,
                      vote_circle_autonomy_code: vote_circle_autonomy_code_value,
                      vote_circle_town_code: vote_circle_town_code_value,
                      vote_circle_island_code: vote_circle_island_code_value,
                      vote_circle_id: get_vote_circle_id

    order.target_territory = order.generate_target_territory
    order
  end

  MAX_RETURNED_ORDERS = 2
  def processed_order!(error = nil, warn = false, is_error = false)
    # FIXME: this should be orders for the inflextions
    # http://guides.rubyonrails.org/association_basics.html#the-has-many-association
    # should have a solid test base before doing this change and review where .order
    # is called.

    oids = order.pluck(:id).last(MAX_RETURNED_ORDERS)
    returned_orders = order.where(id: oids).returned.count
    militant = get_user.militant? || false

    if is_payable?
      if error
        set_error! 'Marcada como error porque se ha devuelto una orden con código asociado a error en la colaboración.'
      elsif warn
        set_warning! 'Marcada como alerta porque se ha devuelto una orden con código asociado a alerta en la colaboración.'
      elsif returned_orders >= MAX_RETURNED_ORDERS || is_error
        last_order = last_order_for(Time.zone.today)
        last_month = if last_order
                       last_order.payable_at.unique_month
                     else
                       created_at.unique_month
                     end
        msg_error = is_error ? 'Marcada como error por respuesta directa del banco' : 'Marcada como error porque se ha superado el límite de órdenes devueltas consecutivas.'
        if (Time.zone.today.unique_month - 1 - last_month >= frequency * MAX_RETURNED_ORDERS) || is_error
          set_error! msg_error
        end
      end
    end
    if returned_orders >= MAX_RETURNED_ORDERS || is_error
      if militant
        CollaborationsMailer.collaboration_suspended_militant(self).deliver_now
      else
        CollaborationsMailer.collaboration_suspended_user(self).deliver_now
      end
    elsif militant
      CollaborationsMailer.order_returned_militant(self).deliver_now
    else
      CollaborationsMailer.order_returned_user(self).deliver_now
    end
  end

  def has_warnings?
    status == 4
  end

  def has_errors?
    status == 1
  end

  def set_error!(reason)
    # Rails 7.2: Use update_column instead of deprecated update_attribute
    update_column :status, 1
    add_comment reason
  end

  def set_active!
    # Rails 7.2: Use update_column instead of deprecated update_attribute
    update_column(:status, 2) if status < 2
  end

  def set_ok!
    # Rails 7.2: Use update_column instead of deprecated update_attribute
    update_column :status, 3
  end

  def set_warning!(reason)
    # Rails 7.2: Use update_column for persisted records, direct assignment for new records
    # update_column requires a persisted record
    if persisted?
      update_column :status, 4
    else
      self.status = 4
    end
    add_comment reason
  end

  def must_have_order?(date)
    this_month = Time.zone.today.unique_month

    # first order not created yet, must have order this month, or next if its paid by bank and was created this month after payment day
    if first_order.nil?
      next_order = this_month
      next_order += 1 if is_bank? && (created_at.unique_month == next_order) && (created_at.day >= Order.payment_day)
      return date.unique_month == next_order if frequency.zero?

      # first order created on asked date
    elsif first_order.payable_at.unique_month == date.unique_month
      return true

      # mustn't have order on months before it first order
    elsif first_order.payable_at.unique_month > date.unique_month
      return false

      # don't create more orders for single collaborations
    elsif frequency.zero?
      return false

      # calculate next order month based on last paid order
    else
      next_order = last_order_for(date - 1.month).payable_at.unique_month + frequency
      # update next order when a payment was missed
      next_order = Time.zone.today.unique_month if next_order < Time.zone.today.unique_month
    end

    (date.unique_month >= next_order) && ((date.unique_month - next_order) % frequency).zero?
  end

  def get_orders(date_start = Time.zone.today, date_end = Time.zone.today, create_orders = true)
    saved_orders = Hash.new { |h, k| h[k] = [] }
    order.select do |o|
      o.payable_at > date_start.beginning_of_month and o.payable_at < date_end.end_of_month and !o.parent.nil?
    end.each do |o|
      saved_orders[o.payable_at.unique_month] << o
    end

    current = date_start

    orders = []
    add_amount = true
    while current <= date_end
      # month orders sorted by creation date
      month_orders = saved_orders[current.unique_month].sort_by(&:created_at)

      # valid orders without errors
      valid_orders = month_orders.reject(&:has_errors?)

      # if collaboration is active, should create orders, this month should have an order and it doesn't have a valid saved order, create it (not persistent)

      if deleted_at.nil? && create_orders && must_have_order?(current) && valid_orders.empty?
        order = create_order current, orders.empty?, add_amount
        month_orders << order if order
      end
      orders << month_orders if month_orders.length.positive?
      current += 1.month
      add_amount = false
    end
    orders
  end

  def ok_url
    ok_collaboration_url(host: default_url_options[:host])
  end

  def ko_url
    ko_collaboration_url(host: default_url_options[:host])
  end

  def fix_status!
    if !valid? && !has_errors?
      set_error! 'Marcada como error porque la colaboración no supera todas las validaciones antes de generar su orden.'
      true
    else
      false
    end
  end

  def charge!
    return unless is_payable?

    order = get_orders[0] # get orders for current month
    order = order[-1] if order # get last order for current month
    return unless order&.is_chargeable?

    if is_credit_card?
      order.redsys_send_request if is_active?
    else
      order.save
    end
  end

  def get_bank_data(date)
    order = last_order_for date
    return unless order && (order.payable_at.unique_month == date.unique_month) && order.is_chargeable?

    col_user = get_user
    [format('%02d%02d%06d', date.year % 100, date.month, order.id % 1_000_000),
     col_user.full_name.mb_chars.upcase.to_s, col_user.document_vatid.upcase, col_user.email,
     col_user.address.mb_chars.upcase.to_s, col_user.town_name.mb_chars.upcase.to_s,
     col_user.postal_code, col_user.country.upcase,
     calculate_iban, ccc_full, calculate_bic,
     order.amount / 100, order.due_code, order.url_source, id,
     created_at.strftime('%d-%m-%Y'), order.reference, order.payable_at.strftime('%d-%m-%Y'),
     frequency_name, col_user.full_name.mb_chars.upcase.to_s,
     col_user.respond_to?(:still_militant?) ? col_user.still_militant? : false]
  end

  class NonUser
    def initialize(args)
      %i[legacy_id full_name document_vatid email address town_name postal_code country province
         phone province_name island_name autonomy_name ine_town].each do |var|
        instance_variable_set("@#{var}", args[var]) if args.member? var
      end
    end

    attr_accessor :legacy_id, :full_name, :document_vatid, :email, :address, :town_name, :postal_code, :country,
                  :province, :phone, :province_name, :island_name, :autonomy_name, :ine_town

    def to_s
      "#{full_name} (#{document_vatid} - #{email})"
    end

    def still_militant?
      false
    end

    def vote_circle_id
      nil
    end
  end

  def parse_non_user
    @non_user = if non_user_data
                  YAML.safe_load(non_user_data, permitted_classes: [Collaboration::NonUser, Symbol], aliases: true)
                end
  end

  def format_non_user
    if @non_user
      self.non_user_data = YAML.dump(@non_user)
      self.non_user_document_vatid = @non_user.document_vatid
      self.non_user_email = @non_user.email
    else
      self.non_user_data = self.non_user_document_vatid = self.non_user_email = nil
    end
  end

  def set_non_user(info)
    @non_user = info.nil? ? nil : NonUser.new(info)
    format_non_user
  end

  def get_user
    user || @non_user
  end

  def get_vote_town
    if user
      user.vote_town
    else
      get_non_user.ine_town
    end
  end

  def get_vote_town_name
    if user
      user.vote_town_name
    elsif get_non_user.ine_town
      prov = Carmen::Country.coded('ES').subregions[get_non_user.ine_town[2, 2].to_i - 1]
      carmen_town = prov.subregions.coded(get_non_user.ine_town.strip)
      carmen_town.present? ? carmen_town.name : "#{get_non_user.ine_town} no es un municipio válido"
    else
      ''
    end
  end

  def get_vote_autonomy_code
    if user
      user.vote_autonomy_code
    else
      non_user = get_non_user
      return nil unless non_user.respond_to?('ine_town') && non_user.ine_town

      vote_province_code = "p_#{non_user.ine_town.slice(2, 2)}"
      autonomy_data = PlebisBrand::GeoExtra::AUTONOMIES[vote_province_code]
      autonomy_data&.first
    end
  end

  def get_vote_autonomy_name
    if user
      user.vote_autonomy_name
    else
      non_user = get_non_user
      return nil unless non_user.respond_to?('ine_town') && non_user.ine_town

      vote_province_code = "p_#{non_user.ine_town.slice(2, 2)}"
      autonomy_data = PlebisBrand::GeoExtra::AUTONOMIES[vote_province_code]
      autonomy_data&.last
    end
  end

  def get_vote_island_code
    if user
      user.vote_island_code
    else
      non_user = get_non_user
      return nil unless non_user&.ine_town

      island_data = PlebisBrand::GeoExtra::ISLANDS[non_user.ine_town]
      island_data&.first
    end
  end

  def get_vote_island_name
    if user
      user.vote_island_name
    else
      non_user = get_non_user
      return nil unless non_user&.ine_town

      island_data = PlebisBrand::GeoExtra::ISLANDS[non_user.ine_town]
      island_data&.last
    end
  end

  def get_vote_circle_town
    town_code = nil
    if user
      u = user
      if u.vote_circle_id.present?
        circle = u.vote_circle
        town_code = circle.town if circle.town.present?
      end
      town_code ||= u.vote_town
    else
      town_code = get_non_user.ine_town
    end
    town_code
  end

  def get_vote_circle_autonomy_code
    autonomy_code = nil
    if user
      u = user
      if u.vote_circle_id.present?
        circle = u.vote_circle
        autonomy_code = circle.autonomy_code
      end
      autonomy_code ||= u.vote_autonomy_code
    else
      non_user = get_non_user
      if non_user.respond_to?('ine_town') && non_user.ine_town
        vote_province_code = "p_#{non_user.ine_town.slice(2, 2)}"
        autonomy_data = PlebisBrand::GeoExtra::AUTONOMIES[vote_province_code]
        autonomy_code = autonomy_data&.first
      end
    end
    autonomy_code
  end

  def get_vote_circle_island_code
    island_code = nil
    if user
      u = user
      if u.vote_circle_id.present?
        circle = u.vote_circle
        if circle.town.present?
          island = PlebisBrand::GeoExtra::ISLANDS[circle.town]
          island_code = circle.island_code
          island_code = island.present? ? island[0] : u.vote_island_code if island_code.blank?
        elsif circle.in_spain?
          island_code = circle.island_code
        end
      end
      island_code ||= u.vote_island_code
    else
      non_user = get_non_user
      if non_user&.ine_town
        island_data = PlebisBrand::GeoExtra::ISLANDS[non_user.ine_town]
        island_code = island_data&.first
      end
    end
    island_code
  end

  def get_vote_circle_id
    user.vote_circle_id if user && user.vote_circle_id.present?
  end

  def get_non_user
    @non_user
  end

  def vote_town
    :ine_town
  end

  def town_name
    :town_name
  end

  def province_name
    :province_name
  end

  def autonomy_name
    :autonomy_name
  end

  def island_name
    :island_name
  end

  def validates_has_user
    return unless get_user.nil?

    errors.add(:user, 'La colaboración debe tener un usuario asociado.')
  end

  def self.bank_filename(date, full_path = true)
    filename = "plebisbrand.orders.#{date.year}.#{date.month}"
    if full_path
      Rails.root.join("db/plebisbrand/#{filename}.csv").to_s
    else
      filename
    end
  end

  BANK_FILE_LOCK = Rails.root.join("db/plebisbrand/plebisbrand.orders.#{Rails.env}.lock").to_s.freeze
  def self.bank_file_lock(status)
    if status
      folder = File.dirname BANK_FILE_LOCK
      FileUtils.mkdir_p(folder) unless File.directory?(folder)
      FileUtils.touch BANK_FILE_LOCK
    elsif File.exist? BANK_FILE_LOCK
      FileUtils.rm_f(BANK_FILE_LOCK)
    end
  end

  def self.has_bank_file?(date)
    [File.exist?(BANK_FILE_LOCK), File.exist?(bank_filename(date))]
  end

  def self.update_paid_unconfirmed_bank_collaborations(orders)
    Collaboration.unconfirmed.joins(:order).merge(orders).update_all(status: 3)
  end

  def verify_user_militant_status
    u = user
    return if u.nil?

    u.update(militant: u.still_militant?)
    u.process_militant_data
  end

  # Get available payment types based on collaboration state
  def self.available_payment_types(collaboration)
    Order::PAYMENT_TYPES.to_a.select { |_k, v| [3, collaboration.payment_type].member?(v) }
  end

  # Get available frequencies for user based on existing collaborations and parameters
  def self.available_frequencies_for_user(user, force_single: false, only_recurrent: false)
    return FREQUENCIES.slice('Puntual').to_a if force_single
    return FREQUENCIES.except('Puntual').to_a if user.recurrent_collaboration || only_recurrent

    FREQUENCIES.to_a
  end

  # Calculate date range and max order elements for display
  def calculate_date_range_and_orders
    start_date = [created_at.to_date, Time.zone.today - 6.months].max
    max_element = (frequency.zero? ? 1 : (12 / frequency) - 1)
    orders = get_orders(start_date, start_date + 12.months)[0..max_element]

    { start_date: start_date, max_element: max_element, orders: orders }
  end
end
