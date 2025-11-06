class UserVerificationsController < ApplicationController
  include Redirectable
  before_action :check_valid_and_verified, only: [:new, :create]

  def new
    @user_verification = UserVerification.for current_user
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params
    # if the validation was rejected, restart it
    #@user_verification.status = UserVerification.statuses[:paused] if current_user.autonomy_code == "c_14" # Euskadi convertir en parametro y sacarlo al formulario
    @user_verification.status = UserVerification.statuses[:pending] if @user_verification.rejected? or @user_verification.issues?
    @user_verification.status = UserVerification.statuses[:accepted_by_email] if current_user.photos_unnecessary?
    if @user_verification.save
      if @user_verification.wants_card
        redirect_to(edit_user_registration_path ,flash: { notice: [t('plebisbrand.user_verification.documentation_received'), t('plebisbrand.user_verification.please_check_details')].join("<br>")})
      else
        redirect_to(create_vote_path(election_id: params[:election_id])) and return if params[:election_id]
        redirect_to(session.delete(:return_to)||root_path, flash: { notice: t('plebisbrand.user_verification.documentation_received')})
      end
    else
      render :new
    end
  end

  def report
    @report = UserVerificationReportService.new(params[:report_code]).generate
  end

  def report_town
    @report_town = TownVerificationReportService.new(params[:report_code]).generate
  end

  def report_exterior
    @report_exterior = ExteriorVerificationReportService.new(params[:report_code]).generate
  end
  private
  def check_valid_and_verified
    if current_user.has_not_future_verified_elections?
      redirect_to(session.delete(:return_to)||root_path, flash: { notice: t('plebisbrand.user_verification.user_not_valid_to_verify') })
    elsif current_user.verified? && current_user.photos_necessary?
      redirect_to(session.delete(:return_to)||root_path, flash: { notice: t('plebisbrand.user_verification.user_already_verified') })
    end
  end
  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end
end
