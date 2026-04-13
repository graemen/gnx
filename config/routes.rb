Rails.application.routes.draw do
  root "threads#index"

  resources :threads, only: [:index, :show, :new, :create] do
    resources :posts, only: [:create] do
      collection do
        post :preview
      end
    end
  end

  #get  "admin/login", to: "admin#login"
  #post "admin/authenticate", to: "admin#authenticate"
  #delete "admin/logout", to: "admin#logout"
  #get  "admin/posts/:id/edit", to: "admin#edit", as: :admin_edit_post
  #patch "admin/posts/:id", to: "admin#update", as: :admin_update_post
  #delete "admin/posts/:id", to: "admin#destroy", as: :admin_destroy_post

  post "theme", to: "themes#update", as: :update_theme

  get "up" => "rails/health#show", as: :rails_health_check
end
