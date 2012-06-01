Example::Application.routes.draw do
  resources :orders

  match "/docs" => Raddocs::App, :anchor => false
end
