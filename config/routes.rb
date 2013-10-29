DclgStatsSelector::Engine.routes.draw do
  resources :selectors, except: [:index] do
    post :preview, on: :collection
    get :finish, on: :member
    get :download, on: :member
    resources :fragments, except: [:show, :index] do
      get :datasets, on: :collection
    end
  end
end
