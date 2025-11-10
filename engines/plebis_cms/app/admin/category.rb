ActiveAdmin.register PlebisCms::Category, as: "Category" do
  menu :parent => "Blog"
  permit_params :name, :slug

end
