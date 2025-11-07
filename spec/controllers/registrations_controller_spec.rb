# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
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
      expect(controller.class._process_action_callbacks.any? { |c|
        c.filter == :load_user_location
      }).to be true
    end
  end

  # ==================== USER ENUMERATION PROTECTION TESTS ====================

  describe 'POST #create - paranoid mode' do
    let!(:existing_user) { create(:user, email: 'existing@example.com', document_vatid: '87654321B') }

    context 'with duplicate email' do
      before do
        valid_user_attributes[:email] = existing_user.email
        valid_user_attributes[:email_confirmation] = existing_user.email
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(true)
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
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/registration_duplicate_email/))

        post :create, params: { user: valid_user_attributes }
      end

      it 'does not create new user' do
        expect {
          post :create, params: { user: valid_user_attributes }
        }.not_to change(User, :count)
      end
    end

    context 'with duplicate document_vatid' do
      before do
        valid_user_attributes[:document_vatid] = existing_user.document_vatid
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(true)
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
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/registration_duplicate_document/))

        post :create, params: { user: valid_user_attributes }
      end
    end

    context 'with invalid captcha' do
      before do
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_return(false)
      end

      it 'logs invalid captcha attempt' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/registration_invalid_captcha/))

        post :create, params: { user: valid_user_attributes }
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
        expect(Rails.logger).to receive(:error).with(a_string_matching(/load_user_location_error/))

        get :new

        expect(response).to be_successful
        expect(assigns(:user_location)).to eq({})
      end
    end

    context 'when registration fails unexpectedly' do
      before do
        allow_any_instance_of(User).to receive(:valid_with_captcha?).and_raise(StandardError.new('Unexpected error'))
      end

      it 'handles error and logs it' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/registration_create_error/))

        post :create, params: { user: valid_user_attributes }

        expect(response).to render_template(:new)
      end
    end

    context 'when QR code generation fails' do
      let(:user) { create(:user) }

      before do
        sign_in user
        allow(user).to receive(:can_show_qr?).and_return(true)
        allow(user).to receive(:qr_svg).and_raise(StandardError.new('QR error'))
      end

      it 'handles error gracefully' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/qr_code_generation_error/))

        get :qr_code

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
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/unauthorized_qr_access_attempt/))

        get :qr_code
      end
    end

    context 'when user cannot show QR' do
      let(:user) { create(:user) }

      before do
        sign_in user
        allow(user).to receive(:can_show_qr?).and_return(false)
      end

      it 'redirects to root' do
        get :qr_code

        expect(response).to redirect_to(root_path)
      end

      it 'logs unauthorized attempt' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/unauthorized_qr_access_attempt/))

        get :qr_code
      end
    end

    context 'when user can show QR' do
      let(:user) { create(:user) }
      let(:qr_svg) { '<svg>QR Code</svg>' }
      let(:expire_date) { 1.day.from_now }

      before do
        sign_in user
        allow(user).to receive(:can_show_qr?).and_return(true)
        allow(user).to receive(:qr_svg).and_return(qr_svg)
        allow(user).to receive(:qr_expire_date).and_return(expire_date)
      end

      it 'renders QR code' do
        get :qr_code

        expect(response).to be_successful
        expect(assigns(:svg)).to eq(qr_svg)
      end

      it 'logs QR code access' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/qr_code_accessed/))

        get :qr_code
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
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/vote_circle_changed/))

        patch :update, params: { user: { vote_circle_id: vote_circle.id, current_password: user.password } }
      end
    end

    context 'when vote_circle_id is invalid' do
      it 'redirects with error' do
        patch :update, params: { user: { vote_circle_id: 99999 } }

        expect(response).to redirect_to(edit_user_registration_path)
      end

      it 'logs invalid attempt' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_vote_circle_attempt/))

        patch :update, params: { user: { vote_circle_id: 99999 } }
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
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/account_deletion_request/))

      delete :destroy
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
        expect(Rails.logger).to receive(:error).with(a_string_matching(/account_deletion_error/))

        delete :destroy

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
      expect(user).to receive(:send_reset_password_instructions)

      post :recover_and_logout
    end

    it 'logs password recovery request' do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/password_recovery_from_profile/))

      post :recover_and_logout
    end

    it 'signs user out' do
      post :recover_and_logout

      expect(controller.current_user).to be_nil
    end

    context 'when recovery fails' do
      before do
        allow(user).to receive(:send_reset_password_instructions).and_raise(StandardError.new('Email error'))
      end

      it 'handles error gracefully' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/password_recovery_error/))

        post :recover_and_logout

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
          expect(Rails.logger).to receive(:error).with(a_string_matching(/regions_provinces_error/))

          get :regions_provinces, xhr: true
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

      expect(Rails.logger).to receive(:warn).with(a_string_matching(/"ip_address"/))

      get :qr_code
    end

    it 'logs with user agent' do
      user = create(:user)
      sign_in user

      expect(Rails.logger).to receive(:warn).with(a_string_matching(/"user_agent"/))

      get :qr_code
    end

    it 'logs with timestamp' do
      user = create(:user)
      sign_in user

      expect(Rails.logger).to receive(:warn).with(a_string_matching(/"timestamp"/))

      get :qr_code
    end

    it 'logs with controller name' do
      user = create(:user)
      sign_in user

      expect(Rails.logger).to receive(:warn).with(a_string_matching(/"controller":"registrations"/))

      get :qr_code
    end
  end

  # ==================== STRONG PARAMETERS TESTS ====================

  describe 'strong parameters' do
    context 'sign_up_params' do
      it 'permits safe attributes' do
        params = ActionController::Parameters.new(user: valid_user_attributes)

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
          allow(user).to receive(:verified?).and_return(true)
        end

        it 'returns true' do
          expect(controller.send(:locked_personal_data?)).to be true
        end
      end

      context 'when user is not verified' do
        let(:user) { create(:user) }

        before do
          sign_in user
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'returns false' do
          expect(controller.send(:locked_personal_data?)).to be false
        end
      end
    end
  end
end
