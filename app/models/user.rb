# frozen_string_literal: true

class User < ApplicationRecord
  apply_simple_captcha

  include FlagShihTzu

  include Rails.application.routes.url_helpers

  # Engine User concerns - dynamically loaded based on active engines
  include EngineUser

  # V2.0 features
  include Gamifiable

  # User concerns - extracted for better organization
  include User::PhoneVerification
  include User::LocationHelpers

  # FlagShihTzu: check_for_column: false prevents startup warnings before migrations run
  has_flags  1 => :banned,
             2 => :superadmin,
             3 => :verified,
             4 => :finances_admin,
             5 => :impulsa_author,
             6 => :impulsa_admin,
             7 => :verifier,
             8 => :paper_authority,
             9 => :militant,
             10 => :exempt_from_payment,
             check_for_column: false

  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  # Register engine-specific concerns (loaded only when engines are active)
  register_engine_concern('plebis_voting', EngineUser::Votable)
  register_engine_concern('plebis_collaborations', EngineUser::Collaborator)
  register_engine_concern('plebis_verification', EngineUser::Verifiable)
  register_engine_concern('plebis_microcredit', EngineUser::Microcreditor)
  register_engine_concern('plebis_impulsa', EngineUser::ImpulsaAuthor)
  register_engine_concern('plebis_proposals', EngineUser::Proposer)
  register_engine_concern('plebis_participation', EngineUser::TeamMember)
  register_engine_concern('plebis_militant', EngineUser::Militant)

  before_save :before_save

  acts_as_paranoid
  has_paper_trail

  # NOTE: Associations are defined in engine-specific concerns
  # See app/models/concerns/engine_user/*.rb
  # Each concern is loaded only when the corresponding engine is active
  #
  # Associations now in concerns:
  # - votes, paper_authority_votes → EngineUser::Votable
  # - supports → EngineUser::Proposer
  # - collaborations → EngineUser::Collaborator
  # - participation_teams → EngineUser::TeamMember
  # - microcredit_loans → EngineUser::Microcreditor
  # - user_verifications → EngineUser::Verifiable
  # - militant_records → EngineUser::Militant

  # Core association (not in any engine)
  belongs_to :vote_circle, optional: true

  validates :first_name, :last_name, :document_type, :document_vatid, presence: true
  validates :address, :postal_code, :town, :province, :country, :born_at, presence: true
  validates :email, email: true
  validates :email, confirmation: true, on: :create
  validates :email_confirmation, presence: true, on: :create
  validates :terms_of_service, acceptance: { accept: [true, '1'] }
  validates :over_18, acceptance: { accept: [true, '1'] }
  validates :document_type, inclusion: { in: [1, 2, 3], message: 'Tipo de documento no válido' }
  validates :document_vatid, valid_nif: true, if: :is_document_dni?
  validates :document_vatid, valid_nie: true, if: :is_document_nie?
  validates :born_at, date: true, allow_blank: true #  gem date_validator
  validate :validate_born_at
  validates :checked_vote_circle, acceptance: { accept: [true, '1'] }

  validates :email, uniqueness: { case_sensitive: false, scope: :deleted_at }
  validates :document_vatid, uniqueness: { case_sensitive: false, scope: :deleted_at }
  validates :phone, uniqueness: { scope: :deleted_at }, allow_blank: true
  validates :unconfirmed_phone, uniqueness: { scope: :deleted_at }, allow_blank: true

  validate :validates_postal_code
  # SEC-002: Password complexity validation
  validate :password_complexity, if: -> { password.present? }

  MIN_MILITANT_AMOUNT = Rails.application.secrets.users['min_militant_amount'].present? ? Rails.application.secrets.users['min_militant_amount'].to_i : 3

  def validate_born_at
    errors.add(:born_at, 'debes ser mayor de 18 años') if born_at && born_at > Time.zone.today - 18.years
  end

  # SEC-002: Password complexity validation
  # Requires at least one lowercase letter, one uppercase letter, and one digit
  def password_complexity
    return if password.blank?

    return if password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)

    errors.add :password, 'must include at least one lowercase letter, one uppercase letter, and one digit'
  end

  def validates_postal_code
    return unless country == 'ES'

    if (postal_code =~ /^\d{5}$/).zero?
      province = Carmen::Country.coded('ES').subregions.coded(self.province)
      if province && (postal_code[0...2] != province.subregions[0].code[2...4])
        errors.add(:postal_code, 'El código postal no coincide con la provincia indicada')
      end
    else
      errors.add(:postal_code, 'El código postal debe ser un número de 5 cifras')
    end
  end


  def check_issue(validation_response, path, message, controller)
    return unless validation_response

    message[message.first[0]] = validation_response if message && validation_response.instance_of?(String)
    { path: path, message: message, controller: controller }
  end

  # returns issues with user profile, blocking first
  def get_unresolved_issue(only_blocking = false)
    # User have a valid born date
    issue ||= check_issue (born_at.nil? || (born_at == Date.civil(1900, 1, 1))), :edit_user_registration,
                          { alert: 'born_at' }, 'registrations'

    # User must review his location (town code first letter uppercase)
    issue ||= check_issue town.starts_with?('M_'), :edit_user_registration, { notice: 'location' }, 'registrations'

    # User have a valid location
    issue ||= check_issue verify_user_location, :edit_user_registration, { alert: 'location' }, 'registrations'

    # User don't have a legacy password, verify if profile is valid before request to change it
    if has_legacy_password?
      issue ||= check_issue invalid?, :edit_user_registration, nil, 'registrations'

      issue ||= check_issue true, :new_legacy_password, { alert: 'legacy_password' }, 'legacy_password'
    end

    # User has confirmed SMS code
    issue ||= check_issue sms_confirmed_at.nil?, :sms_validator_step1, { alert: 'confirm_sms' }, 'sms_validator'

    return issue if issue || only_blocking # End of blocking issues

    issue ||= check_issue vote_town_notice, :edit_user_registration, { notice: 'vote_town' }, 'registrations'

    return unless issue

    issue
  end
  attr_accessor :sms_user_token_given, :login, :skip_before_save, :checked_vote_circle, :participa_user_id

  scope :all_with_deleted, -> { where 'deleted_at IS null OR deleted_at IS NOT null' }
  scope :wants_newsletter, -> { where(wants_newsletter: true) }
  scope :created, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :unconfirmed_mail, -> { where(confirmed_at: nil) }
  scope :unconfirmed_phone, -> { where(sms_confirmed_at: nil) }
  scope :confirmed_mail, -> { where.not(confirmed_at: nil) }
  scope :confirmed_phone, -> { where.not(sms_confirmed_at: nil) }
  scope :legacy_password, -> { where(has_legacy_password: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil).where.not(sms_confirmed_at: nil) }
  scope :signed_in, -> { where.not(sign_in_count: nil) }
  scope :has_collaboration, -> { joins(:collaborations).where.not(collaborations: { user_id: nil }) }
  scope :has_collaboration_credit_card, -> { joins(:collaborations).where('collaborations.payment_type' => 1) }
  scope :has_collaboration_bank_national, -> { joins(:collaborations).where('collaborations.payment_type' => 2) }
  scope :has_collaboration_bank_international, -> { joins(:collaborations).where('collaborations.payment_type' => 3) }
  scope :participation_team, -> { includes(:participation_team).where.not(participation_team_at: nil) }
  scope :has_vote_circle, -> { where.not(vote_circle_id: nil) }
  scope :wants_information_by_sms, -> { where(wants_information_by_sms: true) }
  scope :militant_and_exempt_from_payment, -> { created.militant.exempt_from_payment }
  scope :active_militant, -> { created.militant }
  scope :exterior, -> { where.not(country: 'ES') }
  scope :spain, -> { where(country: 'ES') }

  ransacker :vote_province, formatter: proc { |value|
    values = value.split(',')
    values.map do |val|
      Carmen::Country.coded('ES').subregions[(val[2..3].to_i - 1)].subregions.map(&:code)
    end.flatten.compact
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :vote_autonomy, formatter: proc { |value|
    values = value.split(',')
    spain = Carmen::Country.coded('ES')
    PlebisBrand::GeoExtra::AUTONOMIES.map do |k, v|
      next unless v[0].in?(values)

      spain.subregions[k[2..3].to_i - 1].subregions.map(&:code)
    end.compact.flatten
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :vote_island, formatter: proc { |value|
    values = value.split(',')
    PlebisBrand::GeoExtra::ISLANDS.map { |k, v| k if v[0].in?(values) }.compact
  } do |parent|
    parent.table[:vote_town]
  end

  ransacker :user_vote_circle_province_id, formatter: proc { |value|
    VoteCircle.where('code like ?', value).map(&:id).uniq
  } do |parent|
    parent.table[:vote_circle_id]
  end

  ransacker :user_vote_circle_autonomy_id, formatter: proc { |value|
    VoteCircle.where('code like ?', value).map(&:id).uniq
  } do |parent|
    parent.table[:vote_circle_id]
  end

  ransacker :user_vote_circle_id, formatter: proc { |value|
    VoteCircle.where(id: value).map(&:id).uniq
  } do |parent|
    parent.table[:vote_circle_id]
  end

  GENDER = { 'F' => 'Femenino', 'M' => 'Masculino', 'O' => 'Otro', 'N' => 'No contesta' }.freeze
  DOCUMENTS_TYPE = [['DNI', 1], ['NIE', 2], ['Pasaporte', 3]].freeze

  #  Based on
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  # Check if login is email or document_vatid to use the DB indexes
  #
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      login_key = login.downcase.include?('@') ? 'email' : 'document_vatid'
      where(conditions).find_by(["lower(#{login_key}) = :value", { value: login.downcase }])
    else
      where(conditions).first
    end
  end

  # SECURITY FIX SEC-037: Added race condition handling
  def get_or_create_vote(election_id)
    votes.find_or_create_by!(election_id: election_id) do |vote|
      vote.created_at = Time.current
    end
  rescue ActiveRecord::RecordNotUnique
    # Race condition occurred - retry with existing record
    votes.find_by!(election_id: election_id)
  end

  def has_already_voted_in(election_id)
    Vote.where(election_id: election_id).where(user_id: id).present?
  end

  def document_vatid=(val)
    self[:document_vatid] = val.upcase.strip
  end

  def is_document_dni?
    document_type == 1
  end

  def is_document_nie?
    document_type == 2
  end

  def is_passport?
    document_type == 3
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_address
    "#{address}, #{town_name}, #{province_name}, CP #{postal_code}, #{country_name}"
  end

  def is_admin?
    admin
  end


  def document_type_name
    User::DOCUMENTS_TYPE.select { |v| v[1] == document_type }[0][0]
  end

  def gender_name
    User::GENDER[gender]
  end

  def in_spain?
    country == 'ES'
  end


  def self.ban_users(ids, value)
    t = User.with_deleted.arel_table
    User.with_deleted.where(id: ids).where(t[:admin].eq(false).or(t[:admin].eq(nil))).update_all User.set_flag_sql(
      :banned, value
    )
  end

  def before_save
    return if @skip_before_save

    if User.with_deleted.banned.where(document_vatid: document_vatid).any?
      errors.add('Información insuficiente:', I18n.t('plebisbrand.banned', full_name: full_name))
      false
    else
      # Spanish users can't set a different town for vote, except when blocked
      if in_spain? && can_change_vote_location?
        self.vote_town = town
        self.vote_district = nil if vote_town_changed? # remove this when the user is allowed to choose district
      end
      self.militant = still_militant?
      if vote_circle_id_changed?
        self.vote_circle_changed_at = Time.zone.now
        process_militant_data
      end
      true
    end
  end

  def in_participation_team?(team_id)
    participation_team_ids.member? team_id
  end

  def admin_permalink
    admin_user_path(self)
  end


  private

  # Safely parse duration configuration strings without using eval()
  # Supports ActiveSupport duration formats: "5.minutes", "1.hour", "1.year"

  public


  def pass_vatid_check?
    verified || user_verifications.pending.any?
  end


  # Rails 7.2 FIX: Removed duplicate methods that were shadowing EngineUser::Verifiable concern
  # These methods are already defined as public in app/models/concerns/engine_user/verifiable.rb
  # Removed: has_not_future_verified_elections?, has_future_verified_elections?,
  #          has_not_verification_accepted?, imperative_verification,
  #          photos_unnecessary?, photos_necessary?
  # The User model was redefining them as private (after line 787), which caused
  # "private method called" errors in Rails 7.2+

  # RAILS 7.2 FIX: Make vote location methods public
  # These methods are called from PageController#add_user_params
  # They were incorrectly placed in the private section, causing NoMethodError


  # Back to private for internal helper methods

  # RAILS 7.2 FIX: This method must be public as it's called from MicrocreditController#any_renewable?
  # Rails 7.2 raises NoMethodError when calling private methods
  def any_microcredit_renewable?
    MicrocreditLoan.renewables.exists?(document_vatid: document_vatid)
  end

  def recurrent_collaboration
    collaborations.where.not(frequency: 0).last
  end

  def single_collaboration
    collaborations.where(frequency: 0).last
  end

  def pending_single_collaborations
    collaborations.where(frequency: 0).where(status: 2)
  end

  def sendy_url
    sendy_page = Rails.application.secrets.users&.dig('sendy_page')
    return nil if sendy_page.blank?

    url = "#{sendy_page}?zaz="
    encrypted = encrypt_data(email)
    url += encrypted if encrypted.present?
    url
  end

  def can_change_vote_circle?
    # use database version if vote_town has changed
    has_limit_date = Rails.application.secrets.users['date_close_vote_circle_unlimited_changes'].present?
    unless has_limit_date && Time.zone.now >= Time.zone.parse(Rails.application.secrets.users['date_close_vote_circle_unlimited_changes'])
      return true
    end
    return true unless vote_circle.present? && vote_circle.is_active?

    max = Rails.application.secrets.users['allow_vote_circle_changed_at_days'].present? ? Rails.application.secrets.users['allow_vote_circle_changed_at_days'].to_i.days : 365
    return true if vote_circle_changed_at.blank?

    if Rails.application.secrets.users['reset_vote_circle_changed_at'].present?
      reset_date = Rails.application.secrets.users['reset_vote_circle_changed_at']
    end
    (reset_date.present? && Time.zone.parse(vote_circle_changed_at.to_s) <= Time.zone.parse(reset_date)) || (Time.zone.parse(vote_circle_changed_at.to_s) <= (Time.zone.now - max.days)) || !persisted?
  end

  def in_vote_circle?
    vote_circle_id.present?
  end

  def has_min_monthly_collaboration?
    collaborations.where.not(frequency: 0).where(amount: MIN_MILITANT_AMOUNT..).exists?(status: 3)
  end

  def verified_for_militant?
    status = user_verifications.last.status if user_verifications.any?
    verified? || (user_verifications.any? && %w[pending accepted accepted_by_email].include?(status))
  end

  def collaborator_for_militant?
    has_min_monthly_collaboration? || collaborations.where.not(frequency: 0).where(amount: MIN_MILITANT_AMOUNT..).exists?(status: 2)
  end

  def still_militant?
    verified_for_militant? && in_vote_circle? && (exempt_from_payment? || collaborator_for_militant?)
  end

  def militant_at?(date)
    in_circle_at = Time.zone.parse(vote_circle_changed_at.to_s) if vote_circle_id.present?
    verified_at = nil
    collaborator_at = nil
    if user_verifications.any?
      last_verification = user_verifications.last
      status = last_verification.status
      verified_at = Time.zone.parse(last_verification.updated_at.to_s) if verified? || %w[pending
                                                                                          accepted].include?(status)
    end
    valid_collaboration = collaborations.where.not(frequency: 0).where(amount: MIN_MILITANT_AMOUNT..).where(status: [0,
                                                                                                                     2, 3])
    collaborator_at = Time.zone.parse(valid_collaboration.last.created_at.to_s) if valid_collaboration.exists?
    if exempt_from_payment?
      last_record = MilitantRecord.where(user_id: id).where(payment_type: 0).where.not(begin_payment: nil).last
      if last_record.present? && last_record.begin_payment.present?
        exempt_at = Time.zone.parse(last_record.begin_payment.to_s)
      end
      collaborator_at = [collaborator_at, exempt_at].min if collaborator_at && exempt_at
      collaborator_at ||= exempt_at
    end

    return false unless in_circle_at.present? && verified_at.present? && collaborator_at.present?

    dates_1 = [in_circle_at, collaborator_at]
    min_date = Time.zone.parse(date.to_s)
    (dates_1.min <= min_date)
  end

  def get_not_militant_detail
    is_militant = still_militant?
    return if militant? && is_militant
    update(militant: is_militant) && return if is_militant

    result = []

    result.push('No esta verificado') unless verified_for_militant?
    result.push('No esta inscrito en un circulo') unless in_vote_circle?
    unless exempt_from_payment? || collaborator_for_militant?
      result.push('No tiene colaboración económica periódica suscrita, no está exento de pago')
    end
    result.compact.flatten.join(', ').sub(/.*\K, /, ' y ')
  end

  def militant_records_management(is_militant)
    last_record = militant_records.last if militant_records.any?
    last_record ||= MilitantRecord.new
    new_record = MilitantRecord.new
    new_record.user_id = id
    now = DateTime.now
    if verified_for_militant?
      new_record.begin_verified = last_record.begin_verified if last_record.end_verified.blank?
      new_record.begin_verified ||= user_verifications.pluck(:updated_at).last
      new_record.end_verified = nil
    else
      new_record.begin_verified = last_record.begin_verified || nil
      new_record.end_verified = now if new_record.begin_verified.present?
    end
    if in_vote_circle?
      if vote_circle && vote_circle.name.present? && last_record.vote_circle_name.present? && vote_circle.name.downcase.strip == last_record.vote_circle_name.downcase.strip
        new_record.begin_in_vote_circle = last_record.begin_in_vote_circle if last_record.end_in_vote_circle.blank?
        new_record.begin_in_vote_circle ||= vote_circle_changed_at
        if last_record.vote_circle_name.present? && last_record.end_in_vote_circle.nil?
          new_record.vote_circle_name = last_record.vote_circle_name
        end
        new_record.vote_circle_name ||= vote_circle.name
      else
        last_record.update(end_in_vote_circle: vote_circle_changed_at)
        new_record.begin_in_vote_circle = vote_circle_changed_at
        new_record.vote_circle_name = vote_circle.name
      end
      new_record.end_in_vote_circle = nil
    else
      new_record.begin_in_vote_circle = last_record.begin_in_vote_circle if last_record.begin_in_vote_circle.present?
      new_record.vote_circle_name = last_record.vote_circle_name if last_record.vote_circle_name.present?
      new_record.end_in_vote_circle = now if new_record.begin_in_vote_circle.present?
    end
    if exempt_from_payment? || collaborator_for_militant?
      date_collaboration = last_record.begin_payment if last_record.end_payment.blank?
      new_record.payment_type = last_record.payment_type if last_record.end_payment.blank?
      if exempt_from_payment?
        date_collaboration ||= now
        new_record.payment_type ||= 0
        new_record.amount = 0
      else
        last_valid_collaboration = collaborations.where.not(frequency: 0).where(amount: MIN_MILITANT_AMOUNT..).where(status: 3).last
        last_valid_collaboration ||= collaborations.where.not(frequency: 0).where(status: [0, 2]).last
        # RAILS 7.2 FIX: Handle nil last_valid_collaboration to prevent NoMethodError
        date_collaboration ||= last_valid_collaboration&.created_at || now
        new_record.payment_type ||= 1
        new_record.amount = last_valid_collaboration&.amount || 0
      end
      new_record.begin_payment = date_collaboration
      new_record.end_payment = nil
    else
      new_record.begin_payment = last_record.begin_payment if last_record.begin_payment.present?
      new_record.end_in_vote_circle = now if new_record.begin_payment.present?
    end
    new_record.is_militant = is_militant
    new_record.save if new_record.diff?(last_record)
  end

  def process_militant_data
    is_militant = still_militant?
    lmr = militant_records.last
    if is_militant && (lmr.blank? || (lmr.present? && lmr.is_militant == false))
      UsersMailer.new_militant_email(id).deliver_now
    end
    militant_records_management is_militant
  end

  def self.census_vote_circle
    ids = User.militant.select { |u| u.id if u.militant_at?('2020-09-15') }
    User.where(id: ids)
  end

  def generate_qr_code
    secret = qr_secret || SecureRandom.hex(32).upcase
    date = Time.zone.now
    hash = Digest::SHA256.hexdigest(secret)
    [hash, secret, date]
  end

  def create_qr_code!
    hash, secret, date = generate_qr_code
    update(qr_hash: hash, qr_secret: secret, qr_created_at: date)
  end

  def qr_svg(generate = false)
    create_qr_code! if generate || qr_created_at.nil? || qr_expired?
    qrcode = RQRCode::QRCode.new("#{document_vatid}+#{qr_hash}")
    qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6
    )
  end

  def qr_life
    Rails.application.secrets[:qr_lifetime].send(Rails.application.secrets[:qr_life_units])
  end

  def qr_expire_date
    date = qr_created_at
    date + qr_life
  end

  def qr_expired?
    Time.zone.now > qr_expire_date
  end

  def is_qr_hash_correct?(qr_hash)
    Digest::SHA256.hexdigest(qr_secret) == qr_hash
  end

  def can_show_qr?
    Rails.application.secrets[:qr_enabled] && militant?
  end

  def has_active_circle?
    vote_circle_id.present? && !vote_circle.interno?
  end

  def has_comarcal_circle?
    vote_circle_id.present? && vote_circle.comarcal?
  end

  private


  def encrypt_data(data)
    cipher_type = Rails.application.secrets.users['cipher_type']
    key = Rails.application.secrets.users['cipher_key']
    iv = Rails.application.secrets.users['cipher_iv']

    return nil if cipher_type.nil? || key.nil? || iv.nil?

    cipher = OpenSSL::Cipher.new(cipher_type)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv

    encrypted = cipher.update(data) + cipher.final
    Base64.encode64([encrypted].pack('m').chomp)
  end
end
