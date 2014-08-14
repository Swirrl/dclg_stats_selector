DclgStatsSelector::Engine.routes.draw do
  resources :selectors, except: [:index] do
    member do
      get :finish
      get :download
      put :duplicate
      # get :create # so we can redirect here from the geo selector
    end

    collection do
      post :preview
    end

    resources :fragments, except: [:show, :index] do
      get :datasets, on: :collection
    end
  end
end
