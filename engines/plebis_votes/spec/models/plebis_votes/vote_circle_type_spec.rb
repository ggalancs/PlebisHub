# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe VoteCircleType, type: :model do
    # ====================
    # LEGACY MODEL NOTICE
    # ====================
    # This model exists in engines/plebis_votes but has no corresponding table.
    # Tests are adjusted to document model existence and skip database operations.
    # ====================

    describe 'model structure' do
      it 'is defined as a class' do
        expect(VoteCircleType).to be_a(Class)
      end

      it 'is an ApplicationRecord subclass' do
        expect(VoteCircleType.ancestors).to include(ApplicationRecord)
      end

      it 'is within PlebisVotes module' do
        expect(VoteCircleType.name).to start_with('PlebisVotes::')
      end

      it 'responds to ActiveRecord class methods' do
        expect(VoteCircleType).to respond_to(:all)
        expect(VoteCircleType).to respond_to(:where)
        expect(VoteCircleType).to respond_to(:find_by)
        expect(VoteCircleType).to respond_to(:create)
      end
    end

    describe 'table configuration' do
      it 'has expected table name pattern' do
        expect(VoteCircleType.table_name).to eq('plebis_votes_vote_circle_types')
      end

      it 'table does not exist in database' do
        expect(VoteCircleType.table_exists?).to be_falsey
      end
    end

    describe 'model behavior without table' do
      it 'raises error when trying to instantiate without table' do
        expect { VoteCircleType.new }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it 'raises error when trying to create without table' do
        expect { VoteCircleType.create }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it 'raises error when querying without table' do
        expect { VoteCircleType.all.to_a }.to raise_error(ActiveRecord::StatementInvalid)
      end

      it 'raises error when counting without table' do
        expect { VoteCircleType.count }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    describe 'inheritance chain' do
      it 'inherits from ApplicationRecord' do
        expect(VoteCircleType.superclass).to eq(ApplicationRecord)
      end

      it 'includes ActiveRecord modules' do
        expect(VoteCircleType.ancestors).to include(ActiveRecord::Core)
        expect(VoteCircleType.ancestors).to include(ActiveRecord::Persistence)
      end
    end
  end
end
