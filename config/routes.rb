Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get 'search' => 'welcome#search'

  post 'results/multiple_results' => 'results#multiple_results'

  get 'download_sessions' => 'welcome#download_sessions'

  get 'exchange/:exchange' => 'welcome#exchange'

  put 'indicators/update_many' => 'indicators#update_many'

  resources :results
  resources :visualizations
  resources :stocks
  resources :exchanges
  resources :indicators

  ## its better than nothing.
  ## lets see how it goes with this much first.
  get 'stocks/:id/with_stock/:primary_stock_id' => "stocks#show", as: "combination_entity"
  get 'stocks/:id/with_indicator/:indicator_id' => "stocks#show", as: "combination_indicator" 
  get 'stocks/:id/:trend_direction' => "stocks#show", as: "direction_entity"
  get 'stocks/:id/with_stock/:primary_stock_id/with_indicator/:indicator_id' => "stocks#show"
  get 'stocks/:id/with_exchange/:exchange_id' => "stocks#show"

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
