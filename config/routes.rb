Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    get '/' => 'api#root'

    post 'auth' => 'auth#post'
  end
end
