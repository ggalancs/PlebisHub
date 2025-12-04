# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe VoteCircleType, type: :model do
    describe 'model structure' do
      it 'is an ApplicationRecord' do
        expect(VoteCircleType.ancestors).to include(ApplicationRecord)
      end

      it 'can be instantiated' do
        vote_circle_type = VoteCircleType.new
        expect(vote_circle_type).to be_a(VoteCircleType)
      end

      it 'can be created in database' do
        vote_circle_type = VoteCircleType.create
        expect(vote_circle_type).to be_persisted
      end

      it 'can be saved' do
        vote_circle_type = VoteCircleType.new
        expect(vote_circle_type.save).to be_truthy
      end

      it 'can be destroyed' do
        vote_circle_type = VoteCircleType.create
        expect { vote_circle_type.destroy }.to change(VoteCircleType, :count).by(-1)
      end
    end

    describe 'database operations' do
      it 'supports find operations' do
        created = VoteCircleType.create
        found = VoteCircleType.find(created.id)
        expect(found).to eq(created)
      end

      it 'supports all query' do
        VoteCircleType.create
        VoteCircleType.create
        expect(VoteCircleType.all.count).to be >= 2
      end

      it 'supports where queries' do
        type1 = VoteCircleType.create(id: 999_999)
        results = VoteCircleType.where(id: type1.id)
        expect(results).to include(type1)
      end

      it 'supports count operations' do
        initial_count = VoteCircleType.count
        VoteCircleType.create
        expect(VoteCircleType.count).to eq(initial_count + 1)
      end
    end

    describe 'table existence' do
      it 'has a table in the database' do
        expect(VoteCircleType.table_exists?).to be_truthy
      end

      it 'has correct table name' do
        expect(VoteCircleType.table_name).to eq('plebis_votes_vote_circle_types')
      end
    end
  end
end
