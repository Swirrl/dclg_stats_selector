Rails.application.routes.draw do

  mount DclgStatsSelector::Engine => "/dclg_stats_selector"
end
