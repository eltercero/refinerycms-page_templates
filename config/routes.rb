::Refinery::Application.routes.draw do
  scope(:path => 'refinery', :as => 'admin', :module => 'admin') do
    resources :page_templates, :only => :index do
      collection do
        post :update_positions
      end
    end
  end
end
