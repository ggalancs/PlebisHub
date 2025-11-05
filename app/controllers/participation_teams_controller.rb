class PlebisHubtionTeamsController < InheritedResources::Base
  	before_action :authenticate_user!

	def index
  		@participation_teams = PlebisHubtionTeam.active
  	end

	def join
		if params[:team_id]
			team = PlebisHubtionTeam.find(params[:team_id])
			if team and not current_user.participation_team.member? team
				current_user.participation_team << team
				current_user.save
			end
		else
			current_user.update_attribute(:participation_team_at, DateTime.now)
			flash[:notice] = "Te damos la bienvienida a los Equipos de Acción PlebisHubtiva. En los próximos días nos pondremos en contacto contigo."
		end			
		redirect_to participation_teams_path
	end

	def leave
		if params[:team_id]
			team = PlebisHubtionTeam.find(params[:team_id])
			if team and current_user.participation_team.member? team
				current_user.participation_team.delete(team)
				current_user.save
			end
		else
			current_user.update_attribute(:participation_team_at, nil)
			flash[:notice] = "Te has dado de baja de los Equipos de Acción PlebisHubtiva"
		end 
		redirect_to participation_teams_path
	end

	def update_user
		current_user.update_attribute :old_circle_data, params[:user][:old_circle_data]
		redirect_to participation_teams_path
	end
end
