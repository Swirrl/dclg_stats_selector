# Dclg Stats Selector

This is the code that powers the stats selector service on http://opendatacommunities.org

It's a Rails Engine designed to work alongside http://github.com/Swirrl/publish_my_data.

Add it to your project by adding this line to your `Gemfile`:

`gem 'dclg_stats_selector', :git => 'git@github.com:Swirrl/dclg_stats_selector.git', :branch => 'master'`

and this line to `routes.rb`:

`mount DclgStatsSelector::Engine, at: "/"`

## Prerequesites

* PublishMyData Community Edition
* MongoDB (for storing selector-state)

## Licence

MIT-LICENSE.