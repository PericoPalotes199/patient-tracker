Rails.application.routes.draw do
  resources :residencies
  #Devise Users
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    invitations: "users/invitations",
    passwords: "users/passwords"
  }

  devise_scope :user do
    get 'payment_info' => 'users/registrations#payment_info'
    post 'pay' => 'users/registrations#pay'
  end

  # Users
  get 'users/new' => redirect('/users/sign_up')
  get 'users/sign_out' => redirect('/users/sign_in')
  get 'users/invitation' => redirect('/users')
  resources :users, except: [:new, :create]

  # Encounters
  get 'encounters/summary' => 'encounters#summary', as: :summary
  resources :encounters, except: [:edit, :update]

  mount StripeEvent::Engine, at: '/stripe_events'

  # (Almost) Static Pages
  get 'faq' => 'pages#faq', as: :faq
  get 'under-construction' => 'pages#under_construction'

  root 'pages#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
