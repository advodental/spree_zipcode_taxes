Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :tax_rates do
      post :import_tax_rates, on: :collection
      resources :taxable_zipcodes, shallow: true
    end
  end
end