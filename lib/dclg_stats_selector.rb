require "dclg_stats_selector/engine"

require 'haml'
require 'jquery-rails'
require 'mongoid'
require 'csv'

Dir[File.expand_path('../../app/models/concerns/**/*.rb', __FILE__)].each {|f| require f}

module DclgStatsSelector

  mattr_accessor :stats_selector_display_name
  @@stats_selector_display_name = 'Spreadsheet builder'

end