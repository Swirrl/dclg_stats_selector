require "dclg_stats_selector/engine"

require 'haml'
require 'jquery-rails'
require 'mongoid'
require 'csv'

Dir[File.expand_path('../../app/models/concerns/**/*.rb', __FILE__)].each {|f| require f}

module DclgStatsSelector
end

STATSELECTOR_DISPLAY_NAME = "Stat Selector"