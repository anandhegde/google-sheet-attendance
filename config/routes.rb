Rails.application.routes.draw do
  
  get 'login', to: redirect('/auth/google_oauth2'), as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'home', to: 'home#show'
  get 'me', to: 'me#show', as: 'me'

  root to: "home#show"

  post 'update-work-sheet' => 'me#updateWorkSheet'
  post 'delete-employee' => 'me#deleteEmployee'
  get 'add-employee' => 'me#newEmployee'
  post 'add-employee' => 'me#addEmployee'
  get 'getEmployeeNames' => 'me#getEmployeeNames'

  get 'employee/new' => 'employee#new'
  post 'employee/new' => 'employee#addEmployee'
end