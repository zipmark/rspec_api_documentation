Example::Application.routes.draw do
  resources :orders

  match "/docs" => Raddocs, :anchor => false
end
