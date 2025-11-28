# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisParticipation::ParticipationTeamsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:team) { create(:participation_team) }

  # Skip ApplicationController filters for isolation
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Setup Devise mapping for tests
    @request.env["devise.mapping"] = Devise.mappings[:user]

    # Define simple routes for testing
    @routes ||= ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get '/participation_teams' => 'participation_teams#index'
      post '/participation_teams/join' => 'participation_teams#join'
      post '/participation_teams/leave' => 'participation_teams#leave'
      patch '/participation_teams/update_user' => 'participation_teams#update_user'
    end
  end

  describe "GET #index" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not set instance variables" do
        get :index
        expect(assigns(:participation_teams)).to be_nil
      end
    end

    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns only active teams to @participation_teams" do
        active_team = create(:participation_team, active: true)
        inactive_team = create(:participation_team, :inactive)

        get :index

        expect(assigns(:participation_teams)).to include(active_team)
        expect(assigns(:participation_teams)).not_to include(inactive_team)
      end

      it "assigns empty array when no active teams exist" do
        create(:participation_team, :inactive)

        get :index

        expect(assigns(:participation_teams)).to be_empty
      end
    end
  end

  describe "POST #join" do
    before do
      sign_in user
    end

    context "when team_id is provided" do
      context "with valid team_id" do
        it "adds user to the team" do
          expect {
            post :join, params: { team_id: team.id }
          }.to change { user.participation_teams.count }.by(1)

          expect(user.participation_teams).to include(team)
        end

        it "sets success flash message" do
          post :join, params: { team_id: team.id }
          expect(flash[:notice]).to eq("Te has unido al equipo #{team.name}")
        end

        it "redirects to participation_teams_path" do
          post :join, params: { team_id: team.id }
          expect(response).to redirect_to(participation_teams_path)
        end

        context "when user is already a member" do
          before do
            user.participation_teams << team
          end

          it "does not add user to team again" do
            expect {
              post :join, params: { team_id: team.id }
            }.not_to change { user.participation_teams.count }
          end

          it "sets alert flash message" do
            post :join, params: { team_id: team.id }
            expect(flash[:alert]).to eq("Ya eres miembro de este equipo")
          end
        end
      end

      context "with invalid team_id (HIGH PRIORITY FIX)" do
        it "does not raise exception" do
          expect {
            post :join, params: { team_id: 99999 }
          }.not_to raise_error
        end

        it "sets alert flash message" do
          post :join, params: { team_id: 99999 }
          expect(flash[:alert]).to eq("El equipo solicitado no existe")
        end

        it "does not add any team to user" do
          expect {
            post :join, params: { team_id: 99999 }
          }.not_to change { user.participation_teams.count }
        end

        it "redirects to participation_teams_path" do
          post :join, params: { team_id: 99999 }
          expect(response).to redirect_to(participation_teams_path)
        end
      end

      context "with non-numeric team_id" do
        it "handles gracefully" do
          expect {
            post :join, params: { team_id: "invalid" }
          }.not_to raise_error
        end

        it "sets alert flash message" do
          post :join, params: { team_id: "invalid" }
          expect(flash[:alert]).to eq("El equipo solicitado no existe")
        end
      end
    end

    context "when team_id is not provided (general signup)" do
      it "updates user's participation_team_at timestamp" do
        freeze_time do
          post :join

          expect(user.reload.participation_team_at).to be_within(1.second).of(DateTime.now)
        end
      end

      it "sets success flash message" do
        post :join
        expect(flash[:notice]).to eq("Te damos la bienvenida a los Equipos de Acción Participativa. En los próximos días nos pondremos en contacto contigo.")
      end

      it "redirects to participation_teams_path" do
        post :join
        expect(response).to redirect_to(participation_teams_path)
      end

      context "when update fails (MEDIUM PRIORITY FIX)" do
        before do
          allow(user).to receive(:update).and_return(false)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "sets alert flash message" do
          post :join
          expect(flash[:alert]).to eq("Error al registrar tu solicitud. Por favor, inténtalo de nuevo.")
        end
      end
    end
  end

  describe "POST #leave" do
    before do
      sign_in user
    end

    context "when team_id is provided" do
      context "when user is a member of the team" do
        before do
          user.participation_teams << team
        end

        it "removes user from the team" do
          expect {
            post :leave, params: { team_id: team.id }
          }.to change { user.participation_teams.count }.by(-1)

          expect(user.participation_teams).not_to include(team)
        end

        it "sets success flash message" do
          post :leave, params: { team_id: team.id }
          expect(flash[:notice]).to eq("Has abandonado el equipo #{team.name}")
        end

        it "redirects to participation_teams_path" do
          post :leave, params: { team_id: team.id }
          expect(response).to redirect_to(participation_teams_path)
        end
      end

      context "when user is not a member of the team" do
        it "does not change user's teams" do
          expect {
            post :leave, params: { team_id: team.id }
          }.not_to change { user.participation_teams.count }
        end

        it "sets alert flash message" do
          post :leave, params: { team_id: team.id }
          expect(flash[:alert]).to eq("No eres miembro de este equipo")
        end
      end

      context "with invalid team_id (HIGH PRIORITY FIX)" do
        it "does not raise exception" do
          expect {
            post :leave, params: { team_id: 99999 }
          }.not_to raise_error
        end

        it "sets alert flash message" do
          post :leave, params: { team_id: 99999 }
          expect(flash[:alert]).to eq("El equipo solicitado no existe")
        end

        it "redirects to participation_teams_path" do
          post :leave, params: { team_id: 99999 }
          expect(response).to redirect_to(participation_teams_path)
        end
      end
    end

    context "when team_id is not provided (general opt-out)" do
      before do
        user.update(participation_team_at: DateTime.now)
      end

      it "sets participation_team_at to nil" do
        post :leave

        expect(user.reload.participation_team_at).to be_nil
      end

      it "sets success flash message" do
        post :leave
        expect(flash[:notice]).to eq("Te has dado de baja de los Equipos de Acción Participativa")
      end

      it "redirects to participation_teams_path" do
        post :leave
        expect(response).to redirect_to(participation_teams_path)
      end

      context "when update fails (MEDIUM PRIORITY FIX)" do
        before do
          allow(user).to receive(:update).and_return(false)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it "sets alert flash message" do
          post :leave
          expect(flash[:alert]).to eq("Error al procesar tu solicitud. Por favor, inténtalo de nuevo.")
        end
      end
    end
  end

  describe "PATCH #update_user" do
    before do
      sign_in user
    end

    context "with valid parameters" do
      let(:valid_params) { { user: { old_circle_data: "Some circle data" } } }

      it "updates user's old_circle_data" do
        patch :update_user, params: valid_params

        expect(user.reload.old_circle_data).to eq("Some circle data")
      end

      it "sets success flash message" do
        patch :update_user, params: valid_params
        expect(flash[:notice]).to eq("Datos actualizados correctamente")
      end

      it "redirects to participation_teams_path" do
        patch :update_user, params: valid_params
        expect(response).to redirect_to(participation_teams_path)
      end
    end

    context "when update fails (MEDIUM PRIORITY FIX)" do
      before do
        allow(user).to receive(:update).and_return(false)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "sets alert flash message" do
        patch :update_user, params: { user: { old_circle_data: "data" } }
        expect(flash[:alert]).to eq("Error al actualizar los datos")
      end

      it "redirects to participation_teams_path" do
        patch :update_user, params: { user: { old_circle_data: "data" } }
        expect(response).to redirect_to(participation_teams_path)
      end
    end
  end

  describe "security: strong parameters (HIGH PRIORITY FIX)" do
    before do
      sign_in user
    end

    it "only permits old_circle_data attribute" do
      # Attempt to update other attributes via mass assignment
      malicious_params = {
        user: {
          old_circle_data: "allowed data",
          admin: true,  # Should be blocked
          email: "hacker@example.com"  # Should be blocked
        }
      }

      patch :update_user, params: malicious_params

      user.reload
      expect(user.old_circle_data).to eq("allowed data")
      expect(user.admin).not_to eq(true)
      expect(user.email).not_to eq("hacker@example.com")
    end

    it "raises error when user parameter is missing" do
      expect {
        patch :update_user, params: { old_circle_data: "data" }
      }.to raise_error(ActionController::ParameterMissing)
    end
  end

  describe "authentication" do
    context "when user is not signed in" do
      it "redirects to sign in for index" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to sign in for join" do
        post :join
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to sign in for leave" do
        post :leave
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to sign in for update_user" do
        patch :update_user, params: { user: { old_circle_data: "data" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "edge cases" do
    before do
      sign_in user
    end

    context "when params are empty strings" do
      it "handles empty team_id in join" do
        expect {
          post :join, params: { team_id: "" }
        }.not_to raise_error
      end

      it "handles empty team_id in leave" do
        expect {
          post :leave, params: { team_id: "" }
        }.not_to raise_error
      end
    end

    context "when params are nil" do
      it "handles nil team_id in join (general signup)" do
        post :join, params: { team_id: nil }
        expect(user.reload.participation_team_at).not_to be_nil
      end

      it "handles nil team_id in leave (general opt-out)" do
        user.update(participation_team_at: DateTime.now)
        post :leave, params: { team_id: nil }
        expect(user.reload.participation_team_at).to be_nil
      end
    end

    context "when team is inactive" do
      let(:inactive_team) { create(:participation_team, :inactive) }

      it "can still join inactive team (business logic may want to prevent this)" do
        post :join, params: { team_id: inactive_team.id }
        expect(user.participation_teams).to include(inactive_team)
      end

      it "can leave inactive team" do
        user.participation_teams << inactive_team
        post :leave, params: { team_id: inactive_team.id }
        expect(user.participation_teams).not_to include(inactive_team)
      end
    end

    context "when database operations fail" do
      it "handles join failure gracefully" do
        allow_any_instance_of(ActiveRecord::Associations::CollectionProxy)
          .to receive(:<<).and_raise(ActiveRecord::RecordInvalid)

        expect {
          post :join, params: { team_id: team.id }
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "CRITICAL FIX: class name correction" do
    it "uses correct controller class name ParticipationTeamsController" do
      expect(controller.class.name).to eq("ParticipationTeamsController")
      expect(controller.class.name).not_to eq("PlebisHubtionTeamsController")
    end

    it "uses correct model class name ParticipationTeam" do
      get :index

      teams = assigns(:participation_teams)
      expect(teams.model.name).to eq("ParticipationTeam")
    end
  end

  describe "performance: database efficiency (LOW PRIORITY FIX)" do
    before do
      sign_in user
    end

    it "does not call save after association modification in join" do
      # Rails handles association saves automatically
      expect(user).not_to receive(:save)

      post :join, params: { team_id: team.id }
    end

    it "does not call save after association modification in leave" do
      user.participation_teams << team

      # Rails handles association saves automatically
      expect(user).not_to receive(:save)

      post :leave, params: { team_id: team.id }
    end
  end
end
