class MilitantController < ActionController::Base
  #TODO : refactorize code and use API::V2Controller instead
  def get_militant_info
    @result = ""
    signature_service = UrlSignatureService.new
    url_verified, data = signature_service.verify_militant_url(request.original_url)

    if url_verified
      if params[:collaborate].present?
        current_user = User.find_by_id(params[:participa_user_id])
        @result = current_user.collaborator_for_militant? ? "1" : "0"
      else
        exemption = params[:exemption]
        current_user = User.find_by_id(params[:participa_user_id])
        if current_user
          current_user.update(exempt_from_payment: exemption)
          current_user.update(militant: current_user.still_militant?)
          current_user.process_militant_data
          @result = "OK#{exemption} #{data}"
        else
          @result = "UserError"
        end
      end
    else
      @result = "signatureError #{data}"
    end
  end
end