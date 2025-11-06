class MicrocreditController < ApplicationController
  include CollaborationsHelper
  before_action :init_env
  before_action(only: [:renewal, :loans_renewal, :loans_renew]) do |controller|
    authenticate_user! unless params[:loan_id]
  end
  layout :external_layout

  def provinces
    render partial: 'subregion_select', locals:{ country: (params[:microcredit_loan_country] or "ES"), province: params[:microcredit_loan_province], disabled: false, required: true, title:"Provincia"}
  end

  def towns
    render partial: 'municipies_select', locals:{ country: (params[:microcredit_loan_country] or "ES"), province: params[:microcredit_loan_province], town: params[:microcredit_loan_town], disabled: false, required: true, title:"Municipio"}
  end

  def init_env
    default_brand = Rails.application.secrets.microcredits["default_brand"]
    @brand = params[:brand]
    @brand_config = Rails.application.secrets.microcredits["brands"][@brand]
    if @brand_config.blank?
      @brand = default_brand
      @brand_config = Rails.application.secrets.microcredits["brands"][default_brand]
    end
    @external = Rails.application.secrets.microcredits["brands"][@brand]["external"]
    @url_params = @brand == default_brand ? {} : { brand: @brand }
  end

  def external_layout
    @external ? "noheader" : "application"
  end

  def index
    @all_microcredits = Microcredit.upcoming_finished_by_priority

    @microcredits_standard = @all_microcredits.select(&:is_active?).select(&:is_standard?)
    @microcredits_mailing = @all_microcredits.select(&:is_active?).select(&:is_mailing?)

    if @microcredits_standard.empty?
      @upcoming_microcredits_standard = @all_microcredits.select(&:is_standard?).select(&:is_upcoming?).sort_by(&:starts_at)
      @finished_microcredits_standard = @all_microcredits.select(&:is_standard?).select(&:recently_finished?).sort_by(&:ends_at).reverse
      @microcredit_index_upcoming_text = @upcoming_microcredits_standard.first&.get_microcredit_index_upcoming_text
    end

    if @microcredits_mailing.empty?
      @upcoming_microcredits_mailing = @all_microcredits.select(&:is_mailing?).select(&:is_upcoming?).sort_by(&:starts_at)
      @finished_microcredits_mailing = @all_microcredits.select(&:is_mailing?).select(&:recently_finished?).sort_by(&:ends_at).reverse
      @microcredit_index_upcoming_text ||= @upcoming_microcredits_mailing.first&.get_microcredit_index_upcoming_text
    end
  end

  def login
    authenticate_user!
    redirect_to new_microcredit_loan_path(params[:id], brand:@brand)
  end

  def new_loan
    @microcredit = Microcredit.find(params[:id])
    redirect_to microcredit_path(brand:@brand) and return unless @microcredit and @microcredit.is_active?
    @loan = MicrocreditLoan.new
    @user_loans = current_user ? @microcredit.loans.where(user:current_user) : []
  end

  def create_loan
    @microcredit = Microcredit.find(params[:id])
    redirect_to microcredit_path(brand:@brand) and return unless @microcredit and @microcredit.is_active?
    @user_loans = current_user ? @microcredit.loans.where(user:current_user) : []

    @loan = MicrocreditLoan.new(loan_params) do |loan|
      loan.microcredit = @microcredit
      loan.user = current_user if current_user
      loan.ip = request.remote_ip
      child_id = params[:microcredit_loan]["microcredit_option_id_#{loan.microcredit_option_id}"] if params[:microcredit_loan].key?("microcredit_option_id_#{loan.microcredit_option_id}") && params[:microcredit_loan]["microcredit_option_id_#{loan.microcredit_option_id}"].present?
      loan.microcredit_option_id = child_id if child_id
    end
    if not current_user
      @loan.set_user_data loan_params
    end 

    @loan.transaction do
      if (current_user or @loan.valid_with_captcha?) and @loan.save
        @loan.update_counted_at
        UsersMailer.microcredit_email(@microcredit, @loan, @brand_config).deliver_now
         
        notice = t('microcredit.new_loan.will_receive_email', name: @brand_config["name"])
        notice += "<br/>" + t('microcredit.new_loan.tweet_campaign', main_url: @brand_config["main_url"], twitter_account: @brand_config["twitter_account"]) if @brand_config["twitter_account"]
        flash[:notice] = notice

        redirect_to microcredit_path(brand:@brand) and return if !params[:reload]
      end
    end
    render :new_loan
  end

  def renewal
    @microcredits_active = Microcredit.active
    @renewable = any_renewable?
  end

  def loans_renewal
    @microcredit = Microcredit.find(params[:id])
    @renewal = get_renewal
  end

  def loans_renew
    @microcredit = Microcredit.find(params[:id])
    @renewal = get_renewal(true)
    if @renewal.valid
      total_amount = 0
      MicrocreditLoan.transaction do
        @renewal.loan_renewals.each do |l|
          l.renew! @microcredit
          total_amount += l.amount
        end
      end
      if total_amount>0
        redirect_to loans_renewal_microcredit_loan_path(@microcredit.id, @renewal.loan.id, @renewal.loan.unique_hash), notice: t('microcredit.loans_renewal.renewal_success', name: @brand_config["name"], amount: number_to_euro(total_amount*100), campaign: @microcredit.title)
        return
      end
    end
    render :loans_renewal
  end

  def show_options
    @colors = ["#683064", "#6b478e", "#b052a9", "#c4a0d8"]
    @microcredit = Microcredit.find(params[:id])

    summary = @microcredit.options_summary
    @data_detail = summary[:data]
    @grand_total = summary[:grand_total]
  end

  private

  def loan_params
    if current_user
      params.require(:microcredit_loan).permit(:amount, :terms_of_service, :minimal_year_old, :iban_account, :iban_bic, :microcredit_option_id)
    else
      params.require(:microcredit_loan).permit(:first_name, :last_name, :document_vatid, :email, :address, :postal_code, :town, :province, :country, :amount, :terms_of_service, :minimal_year_old, :captcha, :captcha_key, :iban_account, :iban_bic, :microcredit_option_id)
    end
  end

  def get_renewal(validate = false)
    service = LoanRenewalService.new(@microcredit, params)
    service.build_renewal(
      loan_id: params[:loan_id],
      current_user: current_user,
      validate: validate
    )
  end

  def any_renewable?
    return false unless @microcredits_active

    if params[:loan_id]
      loan = MicrocreditLoan.find_by(id: params[:loan_id])
      loan && loan.unique_hash == params[:hash] && loan.microcredit.renewable?
    else
      current_user && current_user.any_microcredit_renewable?
    end
  end
end
