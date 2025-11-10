# frozen_string_literal: true

module PlebisParticipation
  # ParticipationTeamsController - Manages Participation Action Teams
  #
  # Allows users to:
  # - View active teams
  # - Join teams
  # - Leave teams
  # - Update their participation data
  class ParticipationTeamsController < ApplicationController
    before_action :authenticate_user!

    def index
      @participation_teams = PlebisParticipation::ParticipationTeam.active
    end

    def join
      if params[:team_id].present?
        team = PlebisParticipation::ParticipationTeam.find_by(id: params[:team_id])

        unless team
          flash[:alert] = "El equipo solicitado no existe"
          redirect_to participation_teams_path
          return
        end

        unless current_user.participation_teams.include?(team)
          current_user.participation_teams << team
          flash[:notice] = "Te has unido al equipo #{team.name}"
        else
          flash[:alert] = "Ya eres miembro de este equipo"
        end
      else
        if current_user.update(participation_team_at: DateTime.now)
          flash[:notice] = "Te damos la bienvenida a los Equipos de Acción Participativa. En los próximos días nos pondremos en contacto contigo."
        else
          flash[:alert] = "Error al registrar tu solicitud. Por favor, inténtalo de nuevo."
        end
      end

      redirect_to participation_teams_path
    end

    def leave
      if params[:team_id].present?
        team = PlebisParticipation::ParticipationTeam.find_by(id: params[:team_id])

        unless team
          flash[:alert] = "El equipo solicitado no existe"
          redirect_to participation_teams_path
          return
        end

        if current_user.participation_teams.include?(team)
          current_user.participation_teams.delete(team)
          flash[:notice] = "Has abandonado el equipo #{team.name}"
        else
          flash[:alert] = "No eres miembro de este equipo"
        end
      else
        if current_user.update(participation_team_at: nil)
          flash[:notice] = "Te has dado de baja de los Equipos de Acción Participativa"
        else
          flash[:alert] = "Error al procesar tu solicitud. Por favor, inténtalo de nuevo."
        end
      end

      redirect_to participation_teams_path
    end

    def update_user
      if current_user.update(old_circle_data: user_params[:old_circle_data])
        flash[:notice] = "Datos actualizados correctamente"
      else
        flash[:alert] = "Error al actualizar los datos"
      end

      redirect_to participation_teams_path
    end

    private

    def user_params
      params.require(:user).permit(:old_circle_data)
    end
  end
end
