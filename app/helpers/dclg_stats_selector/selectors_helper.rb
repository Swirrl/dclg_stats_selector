module DclgStatsSelector
  module SelectorsHelper
    def dom_class_for_fragment(header_column)
      "fragment-#{header_column.fragment_code}"
    end
  
    def row_count(num_rows, max_shown)
      if (num_rows==1)
        return "Previewing the only row"
      end

      if (num_rows>max_shown)
        return "Previewing <strong>#{max_shown}</strong> of <strong>#{num_rows}</strong> rows"
      else
        return "Previewing #{num_rows} of #{num_rows} rows"
      end
    end

  end
end
