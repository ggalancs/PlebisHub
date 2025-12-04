# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  let(:valid_user_attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@example.com',
      email_confirmation: 'john@example.com',
      password: 'Password123!',
      password_confirmation: 'Password123!',
      born_at: '1990-01-01',
      gender: 'male',
      document_type: 'nif',
      document_vatid: '12345678A',
      terms_of_service: '1',
      over_18: '1',
      address: '123 Main St',
      town: 'Madrid',
      province: 'Madrid',
      postal_code: '28001',
      country: 'ES',
      captcha: 'valid',
      captcha_key: 'test_key'
    }
  end

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to be_successful
    end
  end

  # ==================== DEPRECATED METHOD TESTS ====================

  describe 'deprecated method fix' do
    it 'uses prepend_before_action instead of prepend_before_filter' do
      # Check that the controller uses the modern Rails method
      expect(controller.class._process_action_callbacks.any? do |c|
        c.filter == :load_user_location
      end).to be true
    end
  end

  # ==================== USER ENUMERATION PROTECTION TESTS ====================

  describe 'POST #create - paranoid mode' do
    let!(:existing_user) { create(:user, email: 'existing@example.com', document_vatid: '87654321B') }

    context 'with duplicate email' do
      before do
        valid_user_attributes[:email] = existing_user.email
        valid_user_attributes[:email_confirmation] = existing_user.email
        # Rails 7.2: Mock captcha validation to bypass captcha check
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(true)
        allow_any_instance_of(SimpleCaptcha::ControllerHelpers).to receive(:simple_captcha_valid?).and_return(true)
      end

      it 'does not reveal user exists' do
        post :create, params: { user: valid_user_attributes }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('devise.registrations.signed_up_but_unconfirmed'))
      end

      it 'sends email to existing user' do
        expect(UsersMailer).to receive(:remember_email).with(:email, existing_user.email).and_call_original
        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)

        post :create, params: { user: valid_user_attributes }
      end

      it 'logs duplicate email attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        post :create, params: { user: valid_user_attributes }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/registration_duplicate_email/)).at_least(:once)
      end

      it 'does not create new user' do
        expect do
          post :create, params: { user: valid_user_attributes }
        end.not_to change(User, :count)
      end
    end

    context 'with duplicate document_vatid' do
      before do
        valid_user_attributes[:document_vatid] = existing_user.document_vatid
        # Rails 7.2: Mock captcha validation to bypass captcha check
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(true)
        allow_any_instance_of(SimpleCaptcha::ControllerHelpers).to receive(:simple_captcha_valid?).and_return(true)
      end

      it 'does not reveal user exists' do
        post :create, params: { user: valid_user_attributes }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('devise.registrations.signed_up_but_unconfirmed'))
      end

      it 'sends email to existing user' do
        expect(UsersMailer).to receive(:remember_email).with(:document_vatid, existing_user.document_vatid).and_call_original
        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)

        post :create, params: { user: valid_user_attributes }
      end

      it 'logs duplicate document attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        post :create, params: { user: valid_user_attributes }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/registration_duplicate_document/)).at_least(:once)
      end
    end

    context 'with invalid captcha' do
      before do
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(false)
      end

      it 'logs invalid captcha attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        post :create, params: { user: valid_user_attributes }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/registration_invalid_captcha/)).at_least(:once)
      end

      it 'renders new template' do
        post :create, params: { user: valid_user_attributes }

        expect(response).to render_template(:new)
      end
    end
  end

  # ==================== ERROR HANDLING TESTS ====================

  describe 'error handling' do
    context 'when load_user_location fails' do
      before do
        allow(User).to receive(:get_location).and_raise(StandardError.new('Location error'))
      end

      it 'handles error gracefully' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :new
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/load_user_location_error/)).at_least(:once)
        expect(response).to be_successful
        expect(assigns(:user_location)).to eq({})
      end
    end

    context 'when registration fails unexpectedly' do
      before do
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_raise(StandardError.new('Unexpected error'))
      end

      it 'handles error and logs it' do
        allow(Rails.logger).to receive(:error).and_call_original
        post :create, params: { user: valid_user_attributes }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/registration_create_error/)).at_least(:once)
        expect(response).to render_template(:new)
      end
    end

    context 'when QR code generation fails' do
      let(:user) { create(:user) }

      before do
        sign_in user
        allow_any_instance_of(User).to receive(:can_show_qr?).and_return(true)
        allow_any_instance_of(User).to receive(:qr_svg).and_raise(StandardError.new('QR error'))
      end

      it 'handles error gracefully' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :qr_code
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/qr_code_generation_error/)).at_least(:once)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe 'GET #qr_code' do
    context 'when user is not authenticated' do
      it 'redirects to root' do
        get :qr_code

        expect(response).to redirect_to(root_path)
      end

      it 'logs unauthorized attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :qr_code
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/unauthorized_qr_access_attempt/)).at_least(:once)
      end
    end

    context 'when user cannot show QR' do
      let(:user) { create(:user) }

      before do
        sign_in user
        allow_any_instance_of(User).to receive(:can_show_qr?).and_return(false)
      end

      it 'redirects to root' do
        get :qr_code

        expect(response).to redirect_to(root_path)
      end

      it 'logs unauthorized attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :qr_code
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/unauthorized_qr_access_attempt/)).at_least(:once)
      end
    end

    context 'when user can show QR' do
      let(:user) { create(:user) }
      let(:qr_svg) { '<svg>QR Code</svg>' }
      let(:expire_date) { 1.day.from_now }

      before do
        sign_in user
        allow_any_instance_of(User).to receive(:can_show_qr?).and_return(true)
        allow_any_instance_of(User).to receive(:qr_svg).and_return(qr_svg)
        allow_any_instance_of(User).to receive(:qr_expire_date).and_return(expire_date)
      end

      it 'renders QR code' do
        get :qr_code

        expect(response).to be_successful
        expect(assigns(:svg)).to eq(qr_svg)
      end

      it 'logs QR code access' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :qr_code
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/qr_code_accessed/)).at_least(:once)
      end
    end
  end

  # ==================== VOTE CIRCLE VALIDATION TESTS ====================

  describe 'validate_vote_circle' do
    let(:user) { create(:user) }
    let(:vote_circle) { create(:vote_circle) }

    before do
      sign_in user
    end

    context 'when vote_circle_id is valid' do
      it 'allows update' do
        patch :update, params: { user: { vote_circle_id: vote_circle.id } }

        expect(response).not_to have_http_status(:forbidden)
      end

      it 'logs vote_circle change' do
        allow(Rails.logger).to receive(:warn).and_call_original
        patch :update, params: { user: { vote_circle_id: vote_circle.id, current_password: user.password } }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/vote_circle_changed/)).at_least(:once)
      end
    end

    context 'when vote_circle_id is invalid' do
      it 'redirects with error' do
        patch :update, params: { user: { vote_circle_id: 99_999 } }

        expect(response).to redirect_to(edit_user_registration_path)
      end

      it 'logs invalid attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        patch :update, params: { user: { vote_circle_id: 99_999 } }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_vote_circle_attempt/)).at_least(:once)
      end
    end
  end

  # ==================== ACCOUNT DELETION TESTS ====================

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'logs account deletion request' do
      allow(Rails.logger).to receive(:warn).and_call_original
      delete :destroy
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/account_deletion_request/)).at_least(:once)
    end

    it 'sends cancellation email' do
      expect(UsersMailer).to receive(:cancel_account_email).with(user.id).and_call_original
      expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later)

      delete :destroy
    end

    context 'when deletion fails' do
      before do
        allow(UsersMailer).to receive(:cancel_account_email).and_raise(StandardError.new('Email error'))
      end

      it 'handles error gracefully' do
        allow(Rails.logger).to receive(:error).and_call_original
        delete :destroy
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/account_deletion_error/)).at_least(:once)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # ==================== PASSWORD RECOVERY TESTS ====================

  describe 'POST #recover_and_logout' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'sends password reset instructions' do
      expect_any_instance_of(User).to receive(:send_reset_password_instructions)

      post :recover_and_logout
    end

    it 'logs password recovery request' do
      allow(Rails.logger).to receive(:warn).and_call_original
      post :recover_and_logout
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/password_recovery_from_profile/)).at_least(:once)
    end

    it 'signs user out' do
      post :recover_and_logout

      expect(controller.current_user).to be_nil
    end

    context 'when recovery fails' do
      before do
        allow_any_instance_of(User).to receive(:send_reset_password_instructions).and_raise(StandardError.new('Email error'))
      end

      it 'handles error gracefully' do
        allow(Rails.logger).to receive(:error).and_call_original
        post :recover_and_logout
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/password_recovery_error/)).at_least(:once)
        expect(controller.current_user).to be_nil
      end
    end
  end

  # ==================== AJAX ENDPOINTS TESTS ====================

  describe 'AJAX endpoints' do
    before do
      allow(User).to receive(:get_location).and_return({
                                                         country: 'ES',
                                                         province: 'Madrid',
                                                         town: 'Madrid',
                                                         vote_province: 'Madrid',
                                                         vote_town: 'Madrid'
                                                       })
    end

    describe 'GET #regions_provinces' do
      it 'renders subregion_select partial' do
        get :regions_provinces, xhr: true

        expect(response).to be_successful
      end

      context 'when rendering fails' do
        before do
          allow(controller).to receive(:render).and_raise(StandardError.new('Render error'))
        end

        it 'handles error' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :regions_provinces, xhr: true
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/regions_provinces_error/)).at_least(:once)
        end
      end
    end

    describe 'GET #regions_municipies' do
      it 'renders municipies_select partial' do
        get :regions_municipies, xhr: true

        expect(response).to be_successful
      end
    end

    describe 'GET #vote_municipies' do
      it 'renders vote municipies_select partial' do
        get :vote_municipies, xhr: true

        expect(response).to be_successful
      end
    end
  end

  # ==================== SECURITY LOGGING TESTS ====================

  describe 'security logging' do
    it 'logs with IP address' do
      user = create(:user)
      sign_in user

      allow(Rails.logger).to receive(:warn).and_call_original
      get :qr_code
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/"ip_address"/)).at_least(:once)
    end

    it 'logs with user agent' do
      user = create(:user)
      sign_in user

      allow(Rails.logger).to receive(:warn).and_call_original
      get :qr_code
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/"user_agent"/)).at_least(:once)
    end

    it 'logs with timestamp' do
      user = create(:user)
      sign_in user

      allow(Rails.logger).to receive(:warn).and_call_original
      get :qr_code
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/"timestamp"/)).at_least(:once)
    end

    it 'logs with controller name' do
      user = create(:user)
      sign_in user

      allow(Rails.logger).to receive(:warn).and_call_original
      get :qr_code
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/"controller":"registrations"/)).at_least(:once)
    end
  end

  # ==================== STRONG PARAMETERS TESTS ====================

  describe 'strong parameters' do
    context 'sign_up_params' do
      it 'permits safe attributes' do
        controller.params = ActionController::Parameters.new(user: valid_user_attributes)

        expect(controller.send(:sign_up_params).keys).to include('email', 'password', 'first_name')
      end

      it 'does not permit admin field' do
        params = ActionController::Parameters.new(user: valid_user_attributes.merge(admin: true))
        controller.params = params

        expect(controller.send(:sign_up_params).keys).not_to include('admin')
      end

      it 'does not permit flags field' do
        params = ActionController::Parameters.new(user: valid_user_attributes.merge(flags: 999))
        controller.params = params

        expect(controller.send(:sign_up_params).keys).not_to include('flags')
      end
    end

    context 'account_update_params' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'permits safe attributes' do
        params = ActionController::Parameters.new(user: { email: 'new@example.com' })
        controller.params = params

        expect(controller.send(:account_update_params).keys).to include('email')
      end

      it 'does not permit admin field' do
        params = ActionController::Parameters.new(user: { email: 'new@example.com', admin: true })
        controller.params = params

        expect(controller.send(:account_update_params).keys).not_to include('admin')
      end
    end
  end

  # ==================== HELPER METHODS TESTS ====================

  describe 'helper methods' do
    describe '#locked_personal_data?' do
      context 'when user is verified' do
        let(:user) { create(:user) }

        before do
          sign_in user
          allow_any_instance_of(User).to receive(:verified?).and_return(true)
        end

        it 'returns true' do
          expect(controller.send(:locked_personal_data?)).to be true
        end
      end

      context 'when user is not verified' do
        let(:user) { create(:user) }

        before do
          sign_in user
          allow_any_instance_of(User).to receive(:verified?).and_return(false)
        end

        it 'returns false' do
          expect(controller.send(:locked_personal_data?)).to be false
        end
      end

      context 'when user is not logged in' do
        it 'returns false' do
          expect(controller.send(:locked_personal_data?)).to be_falsey
        end
      end
    end
  end

  # ==================== ADDITIONAL COVERAGE TESTS ====================

  describe 'POST #create - successful registration' do
    context 'with valid attributes and captcha' do
      before do
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(true)
        allow_any_instance_of(SimpleCaptcha::ControllerHelpers).to receive(:simple_captcha_valid?).and_return(true)
      end

      it 'logs successful registration when created' do
        # Since actual user creation may fail due to validations, just test the logging path
        allow_any_instance_of(User).to receive(:persisted?).and_return(true)
        allow_any_instance_of(User).to receive(:save).and_return(true)
        allow(Rails.logger).to receive(:warn).and_call_original

        post :create, params: { user: valid_user_attributes }

        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/user_registration_success/)).at_least(:once)
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'renders the edit template' do
      get :edit
      expect(response).to be_successful
    end

    it 'loads user location' do
      expect(User).to receive(:get_location).with(user, anything)
      get :edit
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    context 'with valid parameters' do
      it 'updates user attributes' do
        patch :update, params: { user: { address: '456 New St', current_password: 'Password123456' } }
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'without vote_circle_id' do
      it 'skips vote_circle validation' do
        # The before_action validate_vote_circle has `only: [:update]` but returns early if no vote_circle_id
        patch :update, params: { user: { address: '456 New St', current_password: 'Password123456' } }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#set_flash_message' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'sets flash message with resource params' do
      controller.params = ActionController::Parameters.new(user: { email: 'test@example.com' })
      controller.send(:set_flash_message, :notice, :updated)
      expect(flash[:notice]).to be_present
    end

    context 'when message is not present' do
      it 'does not set flash' do
        allow(controller).to receive(:find_message).and_return(nil)
        controller.params = ActionController::Parameters.new(user: { email: 'test@example.com' })
        flash.clear
        controller.send(:set_flash_message, :notice, :some_missing_key)
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'AJAX endpoints error handling' do
    describe 'GET #regions_municipies' do
      context 'when rendering fails' do
        before do
          allow(controller).to receive(:render).and_raise(StandardError.new('Render error'))
        end

        it 'handles error' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :regions_municipies, xhr: true
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/regions_municipies_error/)).at_least(:once)
        end
      end
    end

    describe 'GET #vote_municipies' do
      context 'when rendering fails' do
        before do
          allow(controller).to receive(:render).and_raise(StandardError.new('Render error'))
        end

        it 'handles error' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :vote_municipies, xhr: true
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/vote_municipies_error/)).at_least(:once)
        end
      end
    end
  end

  describe 'GET #qr_code - IDOR protection' do
    let(:user) { create(:user) }

    before do
      sign_in user
      allow_any_instance_of(User).to receive(:can_show_qr?).and_return(true)
    end

    context 'when user_id parameter is present' do
      it 'rejects request and logs IDOR attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :qr_code, params: { user_id: 999 }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/qr_idor_attempt/)).at_least(:once)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Unauthorized access')
      end
    end

    context 'when id parameter is present' do
      it 'rejects request and logs IDOR attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :qr_code, params: { id: 999 }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/qr_idor_attempt/)).at_least(:once)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Unauthorized access')
      end
    end
  end

  describe '#user_already_exists?' do
    let(:existing_user) { create(:user, email: 'existing@example.com', document_vatid: 'PASS87654321') }
    let(:new_user) { build(:user, email: existing_user.email) }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    it 'detects duplicate email' do
      new_user.validate
      _result, exists = controller.send(:user_already_exists?, new_user, :email)
      expect(exists).to be true
    end

    it 'removes taken error from resource' do
      new_user.validate
      expect(new_user.errors[:email]).not_to be_empty
      controller.send(:user_already_exists?, new_user, :email)
      # Error should be cleared or removed
      expect(new_user.errors[:email].join).not_to include('ya está en uso')
    end

    context 'when error checking fails' do
      it 'handles error gracefully' do
        allow(new_user.errors).to receive(:details).and_raise(StandardError.new('Error checking'))
        allow(Rails.logger).to receive(:error).and_call_original
        _result, exists = controller.send(:user_already_exists?, new_user, :email)
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/user_already_exists_error/)).at_least(:once)
        expect(exists).to be false
      end
    end
  end

  describe '#user_eligible_for_vote_circle?' do
    let(:user) { instance_double(User, vote_province: 'm_28', vote_town: 'm_28_079') }

    context 'when vote_circle does not respond to scope' do
      let(:vote_circle) { double('VoteCircle') }

      it 'returns true' do
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(false)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be true
      end
    end

    context 'when vote_circle scope is town' do
      it 'returns true for matching town' do
        vote_circle = double('VoteCircle', scope: 'town', town: 'm_28_079')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be true
      end

      it 'returns false for different town' do
        vote_circle = double('VoteCircle', scope: 'town', town: 'm_08_019')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be false
      end
    end

    context 'when vote_circle scope is province' do
      it 'returns true for matching province' do
        vote_circle = double('VoteCircle', scope: 'province', province_code: 'm_28')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be true
      end

      it 'returns false for different province' do
        vote_circle = double('VoteCircle', scope: 'province', province_code: 'm_08')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be false
      end
    end

    context 'when vote_circle scope is autonomy' do
      it 'returns true for matching autonomy' do
        # Use a real string that will respond to starts_with?
        user_with_prefix = instance_double(User, vote_town: 'm_28_079')
        allow(user_with_prefix).to receive(:vote_province).and_return('28_123')
        vote_circle = double('VoteCircle', scope: 'autonomy', autonomy_code: '28')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user_with_prefix, vote_circle)).to be true
      end

      it 'returns false for different autonomy' do
        # Use a real string that will respond to starts_with?
        user_with_prefix = instance_double(User, vote_town: 'm_28_079')
        allow(user_with_prefix).to receive(:vote_province).and_return('28_123')
        vote_circle = double('VoteCircle', scope: 'autonomy', autonomy_code: '08')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user_with_prefix, vote_circle)).to be false
      end
    end

    context 'when vote_circle scope is national' do
      it 'returns true for any user' do
        vote_circle = double('VoteCircle', scope: 'national')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be true
      end
    end

    context 'when vote_circle scope is unknown' do
      it 'returns true' do
        vote_circle = double('VoteCircle', scope: 'other')
        allow(vote_circle).to receive(:respond_to?).with(:scope).and_return(true)
        expect(controller.send(:user_eligible_for_vote_circle?, user, vote_circle)).to be true
      end
    end
  end

  describe 'validate_vote_circle - eligibility checks' do
    let(:user) { create(:user) }
    let(:vote_circle) { create(:vote_circle) }

    before do
      sign_in user
    end

    context 'when user is not eligible for vote_circle' do
      before do
        allow(controller).to receive(:user_eligible_for_vote_circle?).and_return(false)
      end

      it 'redirects with location mismatch error' do
        patch :update, params: { user: { vote_circle_id: vote_circle.id } }
        expect(response).to redirect_to(edit_user_registration_path)
        expect(flash[:alert]).to eq(I18n.t('errors.messages.vote_circle_location_mismatch'))
      end

      it 'logs unauthorized attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        patch :update, params: { user: { vote_circle_id: vote_circle.id } }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/unauthorized_vote_circle_attempt/)).at_least(:once)
      end
    end

    context 'when vote_circle validation raises error' do
      before do
        allow(VoteCircle).to receive(:find_by).and_raise(StandardError.new('DB error'))
      end

      it 'handles error gracefully' do
        allow(Rails.logger).to receive(:error).and_call_original
        patch :update, params: { user: { vote_circle_id: vote_circle.id } }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/validate_vote_circle_error/)).at_least(:once)
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end
  end

  describe 'account_update_params - dynamic permissions' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    context 'when user can change vote location' do
      before do
        allow_any_instance_of(User).to receive(:can_change_vote_location?).and_return(true)
      end

      it 'permits vote_province and vote_town' do
        params = ActionController::Parameters.new(user: { vote_province: 'p_28', vote_town: 'm_28_079' })
        controller.params = params
        result = controller.send(:account_update_params)
        expect(result.keys).to include('vote_province', 'vote_town')
      end
    end

    context 'when user cannot change vote location' do
      before do
        allow_any_instance_of(User).to receive(:can_change_vote_location?).and_return(false)
      end

      it 'does not permit vote_province and vote_town' do
        params = ActionController::Parameters.new(user: { vote_province: 'p_28', vote_town: 'm_28_079' })
        controller.params = params
        result = controller.send(:account_update_params)
        expect(result.keys).not_to include('vote_province', 'vote_town')
      end
    end

    context 'when personal data is not locked' do
      before do
        allow(controller).to receive(:locked_personal_data?).and_return(false)
      end

      it 'permits first_name, last_name, born_at' do
        params = ActionController::Parameters.new(user: { first_name: 'New', last_name: 'Name', born_at: '1990-01-01' })
        controller.params = params
        result = controller.send(:account_update_params)
        expect(result.keys).to include('first_name', 'last_name', 'born_at')
      end
    end

    context 'when personal data is locked' do
      before do
        allow(controller).to receive(:locked_personal_data?).and_return(true)
      end

      it 'does not permit first_name, last_name, born_at' do
        params = ActionController::Parameters.new(user: { first_name: 'New', last_name: 'Name', born_at: '1990-01-01' })
        controller.params = params
        result = controller.send(:account_update_params)
        expect(result.keys).not_to include('first_name', 'last_name', 'born_at')
      end
    end
  end

  describe 'AJAX endpoints with user restrictions' do
    describe 'GET #regions_provinces' do
      context 'when user can change vote location' do
        let(:user) { create(:user) }

        before do
          sign_in user
          allow_any_instance_of(User).to receive(:can_change_vote_location?).and_return(true)
          allow(User).to receive(:get_location).and_return({
                                                             country: 'ES',
                                                             province: 'Madrid',
                                                             town: 'Madrid'
                                                           })
        end

        it 'includes blocked provinces filter' do
          expect(User).to receive(:blocked_provinces)
          get :regions_provinces, xhr: true
        end
      end

      context 'when user cannot change vote location' do
        let(:user) { create(:user) }

        before do
          sign_in user
          allow_any_instance_of(User).to receive(:can_change_vote_location?).and_return(false)
          allow(User).to receive(:get_location).and_return({
                                                             country: 'ES',
                                                             province: 'Madrid',
                                                             town: 'Madrid'
                                                           })
        end

        it 'does not include blocked provinces filter' do
          expect(User).not_to receive(:blocked_provinces)
          get :regions_provinces, xhr: true
        end
      end

      context 'when no user is signed in' do
        before do
          allow(User).to receive(:get_location).and_return({
                                                             country: 'ES',
                                                             province: 'Madrid',
                                                             town: 'Madrid'
                                                           })
        end

        it 'includes blocked provinces filter' do
          expect(User).to receive(:blocked_provinces)
          get :regions_provinces, xhr: true
        end
      end
    end
  end
end
