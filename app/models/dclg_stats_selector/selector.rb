module DclgStatsSelector
  class Selector
    include Mongoid::Document
    # include Persistence::ActiveModelInterface

    field :finished, type: Boolean, default: false
    field :row_uris, type: Array, default: []
    field :geography_type

    embeds_many :fragments, class_name: 'DclgStatsSelector::Fragment'

    def empty?
      fragments.empty?
    end

    # Convenience method to take a snapshot with all necessary dependencies.
    # If we had an Application Service layer, this would probably live there.
    def build_snapshot(options = {})
      observation_source  = ObservationSource.new
      labeller            = Labeller.new

      snapshot = Snapshot.new(
        observation_source: observation_source, labeller: labeller
      )
      take_snapshot(snapshot, observation_source, labeller, options)
      snapshot
    end

    def take_snapshot(snapshot, observation_source, labeller, options = {})
      row_uris = rows_uris_for_snapshot(options)

      observation_source.row_uris_detected(
        # The current version of the Stats Selector hard-codes this
        'http://opendatacommunities.org/def/ontology/geography/refArea',
        row_uris
      )
      snapshot.row_uris_detected(row_uris)
      row_uris.each do |row_uri|
        labeller.resource_detected(row_uri)
      end

      fragments.each do |fragment|
        fragment.inform_observation_source(observation_source)
        fragment.inform_snapshot(snapshot)
        fragment.inform_labeller(labeller)
      end

      nil
    end

    def finish!
      self.finished = true
      self.save
    end

    private

    def rows_uris_for_snapshot(options)
      row_limit = options.fetch(:row_limit, 0) - 1
      row_uris[0..row_limit]
    end
  end
end