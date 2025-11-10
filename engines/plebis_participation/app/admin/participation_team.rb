ActiveAdmin.register PlebisParticipation::ParticipationTeam, as: "ParticipationTeam" do
  menu :parent => "Users"

  permit_params :name, :description, :active

  filter :name
  filter :active
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :active
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :active
      row :created_at
      row :updated_at
      row :users_count do |team|
        team.users.count
      end
    end
  end

  form do |f|
    f.inputs "Participation Team" do
      f.input :name
      f.input :description
      f.input :active
    end
    f.actions
  end
end
