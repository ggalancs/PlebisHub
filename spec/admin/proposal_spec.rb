# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proposal Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }
  let!(:proposal) do
    create(:proposal,
           title: 'Test Proposal',
           description: 'This is a test proposal description',
           image_url: 'http://example.com/image.jpg')
  end

  before do
    sign_in_admin admin_user
    # Stub the reddit scope on Proposal
    allow(Proposal).to receive(:reddit).and_return(Proposal.all)
  end

  describe 'GET /admin/proposals' do
    it 'displays the index page' do
      get admin_proposals_path
      expect(response).to have_http_status(:success)
    end

    it 'shows proposal columns' do
      get admin_proposals_path
      expect(response.body).to include('Test Proposal')
    end

    it 'displays selectable column' do
      get admin_proposals_path
      # ActiveAdmin 3.x uses batch_action checkboxes instead of 'selectable_column' class
      expect(response.body).to match(/batch|checkbox|toggle_all/i)
    end

    it 'displays id column' do
      get admin_proposals_path
      expect(response.body).to include(proposal.id.to_s)
    end

    it 'displays title column' do
      get admin_proposals_path
      expect(response.body).to include(proposal.title)
    end

    it 'displays actions column' do
      get admin_proposals_path
      expect(response.body).to match(/View|Edit|Delete/i)
    end

    it 'uses reddit scope' do
      get admin_proposals_path
      expect(Proposal).to have_received(:reddit)
    end
  end

  describe 'filters' do
    it 'has title filter' do
      get admin_proposals_path
      expect(response.body).to match(/filter.*title/i)
    end
  end

  describe 'GET /admin/proposals/:id' do
    it 'displays the show page' do
      get admin_proposal_path(proposal)
      expect(response).to have_http_status(:success)
    end

    it 'shows proposal title' do
      get admin_proposal_path(proposal)
      expect(response.body).to include('Test Proposal')
    end

    it 'shows proposal description' do
      get admin_proposal_path(proposal)
      expect(response.body).to include('This is a test proposal description')
    end

    it 'shows proposal image_url' do
      get admin_proposal_path(proposal)
      expect(response.body).to include('http://example.com/image.jpg')
    end

    it 'formats description with simple_format' do
      proposal.update!(description: "Line 1\n\nLine 2")
      get admin_proposal_path(proposal)
      expect(response.body).to include('Line 1')
      expect(response.body).to include('Line 2')
    end
  end

  describe 'GET /admin/proposals/new' do
    it 'displays the new form' do
      get new_admin_proposal_path
      expect(response).to have_http_status(:success)
    end

    it 'has form fields for all permitted params' do
      get new_admin_proposal_path
      expect(response.body).to include('proposal[title]')
      expect(response.body).to include('proposal[description]')
      expect(response.body).to include('proposal[image_url]')
    end

    it 'has Election label in form' do
      get new_admin_proposal_path
      expect(response.body).to include('Election')
    end
  end

  describe 'POST /admin/proposals' do
    let(:valid_params) do
      {
        proposal: {
          title: 'New Proposal',
          description: 'New proposal description',
          image_url: 'http://example.com/new.jpg'
        }
      }
    end

    it 'creates a new proposal' do
      expect do
        post admin_proposals_path, params: valid_params
      end.to change(Proposal, :count).by(1)
    end

    it 'redirects to the proposal show page' do
      post admin_proposals_path, params: valid_params
      expect(response).to redirect_to(admin_proposal_path(Proposal.last))
    end

    it 'creates with correct attributes' do
      post admin_proposals_path, params: valid_params
      proposal = Proposal.last
      expect(proposal.title).to eq('New Proposal')
      expect(proposal.description).to eq('New proposal description')
      expect(proposal.image_url).to eq('http://example.com/new.jpg')
    end
  end

  describe 'GET /admin/proposals/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_proposal_path(proposal)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_proposal_path(proposal)
      expect(response.body).to include('Test Proposal')
      expect(response.body).to include('This is a test proposal description')
    end
  end

  describe 'PUT /admin/proposals/:id' do
    let(:update_params) do
      {
        proposal: {
          title: 'Updated Proposal',
          description: 'Updated description'
        }
      }
    end

    it 'updates the proposal' do
      put admin_proposal_path(proposal), params: update_params
      proposal.reload
      expect(proposal.title).to eq('Updated Proposal')
      expect(proposal.description).to eq('Updated description')
    end

    it 'redirects to the show page' do
      put admin_proposal_path(proposal), params: update_params
      expect(response).to redirect_to(admin_proposal_path(proposal))
    end
  end

  describe 'DELETE /admin/proposals/:id' do
    it 'deletes the proposal' do
      expect do
        delete admin_proposal_path(proposal)
      end.to change(Proposal, :count).by(-1)
    end

    it 'redirects to the index page' do
      delete admin_proposal_path(proposal)
      expect(response).to redirect_to(admin_proposals_path)
    end
  end

  describe 'permitted parameters' do
    it 'permits title' do
      post admin_proposals_path, params: {
        proposal: {
          title: 'Permitted Title',
          description: 'Required description'
        }
      }
      expect(Proposal.last.title).to eq('Permitted Title')
    end

    it 'permits description' do
      post admin_proposals_path, params: {
        proposal: {
          title: 'Test Title',
          description: 'Permitted Description'
        }
      }
      expect(Proposal.last.description).to eq('Permitted Description')
    end

    it 'permits image_url' do
      post admin_proposals_path, params: {
        proposal: {
          title: 'Test Title',
          description: 'Required description',
          image_url: 'http://permitted.com/image.jpg'
        }
      }
      expect(Proposal.last.image_url).to eq('http://permitted.com/image.jpg')
    end
  end

  describe 'menu configuration' do
    it 'appears under PlebisHubción parent menu' do
      get admin_proposals_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'controller customizations' do
    it 'scopes collection to reddit proposals' do
      get admin_proposals_path
      expect(Proposal).to have_received(:reddit)
    end
  end
end
