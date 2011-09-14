::Refinery::Application.routes.draw do
  resources :page_templates, :only => [:index, :show]

  scope(:path => 'refinery', :as => 'admin', :module => 'admin') do
    resources :page_templates, :only => :index do
      member do
        get :page_parts
      end
      collection do
        post :update_positions
      end
    end
  end
end
