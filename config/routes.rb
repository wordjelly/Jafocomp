Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get 'search' => 'welcome#search'

  post 'results/multiple_results' => 'results#multiple_results'

  get 'download_sessions' => 'welcome#download_sessions'

  get 'poller_sessions' => 'welcome#poller_sessions'

  get 'poller_session' => 'welcome#poller_session'

  get 'crons' => 'welcome#crons'

  get 'queue' => 'welcome#queue'

  get 'exchange/:exchange' => 'welcome#exchange'

  put 'indicators/update_many' => 'indicators#update_many'

  get 'our_story' => "welcome#our_story"

  resources :results
  resources :visualizations
  resources :stocks
  resources :exchanges
  resources :indicators

  namespace :sitemap do 
    resources :sitemaps
  end

  get 'all_exchanges' => 'exchanges#all', as: "all_exchanges"
  post 'exchange_summary' => 'exchanges#summary', as: "exchange_summary"
  post 'exchange_download_history' => 'exchanges#exchange_download_history', as: 'exchange_download_history'

  
  get 'stocks/:id/with_stock/:primary_stock_id' => "stocks#show", as: "combination_entity"
  get 'stocks/:id/with_indicator/:indicator_id' => "stocks#show", as: "combination_indicator" 
  get 'stocks/:id/:trend_direction' => "stocks#show", as: "direction_entity"
  get 'stocks/:id/with_stock/:primary_stock_id/with_indicator/:indicator_id' => "stocks#show"
  get 'stocks/:id/with_exchange/:exchange_id' => "stocks#show"
  put 'force_create_index' => "stocks#force_create_index", as: "force_create_index"

  ################################
  ##
  ##
  ## ENTITY LOG ROUTES
  ##
  ##
  ################################
  get 'stock_ticks' => 'stocks#ticks', as: "stock_ticks"
  get 'stock_download_history' => 'stocks#download_history', as: "stock_download_history"
  get 'stock_errors' => 'stocks#errors', as: "stock_errors"
  get 'stock_poller_history' => 'stocks#poller_history', as: "stock_poller_history"
  ## then just rerun it and pray basically.
  post 'update_tick_verified' => 'stocks#update_tick_verified'
   
  

  ## for sitemap.
  get '/sitemap.xml.gz', to: redirect("https://storage.googleapis.com/algorini/sitemaps/sitemap.xml.gz", status: 301)
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
