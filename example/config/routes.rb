Rails.application.routes.draw do
  resources :orders

  resources :uploads, :only => :create

  mount Raddocs::App => "/docs", :anchor => false
end
