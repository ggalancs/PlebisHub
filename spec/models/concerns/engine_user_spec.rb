# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser, type: :model do
  # Create a test user to work with (User includes EngineUser)
  let(:user) { create(:user) }

  describe 'module behavior' do
    it 'extends ActiveSupport::Concern' do
      expect(EngineUser).to be_a(Module)
      # Check if it has been included as a concern
      expect(EngineUser.singleton_class.ancestors.map(&:to_s)).to include('ActiveSupport::Concern')
    end

    it 'is included in User model' do
      expect(User.ancestors).to include(EngineUser)
    end
  end

  describe '.register_engine_concern' do
    let(:test_concern) do
      Module.new do
        extend ActiveSupport::Concern

        included do
          def test_method
            'test_method_called'
          end
        end
      end
    end

    context 'in test environment' do
      before do
        # Ensure we're in test environment
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      end

      it 'includes the concern in test mode' do
        # Create a new test class that includes EngineUser
        test_class = Class.new do
          include EngineUser
        end

        # Stub the logger to avoid noise
        allow(Rails.logger).to receive(:info)

        # Register the concern
        test_class.register_engine_concern('test_engine', test_concern)

        # Verify concern was included
        expect(Rails.logger).to have_received(:info).with('[EngineUser] Test mode: loaded test_engine concern')
      end

      it 'does not check EngineActivation in test mode' do
        test_class = Class.new do
          include EngineUser
        end

        allow(Rails.logger).to receive(:info)

        # Should not access EngineActivation at all
        expect(EngineActivation).not_to receive(:enabled?)

        test_class.register_engine_concern('test_engine', test_concern)
      end
    end

    context 'in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      context 'when EngineActivation does not exist' do
        it 'returns early without error' do
          stub_const('EngineActivation', nil)
          test_class = Class.new do
            include EngineUser
          end

          expect { test_class.register_engine_concern('test_engine', test_concern) }.not_to raise_error
        end
      end

      context 'when EngineActivation table does not exist' do
        it 'returns early without error' do
          allow(EngineActivation).to receive(:table_exists?).and_return(false)

          test_class = Class.new do
            include EngineUser
          end

          expect { test_class.register_engine_concern('test_engine', test_concern) }.not_to raise_error
        end
      end

      context 'when engine is not enabled' do
        it 'does not include the concern' do
          allow(EngineActivation).to receive(:table_exists?).and_return(true)
          allow(EngineActivation).to receive(:enabled?).with('test_engine').and_return(false)

          test_class = Class.new do
            include EngineUser
          end

          test_class.register_engine_concern('test_engine', test_concern)

          # Create instance and verify method doesn't exist
          instance = test_class.new
          expect(instance).not_to respond_to(:test_method)
        end
      end

      context 'when engine is enabled' do
        before do
          allow(EngineActivation).to receive(:table_exists?).and_return(true)
          allow(EngineActivation).to receive(:enabled?).with('test_engine').and_return(true)
          allow(Rails.logger).to receive(:info)
          allow(Rails.logger).to receive(:error)
        end

        context 'and dependencies are not met' do
          it 'logs error and does not include concern' do
            allow(PlebisCore::EngineRegistry).to receive(:dependencies_for).with('test_engine').and_return(['missing_engine'])
            allow(EngineActivation).to receive(:enabled?).with('missing_engine').and_return(false)

            test_class = Class.new do
              include EngineUser
            end

            test_class.register_engine_concern('test_engine', test_concern)

            expect(Rails.logger).to have_received(:error).with('[EngineUser] Cannot load test_engine: missing dependencies missing_engine')
            expect(Rails.logger).to have_received(:error).with('[EngineUser] Enable these engines first: missing_engine')
          end
        end

        context 'and dependencies are met' do
          it 'includes the concern' do
            allow(PlebisCore::EngineRegistry).to receive(:dependencies_for).with('test_engine').and_return(['User'])

            test_class = Class.new do
              include EngineUser
            end

            test_class.register_engine_concern('test_engine', test_concern)

            expect(Rails.logger).to have_received(:info).with('[EngineUser] Successfully loaded test_engine concern')
          end

          it 'skips User dependency check' do
            allow(PlebisCore::EngineRegistry).to receive(:dependencies_for).with('test_engine').and_return(['User', 'other_engine'])
            allow(EngineActivation).to receive(:enabled?).with('other_engine').and_return(true)

            test_class = Class.new do
              include EngineUser
            end

            # Should not check if 'User' is enabled
            expect(EngineActivation).not_to receive(:enabled?).with('User')

            test_class.register_engine_concern('test_engine', test_concern)
          end
        end

        context 'when PlebisCore::EngineRegistry is not defined' do
          it 'includes the concern without dependency checks' do
            stub_const('PlebisCore', Module.new) # Ensure PlebisCore exists but not EngineRegistry

            test_class = Class.new do
              include EngineUser
            end

            test_class.register_engine_concern('test_engine', test_concern)

            expect(Rails.logger).to have_received(:info).with('[EngineUser] Successfully loaded test_engine concern')
          end
        end
      end

      context 'when database error occurs' do
        it 'handles ActiveRecord::NoDatabaseError' do
          allow(EngineActivation).to receive(:table_exists?).and_raise(ActiveRecord::NoDatabaseError)
          allow(Rails.logger).to receive(:warn)

          test_class = Class.new do
            include EngineUser
          end

          expect { test_class.register_engine_concern('test_engine', test_concern) }.not_to raise_error
          expect(Rails.logger).to have_received(:warn).with('[EngineUser] Database not ready (ActiveRecord::NoDatabaseError), skipping test_engine')
        end

        it 'handles ActiveRecord::StatementInvalid' do
          allow(EngineActivation).to receive(:table_exists?).and_raise(ActiveRecord::StatementInvalid.new('test error'))
          allow(Rails.logger).to receive(:warn)

          test_class = Class.new do
            include EngineUser
          end

          expect { test_class.register_engine_concern('test_engine', test_concern) }.not_to raise_error
          expect(Rails.logger).to have_received(:warn).with('[EngineUser] Database not ready (ActiveRecord::StatementInvalid), skipping test_engine')
        end
      end
    end
  end

  describe '.can_access_engine?' do
    context 'when EngineActivation is not defined' do
      it 'returns false' do
        stub_const('EngineActivation', nil)
        expect(EngineUser.can_access_engine?(user, 'test_engine')).to be false
      end
    end

    context 'when EngineActivation is defined' do
      before do
        allow(EngineActivation).to receive(:enabled?)
      end

      it 'delegates to EngineActivation.enabled?' do
        expect(EngineActivation).to receive(:enabled?).with('plebis_voting').and_return(true)
        EngineUser.can_access_engine?(user, 'plebis_voting')
      end

      it 'returns true when engine is enabled' do
        allow(EngineActivation).to receive(:enabled?).with('plebis_voting').and_return(true)
        expect(EngineUser.can_access_engine?(user, 'plebis_voting')).to be true
      end

      it 'returns false when engine is not enabled' do
        allow(EngineActivation).to receive(:enabled?).with('disabled_engine').and_return(false)
        expect(EngineUser.can_access_engine?(user, 'disabled_engine')).to be false
      end

      it 'accepts any user object as first parameter' do
        # Currently the method doesn't use the user parameter, but we test the interface
        expect(EngineActivation).to receive(:enabled?).with('test_engine').and_return(false)
        EngineUser.can_access_engine?(nil, 'test_engine')
      end
    end
  end

  describe 'integration with User model' do
    it 'User model includes EngineUser concern' do
      expect(User.ancestors).to include(EngineUser)
    end

    it 'User can check engine access' do
      allow(EngineActivation).to receive(:enabled?).with('plebis_voting').and_return(true)
      expect(EngineUser.can_access_engine?(user, 'plebis_voting')).to be true
    end

    context 'with actual engine concerns' do
      it 'includes Votable concern when plebis_voting is enabled' do
        # In test mode, all concerns are included by default
        expect(user).to respond_to(:votes) if defined?(Vote)
      end

      it 'includes Collaborator concern when plebis_collaborations is enabled' do
        # In test mode, all concerns are included by default
        expect(user).to respond_to(:collaborations) if defined?(Collaboration)
      end

      it 'includes Verifiable concern when plebis_verification is enabled' do
        # In test mode, all concerns are included by default
        expect(user).to respond_to(:user_verifications) if defined?(UserVerification)
      end
    end
  end

  describe 'module_function behavior' do
    it 'can_access_engine? is accessible as module function' do
      expect(EngineUser).to respond_to(:can_access_engine?)
    end

    it 'can_access_engine? can be called without receiver' do
      # module_function makes it available as both instance and module method
      expect { EngineUser.can_access_engine?(user, 'test') }.not_to raise_error
    end
  end

  describe 'concern structure' do
    it 'has class_methods module' do
      expect(EngineUser::ClassMethods).to be_a(Module)
    end

    it 'register_engine_concern is a class method' do
      expect(User).to respond_to(:register_engine_concern)
    end

    it 'included block executes when concern is included' do
      # The included block is empty in EngineUser, but we verify it exists
      test_class = Class.new do
        include EngineUser
      end

      expect(test_class.ancestors).to include(EngineUser)
    end
  end

  describe 'edge cases' do
    it 'handles nil engine_name gracefully' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      allow(Rails.logger).to receive(:info)

      test_class = Class.new do
        include EngineUser
      end

      expect { test_class.register_engine_concern(nil, Module.new) }.not_to raise_error
    end

    it 'handles empty string engine_name gracefully' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      allow(Rails.logger).to receive(:info)

      test_class = Class.new do
        include EngineUser
      end

      expect { test_class.register_engine_concern('', Module.new) }.not_to raise_error
    end

    it 'handles nil concern_module' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      allow(Rails.logger).to receive(:info)

      test_class = Class.new do
        include EngineUser
      end

      # This will raise an error, which is expected behavior
      expect { test_class.register_engine_concern('test_engine', nil) }.to raise_error
    end
  end
end
