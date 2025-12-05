# frozen_string_literal: true

require 'rails_helper'

module PlebisParticipation
  RSpec.describe ParticipationTeamsController, type: :controller do
    routes { PlebisParticipation::Engine.routes }

    let(:user) { create(:user) }
    let(:team) { create(:participation_team) }

    before { sign_in user }

    describe 'authentication' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to sign in for index' do
          get :index
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'redirects to sign in for join' do
          post :join
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'redirects to sign in for leave' do
          post :leave
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'redirects to sign in for update_user' do
          patch :update_user, params: { user: { old_circle_data: 'data' } }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'GET #index' do
      let!(:active_team) { create(:participation_team) }
      let!(:inactive_team) { create(:participation_team, :inactive) }

      it 'loads active teams' do
        get :index
        expect(assigns(:participation_teams)).to include(active_team)
      end

      it 'does not load inactive teams' do
        get :index
        expect(assigns(:participation_teams)).not_to include(inactive_team)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #join' do
      context 'with team_id parameter' do
        context 'when team exists' do
          context 'when user is not a member' do
            it 'adds user to team' do
              expect do
                post :join, params: { team_id: team.id }
              end.to change { user.participation_teams.count }.by(1)
            end

            it 'sets success notice' do
              post :join, params: { team_id: team.id }
              expect(flash[:notice]).to include(team.name)
            end

            it 'redirects to participation_teams_path' do
              post :join, params: { team_id: team.id }
              expect(response).to redirect_to(participation_teams_path)
            end
          end

          context 'when user is already a member' do
            before { user.participation_teams << team }

            it 'does not add user again' do
              expect do
                post :join, params: { team_id: team.id }
              end.not_to change { user.participation_teams.count }
            end

            it 'sets alert message' do
              post :join, params: { team_id: team.id }
              expect(flash[:alert]).to eq('Ya eres miembro de este equipo')
            end

            it 'redirects to participation_teams_path' do
              post :join, params: { team_id: team.id }
              expect(response).to redirect_to(participation_teams_path)
            end
          end
        end

        context 'when team does not exist' do
          it 'sets alert message' do
            post :join, params: { team_id: 99999 }
            expect(flash[:alert]).to eq('El equipo solicitado no existe')
          end

          it 'redirects to participation_teams_path' do
            post :join, params: { team_id: 99999 }
            expect(response).to redirect_to(participation_teams_path)
          end
        end
      end

      context 'without team_id parameter' do
        it 'updates user participation_team_at timestamp' do
          expect do
            post :join
          end.to change { user.reload.participation_team_at }.from(nil)
        end

        it 'sets welcome notice' do
          post :join
          expect(flash[:notice]).to include('bienvenida')
        end

        it 'redirects to participation_teams_path' do
          post :join
          expect(response).to redirect_to(participation_teams_path)
        end

        context 'when update fails' do
          before do
            allow(user).to receive(:update).and_return(false)
            allow(controller).to receive(:current_user).and_return(user)
          end

          it 'sets alert message' do
            post :join
            expect(flash[:alert]).to eq('Error al registrar tu solicitud. Por favor, inténtalo de nuevo.')
          end
        end
      end
    end

    describe 'POST #leave' do
      context 'with team_id parameter' do
        context 'when user is a member' do
          before { user.participation_teams << team }

          it 'removes user from team' do
            expect do
              post :leave, params: { team_id: team.id }
            end.to change { user.participation_teams.count }.by(-1)
          end

          it 'sets success notice' do
            post :leave, params: { team_id: team.id }
            expect(flash[:notice]).to include(team.name)
          end

          it 'redirects to participation_teams_path' do
            post :leave, params: { team_id: team.id }
            expect(response).to redirect_to(participation_teams_path)
          end
        end

        context 'when user is not a member' do
          it 'sets alert message' do
            post :leave, params: { team_id: team.id }
            expect(flash[:alert]).to eq('No eres miembro de este equipo')
          end
        end

        context 'when team does not exist' do
          it 'sets alert message' do
            post :leave, params: { team_id: 99999 }
            expect(flash[:alert]).to eq('El equipo solicitado no existe')
          end

          it 'redirects to participation_teams_path' do
            post :leave, params: { team_id: 99999 }
            expect(response).to redirect_to(participation_teams_path)
          end
        end
      end

      context 'without team_id parameter' do
        before { user.update(participation_team_at: DateTime.now) }

        it 'clears user participation_team_at timestamp' do
          post :leave
          expect(user.reload.participation_team_at).to be_nil
        end

        it 'sets success notice' do
          post :leave
          expect(flash[:notice]).to include('dado de baja')
        end

        context 'when update fails' do
          before do
            allow(user).to receive(:update).and_return(false)
            allow(controller).to receive(:current_user).and_return(user)
          end

          it 'sets alert message' do
            post :leave
            expect(flash[:alert]).to eq('Error al procesar tu solicitud. Por favor, inténtalo de nuevo.')
          end
        end
      end
    end

    describe 'PATCH #update_user' do
      let(:circle_data) { 'Old circle information' }

      it 'updates user old_circle_data' do
        patch :update_user, params: { user: { old_circle_data: circle_data } }
        expect(user.reload.old_circle_data).to eq(circle_data)
      end

      it 'sets success notice' do
        patch :update_user, params: { user: { old_circle_data: circle_data } }
        expect(flash[:notice]).to eq('Datos actualizados correctamente')
      end

      it 'redirects to participation_teams_path' do
        patch :update_user, params: { user: { old_circle_data: circle_data } }
        expect(response).to redirect_to(participation_teams_path)
      end

      context 'when update fails' do
        before do
          allow(user).to receive(:update).and_return(false)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it 'sets alert message' do
          patch :update_user, params: { user: { old_circle_data: circle_data } }
          expect(flash[:alert]).to eq('Error al actualizar los datos')
        end
      end

      context 'parameter filtering' do
        it 'only permits old_circle_data' do
          patch :update_user, params: { user: { old_circle_data: circle_data, admin: true } }
          expect(user.reload.admin).to be_falsey
        end
      end
    end
  end
end
