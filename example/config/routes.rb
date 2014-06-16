Rails.application.routes.draw do
  resources :orders

  mount Raddocs::App => "/docs", :anchor => false
end
