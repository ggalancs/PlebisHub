# frozen_string_literal: true

require 'rails_helper'

module Gamification
  module Listeners
    RSpec.describe ProposalListener do
      let(:user) { create(:user) }
      let(:proposal) { create(:proposal, author: user) }
      let(:user_stats) { instance_double(UserStats) }

      before do
        allow(UserStats).to receive(:for_user).and_return(user_stats)
        allow(user_stats).to receive(:earn_points!)
        allow(BadgeAwarder).to receive(:check_and_award!)
      end

      describe 'POINTS_CONFIG' do
        it 'defines points for created event' do
          expect(described_class::POINTS_CONFIG[:created]).to eq(50)
        end

        it 'defines points for approved event' do
          expect(described_class::POINTS_CONFIG[:approved]).to eq(100)
        end

        it 'defines points for featured event' do
          expect(described_class::POINTS_CONFIG[:featured]).to eq(200)
        end

        it 'defines points for implemented event' do
          expect(described_class::POINTS_CONFIG[:implemented]).to eq(500)
        end

        it 'is frozen' do
          expect(described_class::POINTS_CONFIG).to be_frozen
        end
      end

      describe '.register!' do
        let(:event_bus) { EventBus.instance }

        before do
          event_bus.clear!
        end

        it 'subscribes to proposal.created event' do
          expect(event_bus).to receive(:subscribe).with('proposal.created', described_class.method(:on_proposal_created))
          described_class.register!
        end

        it 'subscribes to proposal.approved event' do
          expect(event_bus).to receive(:subscribe).with('proposal.approved', described_class.method(:on_proposal_approved))
          described_class.register!
        end

        it 'subscribes to proposal.featured event' do
          expect(event_bus).to receive(:subscribe).with('proposal.featured', described_class.method(:on_proposal_featured))
          described_class.register!
        end

        it 'subscribes to proposal.implemented event' do
          expect(event_bus).to receive(:subscribe).with('proposal.implemented', described_class.method(:on_proposal_implemented))
          described_class.register!
        end

        it 'registers all four events' do
          expect(event_bus).to receive(:subscribe).exactly(4).times
          described_class.register!
        end
      end

      describe '.on_proposal_created' do
        let(:event) { { user_id: user.id, proposal_id: proposal.id } }

        it 'finds the user' do
          expect(User).to receive(:find).with(user.id).and_return(user)
          described_class.on_proposal_created(event)
        end

        it 'gets user stats for the user' do
          expect(UserStats).to receive(:for_user).with(user).and_return(user_stats)
          described_class.on_proposal_created(event)
        end

        it 'awards correct points' do
          expect(user_stats).to receive(:earn_points!).with(
            50,
            hash_including(reason: 'Propuesta creada')
          )
          described_class.on_proposal_created(event)
        end

        it 'includes the proposal as source' do
          expect(user_stats).to receive(:earn_points!) do |points, options|
            expect(options[:source]).to be_a(Proposal)
            expect(options[:source].id).to eq(proposal.id)
          end
          described_class.on_proposal_created(event)
        end

        it 'checks and awards badges' do
          expect(BadgeAwarder).to receive(:check_and_award!).with(user)
          described_class.on_proposal_created(event)
        end

        it 'completes successfully' do
          expect { described_class.on_proposal_created(event) }.not_to raise_error
        end

        context 'when user does not exist' do
          let(:event) { { user_id: 999999, proposal_id: proposal.id } }

          it 'raises ActiveRecord::RecordNotFound' do
            expect { described_class.on_proposal_created(event) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context 'when proposal does not exist' do
          let(:event) { { user_id: user.id, proposal_id: 999999 } }

          it 'raises ActiveRecord::RecordNotFound' do
            expect { described_class.on_proposal_created(event) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe '.on_proposal_approved' do
        let(:event) { { proposal_id: proposal.id } }

        it 'finds the proposal' do
          expect(Proposal).to receive(:find).with(proposal.id).and_return(proposal)
          described_class.on_proposal_approved(event)
        end

        it 'gets user stats for the proposal author' do
          expect(UserStats).to receive(:for_user).with(proposal.author).and_return(user_stats)
          described_class.on_proposal_approved(event)
        end

        it 'awards correct points' do
          expect(user_stats).to receive(:earn_points!).with(
            100,
            hash_including(reason: 'Propuesta aprobada')
          )
          described_class.on_proposal_approved(event)
        end

        it 'includes the proposal as source' do
          expect(user_stats).to receive(:earn_points!) do |points, options|
            expect(options[:source]).to eq(proposal)
          end
          described_class.on_proposal_approved(event)
        end

        it 'checks and awards badges' do
          expect(BadgeAwarder).to receive(:check_and_award!).with(proposal.author)
          described_class.on_proposal_approved(event)
        end

        it 'completes successfully' do
          expect { described_class.on_proposal_approved(event) }.not_to raise_error
        end

        context 'when proposal does not exist' do
          let(:event) { { proposal_id: 999999 } }

          it 'raises ActiveRecord::RecordNotFound' do
            expect { described_class.on_proposal_approved(event) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe '.on_proposal_featured' do
        let(:event) { { proposal_id: proposal.id } }

        it 'finds the proposal' do
          expect(Proposal).to receive(:find).with(proposal.id).and_return(proposal)
          described_class.on_proposal_featured(event)
        end

        it 'gets user stats for the proposal author' do
          expect(UserStats).to receive(:for_user).with(proposal.author).and_return(user_stats)
          described_class.on_proposal_featured(event)
        end

        it 'awards correct points' do
          expect(user_stats).to receive(:earn_points!).with(
            200,
            hash_including(reason: 'Propuesta destacada')
          )
          described_class.on_proposal_featured(event)
        end

        it 'includes the proposal as source' do
          expect(user_stats).to receive(:earn_points!) do |points, options|
            expect(options[:source]).to eq(proposal)
          end
          described_class.on_proposal_featured(event)
        end

        it 'does not check badges' do
          expect(BadgeAwarder).not_to receive(:check_and_award!)
          described_class.on_proposal_featured(event)
        end

        it 'completes successfully' do
          expect { described_class.on_proposal_featured(event) }.not_to raise_error
        end

        context 'when proposal does not exist' do
          let(:event) { { proposal_id: 999999 } }

          it 'raises ActiveRecord::RecordNotFound' do
            expect { described_class.on_proposal_featured(event) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe '.on_proposal_implemented' do
        let(:event) { { proposal_id: proposal.id } }

        it 'finds the proposal' do
          expect(Proposal).to receive(:find).with(proposal.id).and_return(proposal)
          described_class.on_proposal_implemented(event)
        end

        it 'gets user stats for the proposal author' do
          expect(UserStats).to receive(:for_user).with(proposal.author).and_return(user_stats)
          described_class.on_proposal_implemented(event)
        end

        it 'awards correct points' do
          expect(user_stats).to receive(:earn_points!).with(
            500,
            hash_including(reason: '¡Propuesta implementada!')
          )
          described_class.on_proposal_implemented(event)
        end

        it 'includes the proposal as source' do
          expect(user_stats).to receive(:earn_points!) do |points, options|
            expect(options[:source]).to eq(proposal)
          end
          described_class.on_proposal_implemented(event)
        end

        it 'checks and awards badges' do
          expect(BadgeAwarder).to receive(:check_and_award!).with(proposal.author)
          described_class.on_proposal_implemented(event)
        end

        it 'completes successfully' do
          expect { described_class.on_proposal_implemented(event) }.not_to raise_error
        end

        context 'when proposal does not exist' do
          let(:event) { { proposal_id: 999999 } }

          it 'raises ActiveRecord::RecordNotFound' do
            expect { described_class.on_proposal_implemented(event) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe 'integration scenarios' do
        before do
          allow(UserStats).to receive(:for_user).and_call_original
          allow(BadgeAwarder).to receive(:check_and_award!)
        end

        it 'handles complete proposal lifecycle' do
          created_event = { user_id: user.id, proposal_id: proposal.id }
          approved_event = { proposal_id: proposal.id }
          featured_event = { proposal_id: proposal.id }
          implemented_event = { proposal_id: proposal.id }

          expect { described_class.on_proposal_created(created_event) }.not_to raise_error
          expect { described_class.on_proposal_approved(approved_event) }.not_to raise_error
          expect { described_class.on_proposal_featured(featured_event) }.not_to raise_error
          expect { described_class.on_proposal_implemented(implemented_event) }.not_to raise_error
        end

        it 'awards different points for different events' do
          points_awarded = []

          allow(UserStats).to receive(:for_user).and_return(user_stats)
          allow(user_stats).to receive(:earn_points!) do |points, _options|
            points_awarded << points
          end

          described_class.on_proposal_created({ user_id: user.id, proposal_id: proposal.id })
          described_class.on_proposal_approved({ proposal_id: proposal.id })
          described_class.on_proposal_featured({ proposal_id: proposal.id })
          described_class.on_proposal_implemented({ proposal_id: proposal.id })

          expect(points_awarded).to eq([50, 100, 200, 500])
        end

        it 'checks badges three times for full lifecycle' do
          allow(UserStats).to receive(:for_user).and_return(user_stats)
          expect(BadgeAwarder).to receive(:check_and_award!).exactly(3).times

          described_class.on_proposal_created({ user_id: user.id, proposal_id: proposal.id })
          described_class.on_proposal_approved({ proposal_id: proposal.id })
          described_class.on_proposal_featured({ proposal_id: proposal.id })
          described_class.on_proposal_implemented({ proposal_id: proposal.id })
        end
      end

      describe 'event payload variations' do
        it 'handles symbol keys in event' do
          event = { user_id: user.id, proposal_id: proposal.id }
          expect { described_class.on_proposal_created(event) }.not_to raise_error
        end

        it 'handles string keys in event' do
          event = { 'user_id' => user.id, 'proposal_id' => proposal.id }
          expect { described_class.on_proposal_created(event) }.not_to raise_error
        end

        it 'handles EventBus::Event object' do
          event_obj = EventBus::Event.new('proposal.created', { user_id: user.id, proposal_id: proposal.id })
          expect { described_class.on_proposal_created(event_obj) }.not_to raise_error
        end
      end
    end
  end
end
