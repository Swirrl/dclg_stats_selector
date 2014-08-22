module DclgStatsSelector
  class FragmentsController < PublishMyData::ApplicationController
    before_filter :get_dataset, only:  [ :new, :create ]
    before_filter :get_selector, only: [ :datasets, :new, :create, :destroy ]
    before_filter :get_fragment, only: [ :destroy ]

    def datasets
      datasets = GeographyService.geographical_data_cubes(@selector.geography_type)
      @tree = filtered_tree(build_site_trees.first, datasets)

      respond_to do |format|
        format.html { render layout: false }
        format.js
      end
    end

    def new
      @dimensions = PublishMyData::DataCube::Cube.new(@dataset).dimension_objects
      @dimensions.reject! {|d| d.uri == 'http://opendatacommunities.org/def/ontology/geography/refArea'}

      respond_to do |format|
        format.js
      end
    end

    def create
      dimensions = dimensions_from_params(params[:dataset_dimensions])

      # The Data Cube spec permits multiple measures per observation:
      # http://www.w3.org/TR/vocab-data-cube/#dsd-mm-obs
      # PMD currently only supports one measure property in a cube,
      # so we currently just pick the first available. This sort of
      # policy shouldn't live in a controller, but we'd need to
      # restructure the code a lot to give it a proper home.
      measure_property_uri = ObservationSource.measure_property_uri(@dataset.uri)

      @selector.fragments.build(
        dataset_uri:          @dataset.uri.to_s,
        measure_property_uri: measure_property_uri,
        dimensions:           dimensions
      )

      if @selector.save
        redirect_to selector_path(@selector)
      end
    end

    def destroy
      @selector.fragments.delete(@fragment)

      if @selector.save
        redirect_to selector_path(@selector)
      end
    end

    private

    def get_dataset
      @dataset = PublishMyData::Dataset.find(params[:dataset_uri])
    end

    def get_selector
      @selector = Selector.find(params[:selector_id])
    end

    def get_fragment
      @fragment = @selector.fragments.find(params[:id])
    end

    def filtered_tree(tree, datasets)
      filtered_tree = tree.tree_node.dup
      # build an array of all nodes to be included in the filter
      filtered_nodes = datasets.reduce([]) do |memo, dataset|
        leaf = tree.find_node_with_uri(dataset.uri)
        if leaf
          nodes = leaf.parentage + [leaf]
          memo = memo | nodes
        end
        memo
      end
      filtered_tree.breadth_each do |node|
        node.remove_from_parent! unless filtered_nodes.include?(node)
      end
    end

    # Converts {dimension_uri => csv_dimension_value_data} to {dimension_uri => [dim_value_1, ...]}
    # and uses all dimension values for a dimension if none were provided
    def dimensions_from_params(dimension_params)
      dimension_params.reduce({}) do |dimensions, (dimension_uri, value_data)|
        dimension_values_provided = value_data.split(', ')

        dimension_values =
          if dimension_values_provided.present?
            dimension_values_provided
          else
            all_dimensions[dimension_uri]
          end

        dimensions.merge!(dimension_uri => dimension_values)
      end
    end

    def all_dimensions
      all_dimensions = params[:all_dataset_dimensions]
      all_dimensions.keys.reduce({}) do |dimensions_map, dimension_uri|
        dimensions_map[dimension_uri] = all_dimensions[dimension_uri].split(', ')
        dimensions_map
      end
    end
  end
end
