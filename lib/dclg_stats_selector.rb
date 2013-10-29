require "dclg_stats_selector/engine"

require 'haml'
require 'jquery-rails'
require 'mongoid'

Dir[File.expand_path('../../app/models/concerns/**/*.rb', __FILE__)].each {|f| require f}

module DclgStatsSelector
end
