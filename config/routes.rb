Rails.application.routes.draw do
  root 'pages#index'

  get 'about' => 'pages#about'
  get 'calculation' => 'calculation#calculate'
  get 'download' => 'calculation#export'
end
