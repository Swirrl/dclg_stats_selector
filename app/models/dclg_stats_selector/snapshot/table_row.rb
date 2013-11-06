require 'forwardable'

module DclgStatsSelector
  class Snapshot
    class TableRow
      extend Forwardable
      include Enumerable

      attr_reader :uri, :secondary_uri

      def initialize(attributes)
        @observation_source = attributes.fetch(:observation_source)
        @labeller           = attributes.fetch(:labeller)

        row_uri  = attributes.fetch(:row_uri)
        if row_uri.is_a?(Array)
          @uri = row_uri.first 
          @secondary_uri = row_uri.last
        else
          @uri = row_uri
        end

        @cells    = map_dataset_descriptions_to_cells(
          attributes.fetch(:dataset_descriptions)
        )
      end

      def_delegator :@cells, :each

      def values
        map(&:value)
      end

      def label
        @labeller.label_for(@uri)
      end

      def secondary_label
        @labeller.label_for(@secondary_uri) if @secondary_uri
      end

      def to_h
        { row_uri: @uri, cells: @cells.map(&:to_h) }
      end

      private

      def map_dataset_descriptions_to_cells(descriptions)
        descriptions.map { |description|
          description.fetch(:cell_coordinates).map { |coords|
            TableCell.new(
              observation_source:   @observation_source,
              dataset_uri:          description.fetch(:dataset_uri),
              measure_property_uri: description.fetch(:measure_property_uri),
              row_uri:              @uri,
              cell_coordinates:     coords
            )
          }
        }.flatten
      end
    end
  end
end