# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserVerification Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:verifier_user) do
    user = create(:user)
    user.update_flag!(:verifier, true)
    user
  end
  let(:test_user) { create(:user) }
  let!(:pending_verification) { create(:user_verification, user: test_user, status: :pending) }
  let!(:accepted_verification) { create(:user_verification, :accepted, user: create(:user)) }
  let!(:rejected_verification) { create(:user_verification, :rejected, user: create(:user)) }
  let!(:issues_verification) { create(:user_verification, :issues, user: create(:user)) }
  let!(:discarded_verification) { create(:user_verification, :discarded, user: create(:user)) }
  let!(:paused_verification) { create(:user_verification, :paused, user: create(:user)) }
  let!(:accepted_by_email_verification) { create(:user_verification, :accepted_by_email, user: create(:user)) }

  before do
    # Stub Redis::Namespace class if not available
    unless defined?(Redis::Namespace)
      stub_const('Redis::Namespace', Class.new)
    end

    # Initialize Redis mock
    allow(Redis).to receive(:new).and_return(instance_double(Redis))
    allow(Redis::Namespace).to receive(:new).and_return(redis_double)
    $redis = redis_double
  end

  let(:redis_double) do
    double('Redis::Namespace',
           hkeys: [],
           hget: nil,
           hset: true,
           hdel: true)
  end

  describe 'GET /admin/user_verifications' do
    context 'as admin user' do
      before { sign_in admin_user }

      it 'displays the index page' do
        get admin_user_verifications_path
        expect(response).to have_http_status(:success)
        expect(response.body).not_to be_empty
      end

      it 'shows user verification records' do
        get admin_user_verifications_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'as verifier user' do
      before { sign_in verifier_user }

      it 'displays the index page for verifiers' do
        get admin_user_verifications_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'scopes' do
    before { sign_in admin_user }

    it 'filters all verifications' do
      get admin_user_verifications_path, params: { scope: 'all' }
      expect(response).to have_http_status(:success)
    end

    it 'filters pending verifications' do
      get admin_user_verifications_path, params: { scope: 'pending' }
      expect(response).to have_http_status(:success)
    end

    it 'filters accepted verifications' do
      get admin_user_verifications_path, params: { scope: 'accepted' }
      expect(response).to have_http_status(:success)
    end

    it 'filters accepted_by_email verifications' do
      get admin_user_verifications_path, params: { scope: 'accepted_by_email' }
      expect(response).to have_http_status(:success)
    end

    it 'filters issues verifications' do
      get admin_user_verifications_path, params: { scope: 'issues' }
      expect(response).to have_http_status(:success)
    end

    it 'filters rejected verifications' do
      get admin_user_verifications_path, params: { scope: 'rejected' }
      expect(response).to have_http_status(:success)
    end

    it 'filters discarded verifications' do
      get admin_user_verifications_path, params: { scope: 'discarded' }
      expect(response).to have_http_status(:success)
    end

    it 'filters paused verifications' do
      get admin_user_verifications_path, params: { scope: 'paused' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'filters' do
    before { sign_in admin_user }

    it 'filters by status' do
      get admin_user_verifications_path, params: { q: { status_eq: 0 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user email' do
      get admin_user_verifications_path, params: { q: { user_email_cont: test_user.email } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user first name' do
      get admin_user_verifications_path, params: { q: { user_first_name_cont: test_user.first_name } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user last name' do
      get admin_user_verifications_path, params: { q: { user_last_name_cont: test_user.last_name } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user document' do
      get admin_user_verifications_path, params: { q: { user_document_vatid_cont: 'PASS' } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/user_verifications/:id' do
    before { sign_in admin_user }

    it 'displays the show page' do
      get admin_user_verification_path(pending_verification)
      expect(response).to have_http_status(:success)
    end

    it 'shows verification details' do
      get admin_user_verification_path(accepted_verification)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/user_verifications/:id/edit' do
    before { sign_in admin_user }

    it 'displays the edit form' do
      get edit_admin_user_verification_path(pending_verification)
      expect(response).to have_http_status(:success)
    end

    it 'allows editing for verifiers' do
      sign_in verifier_user
      get edit_admin_user_verification_path(pending_verification)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT /admin/user_verifications/:id' do
    context 'as admin user' do
      before do
        sign_in admin_user
        allow(redis_double).to receive(:hget).with(:processing, pending_verification.id).and_return(
          "{author_id=>#{admin_user.id}, locked_at=>\"#{DateTime.now.utc.strftime('%d/%m/%Y %H|%M')}\"}"
        )
        allow(pending_verification).to receive(:active?).and_return(true)
        allow(pending_verification).to receive(:get_current_verifier).and_return(admin_user)
        allow(UserVerification).to receive(:find).and_return(pending_verification)
        allow(UserVerification).to receive(:pending).and_return(UserVerification.none)
      end

      context 'when accepting verification' do
        let(:update_params) do
          {
            user_verification: {
              status: 'accepted',
              comment: 'Verified'
            }
          }
        end

        before do
          allow(UserVerificationMailer).to receive(:on_accepted).and_return(double(deliver_now: true))
          allow(test_user).to receive(:update_flag!)
        end

        it 'updates the verification' do
          put admin_user_verification_path(pending_verification), params: update_params
          expect(response).to have_http_status(:redirect)
        end

        it 'sends acceptance email' do
          put admin_user_verification_path(pending_verification), params: update_params
          expect(UserVerificationMailer).to have_received(:on_accepted)
        end
      end

      context 'when rejecting verification' do
        let(:update_params) do
          {
            user_verification: {
              status: 'rejected',
              comment: 'Invalid document'
            }
          }
        end

        before do
          allow(UserVerificationMailer).to receive(:on_rejected).and_return(double(deliver_now: true))
        end

        it 'sends rejection email' do
          put admin_user_verification_path(pending_verification), params: update_params
          expect(UserVerificationMailer).to have_received(:on_rejected)
        end
      end

      context 'when verification is not active' do
        before do
          allow(pending_verification).to receive(:active?).and_return(false)
        end

        let(:update_params) do
          {
            user_verification: {
              status: 'accepted',
              comment: 'Test'
            }
          }
        end

        it 'redirects with error' do
          put admin_user_verification_path(pending_verification), params: update_params
          expect(response).to redirect_to(admin_user_verifications_path)
        end
      end
    end
  end

  describe 'GET /admin/user_verifications/get_first_free' do
    before { sign_in admin_user }

    context 'when pending verifications exist' do
      before do
        allow(redis_double).to receive(:hkeys).with(:processing).and_return([])
        allow(UserVerification).to receive(:pending).and_return(UserVerification.where(id: pending_verification.id))
        allow(User).to receive(:exists?).with(id: test_user.id).and_return(true)
      end

      it 'redirects to edit first pending verification' do
        get get_first_free_admin_user_verifications_path
        expect(response).to redirect_to(edit_admin_user_verification_path(pending_verification))
      end

      it 'sets verification in redis' do
        expect(redis_double).to receive(:hset).with(:processing, pending_verification.id, anything)
        get get_first_free_admin_user_verifications_path
      end
    end

    context 'when no pending verifications exist' do
      before do
        allow(redis_double).to receive(:hkeys).with(:processing).and_return([])
        allow(UserVerification).to receive(:pending).and_return(UserVerification.none)
      end

      it 'redirects to index with warning' do
        get get_first_free_admin_user_verifications_path
        expect(response).to redirect_to(admin_user_verifications_path)
      end
    end

    context 'when verification user does not exist' do
      let(:orphan_verification) { create(:user_verification, user_id: 99999, status: :pending) }

      before do
        allow(redis_double).to receive(:hkeys).with(:processing).and_return([])
        allow(UserVerification).to receive(:pending).and_return(
          double('relation', where: double('where_relation', order: orphan_verification))
        ).once
        allow(UserVerification).to receive(:pending).and_return(UserVerification.none).once
        allow(User).to receive(:exists?).with(id: 99999).and_return(false)
      end

      it 'handles verification with non-existent user' do
        expect_any_instance_of(UserVerification).to receive(:update).with(status: 5)
        get get_first_free_admin_user_verifications_path
      end
    end
  end

  describe 'GET /admin/user_verifications/:id/cancel_edition' do
    before { sign_in admin_user }

    it 'removes verification from redis' do
      expect(redis_double).to receive(:hget).with(:processing, pending_verification.id.to_s)
      expect(redis_double).to receive(:hdel).with(:processing, pending_verification.id.to_s)
      get cancel_edition_admin_user_verification_path(pending_verification)
    end

    it 'redirects to index' do
      get cancel_edition_admin_user_verification_path(pending_verification)
      expect(response).to redirect_to(admin_user_verifications_path)
    end
  end

  describe 'PATCH /admin/user_verifications/:id/rotate' do
    before do
      sign_in admin_user
      allow_any_instance_of(UserVerification).to receive(:rotate).and_return({})
      # Mock the attachment reprocessing
      attachment_double = instance_double(ActiveStorage::Attached::One)
      allow(attachment_double).to receive(:reprocess!)
      allow_any_instance_of(UserVerification).to receive(:front_vatid).and_return(attachment_double)
      allow_any_instance_of(UserVerification).to receive(:back_vatid).and_return(attachment_double)
    end

    it 'rotates front attachment' do
      patch rotate_admin_user_verification_path(pending_verification), params: {
        attachment: 'front',
        degrees: 90
      }
      expect(response).to have_http_status(:redirect)
    end

    it 'rotates back attachment' do
      patch rotate_admin_user_verification_path(pending_verification), params: {
        attachment: 'back',
        degrees: 180
      }
      expect(response).to have_http_status(:redirect)
    end

    it 'handles different rotation degrees' do
      [0, 90, 180, 270].each do |degrees|
        patch rotate_admin_user_verification_path(pending_verification), params: {
          attachment: 'front',
          degrees: degrees
        }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'GET /admin/user_verifications/:id/view_image' do
    before { sign_in admin_user }

    context 'with missing parameters' do
      it 'handles missing attachment parameter gracefully' do
        get view_image_admin_user_verification_path(pending_verification), params: {
          size: 'thumb'
        }
        expect(response).to have_http_status(:success)
      end

      it 'handles missing size parameter gracefully' do
        get view_image_admin_user_verification_path(pending_verification), params: {
          attachment: 'front'
        }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with valid parameters' do
      before do
        allow_any_instance_of(UserVerification).to receive(:front_vatid_file_name).and_return('test.jpg')
        allow_any_instance_of(UserVerification).to receive(:front_vatid).and_return(
          instance_double(ActiveStorage::Attached::One, path: nil)
        )
      end

      it 'handles front attachment request' do
        get view_image_admin_user_verification_path(pending_verification), params: {
          attachment: 'front',
          size: 'thumb'
        }
        expect(response).to have_http_status(:success)
      end

      it 'handles back attachment request' do
        allow_any_instance_of(UserVerification).to receive(:back_vatid_file_name).and_return('test.jpg')
        allow_any_instance_of(UserVerification).to receive(:back_vatid).and_return(
          instance_double(ActiveStorage::Attached::One, path: nil)
        )
        get view_image_admin_user_verification_path(pending_verification), params: {
          attachment: 'back',
          size: 'original'
        }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'controller methods' do
    before { sign_in admin_user }

    describe '#remove_redis_hash' do
      it 'removes verification from redis processing' do
        expect(redis_double).to receive(:hget).with(:processing, pending_verification.id.to_s)
        expect(redis_double).to receive(:hdel).with(:processing, pending_verification.id.to_s)
        get cancel_edition_admin_user_verification_path(pending_verification)
      end
    end

    describe '#clean_redis_hash' do
      context 'when verification exists and is not active' do
        before do
          allow(redis_double).to receive(:hkeys).with(:processing).and_return([pending_verification.id.to_s])
          allow(UserVerification).to receive(:find_by).with(id: pending_verification.id.to_s).and_return(pending_verification)
          allow(pending_verification).to receive(:active?).and_return(false)
          allow(UserVerification).to receive(:pending).and_return(UserVerification.none)
        end

        it 'removes from redis' do
          expect(redis_double).to receive(:hdel).with(:processing, pending_verification.id.to_s)
          get get_first_free_admin_user_verifications_path
        end
      end

      context 'when verification does not exist' do
        before do
          allow(redis_double).to receive(:hkeys).with(:processing).and_return([pending_verification.id.to_s])
          allow(UserVerification).to receive(:find_by).with(id: pending_verification.id.to_s).and_return(nil)
          allow(UserVerification).to receive(:pending).and_return(UserVerification.none)
        end

        it 'removes from redis' do
          expect(redis_double).to receive(:hdel).with(:processing, pending_verification.id.to_s)
          get get_first_free_admin_user_verifications_path
        end
      end
    end
  end

  describe 'permitted parameters' do
    context 'as admin user' do
      before do
        sign_in admin_user
        allow(redis_double).to receive(:hget).with(:processing, pending_verification.id).and_return(
          "{author_id=>#{admin_user.id}, locked_at=>\"#{DateTime.now.utc.strftime('%d/%m/%Y %H|%M')}\"}"
        )
        allow(pending_verification).to receive(:active?).and_return(true)
        allow(pending_verification).to receive(:get_current_verifier).and_return(admin_user)
        allow(UserVerification).to receive(:find).and_return(pending_verification)
        allow(UserVerification).to receive(:pending).and_return(UserVerification.none)
      end

      it 'permits status for admin' do
        put admin_user_verification_path(pending_verification), params: {
          user_verification: { status: 'accepted' }
        }
        expect(response).to have_http_status(:redirect)
      end

      it 'permits comment for admin' do
        put admin_user_verification_path(pending_verification), params: {
          user_verification: { status: 'accepted', comment: 'Admin comment' }
        }
        expect(response).to have_http_status(:redirect)
      end

      it 'permits user_id' do
        put admin_user_verification_path(pending_verification), params: {
          user_verification: { status: 'accepted', user_id: test_user.id }
        }
        expect(response).to have_http_status(:redirect)
      end

      it 'permits processed_at' do
        put admin_user_verification_path(pending_verification), params: {
          user_verification: { status: 'accepted', processed_at: Time.current }
        }
        expect(response).to have_http_status(:redirect)
      end

      it 'permits wants_card' do
        put admin_user_verification_path(pending_verification), params: {
          user_verification: { status: 'accepted', wants_card: true }
        }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'actions configuration' do
    before { sign_in admin_user }

    it 'allows index action' do
      get admin_user_verifications_path
      expect(response).to have_http_status(:success)
    end

    it 'allows show action' do
      get admin_user_verification_path(pending_verification)
      expect(response).to have_http_status(:success)
    end

    it 'allows edit action' do
      get edit_admin_user_verification_path(pending_verification)
      expect(response).to have_http_status(:success)
    end

    it 'allows update action' do
      allow(redis_double).to receive(:hget).with(:processing, pending_verification.id).and_return(
        "{author_id=>#{admin_user.id}, locked_at=>\"#{DateTime.now.utc.strftime('%d/%m/%Y %H|%M')}\"}"
      )
      allow(pending_verification).to receive(:active?).and_return(true)
      allow(pending_verification).to receive(:get_current_verifier).and_return(admin_user)
      allow(UserVerification).to receive(:find).and_return(pending_verification)
      allow(UserVerification).to receive(:pending).and_return(UserVerification.none)

      put admin_user_verification_path(pending_verification), params: {
        user_verification: { status: 'pending' }
      }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'sort order configuration' do
    before { sign_in admin_user }

    it 'applies default sort order' do
      get admin_user_verifications_path
      expect(response).to have_http_status(:success)
    end
  end
end
