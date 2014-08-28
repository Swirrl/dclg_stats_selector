module DclgStatsSelector
  module FragmentsHelper
    def dom_id_for_dimension_value(dimension_value, prefix=nil)
      uri_string = dimension_value[:label].downcase.gsub(' ', '-')
      prefix.blank? ? uri_string : "#{prefix}-#{uri_string}"
    end

    def column_count(dimensions)
      count = 1
      dimensions.each do |dimension|
        count = count * dimension.values.size
      end
      count
    end

    def group_datasets_by_theme(datasets, themes)
      grouped_datasets = datasets.group_by do |dataset|
        theme = themes.find {|t| t.uri == dataset.theme}
        theme.label
      end

      grouped_datasets.keys.each do |label|
        grouped_datasets[label] = grouped_datasets[label].map{ |dataset| [dataset.title, dataset.uri.to_s] }
      end

      grouped_datasets
    end

    def options_for_select_from_tree(tree)
      # build up a hash containing group names (>-separated folder paths)
      options = {}
      tree.each_leaf do |node|
        option = [node.content[:label], node.name] # label, URI
        opt_group = node.parentage.reverse.map{|n| n.content[:label]}.join(' > ')
        options[opt_group] ||= []
        options[opt_group] << option
        options
      end
      # now reduce our sensible hash to the grouped_options_for_select format
      options_as_array = options.reduce([]) do |memo, (key, value)|
        memo << [key, value]
      end
      grouped_options_for_select(options_as_array)
    end

    def choice_of_columns_available?(dimensions)
      !(dimensions.one? && dimensions.first.values.one?)
    end

  end
end
