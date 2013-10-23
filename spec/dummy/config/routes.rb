Rails.application.routes.draw do
  mount DclgStatsSelector::Engine => "/"
  mount PublishMyData::Engine => "/"
end
