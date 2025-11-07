# frozen_string_literal: true

# CRITICAL FIX: Corrected class name from PlebisHubtionTeamsController to ParticipationTeamsController
# CRITICAL FIX: Changed from InheritedResources::Base to ApplicationController for Devise support
class ParticipationTeamsController < ApplicationController
  before_action :authenticate_user!

  def index
    # CRITICAL FIX: Corrected model name from PlebisHubtionTeam to ParticipationTeam
    @participation_teams = ParticipationTeam.active
  end

  def join
    if params[:team_id].present?
      # HIGH PRIORITY FIX: Use find_by instead of find to avoid raising exceptions
      team = ParticipationTeam.find_by(id: params[:team_id])

      unless team
        flash[:alert] = "El equipo solicitado no existe"
        redirect_to participation_teams_path
        return
      end

      # LOW PRIORITY FIX: Simplified boolean check and removed unnecessary save
      unless current_user.participation_teams.include?(team)
        current_user.participation_teams << team
        flash[:notice] = "Te has unido al equipo #{team.name}"
      else
        flash[:alert] = "Ya eres miembro de este equipo"
      end
    else
      # MEDIUM PRIORITY FIX: Check return value and provide feedback
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
      # HIGH PRIORITY FIX: Use find_by instead of find to avoid raising exceptions
      team = ParticipationTeam.find_by(id: params[:team_id])

      unless team
        flash[:alert] = "El equipo solicitado no existe"
        redirect_to participation_teams_path
        return
      end

      # LOW PRIORITY FIX: Simplified boolean check and removed unnecessary save
      if current_user.participation_teams.include?(team)
        current_user.participation_teams.delete(team)
        flash[:notice] = "Has abandonado el equipo #{team.name}"
      else
        flash[:alert] = "No eres miembro de este equipo"
      end
    else
      # MEDIUM PRIORITY FIX: Check return value and provide feedback
      if current_user.update(participation_team_at: nil)
        flash[:notice] = "Te has dado de baja de los Equipos de Acción Participativa"
      else
        flash[:alert] = "Error al procesar tu solicitud. Por favor, inténtalo de nuevo."
      end
    end

    redirect_to participation_teams_path
  end

  def update_user
    # HIGH PRIORITY FIX: Use strong parameters instead of direct params access
    if current_user.update(old_circle_data: user_params[:old_circle_data])
      flash[:notice] = "Datos actualizados correctamente"
    else
      flash[:alert] = "Error al actualizar los datos"
    end

    redirect_to participation_teams_path
  end

  private

  # HIGH PRIORITY FIX: Strong parameters to prevent mass assignment
  def user_params
    params.require(:user).permit(:old_circle_data)
  end
end
