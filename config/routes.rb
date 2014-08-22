DclgStatsSelector::Engine.routes.draw do
  resources :selectors, except: [:index, :edit, :update] do
    member do
      get :download
      # get :create # so we can redirect here from the geo selector
    end

    resources :fragments, except: [:show, :index] do
      get :datasets, on: :collection
    end
  end
end
