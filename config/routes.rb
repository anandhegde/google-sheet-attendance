Rails.application.routes.draw do
  
  get 'login', to: redirect('/auth/google_oauth2'), as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  
  root to: "employee#show"
  post 'update-work-sheet' => 'employee#updateWorkSheet'
  post 'delete-employee' => 'employee#deleteEmployee'
  get 'getEmployeeNames' => 'employee#getEmployeeNames'
  get 'employee/new' => 'employee#new'
  post 'employee/new' => 'employee#addEmployee'
  get 'employee/:row_number' => 'employee#getEmployee'
  post 'employee/:row_number' => 'employee#updateEmployee'

  #admin routes
  get 'admin/privilege-users' => 'admin#new_privilege_users'
  post 'admin/privilege-users' => 'admin#add_privilege_users'
end