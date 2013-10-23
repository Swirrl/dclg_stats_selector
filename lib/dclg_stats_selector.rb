require "dclg_stats_selector/engine"

require 'haml'
require 'jquery-rails'

module DclgStatsSelector
  mattr_accessor :stats_selector
  @@stats_selector = { }

  def self.configure
    yield self
  end
end
