module DclgStatsSelector
  class SelectorsController < PublishMyData::ApplicationController

    before_filter :get_selector, only: [ :show, :download ]
    before_filter :crumbs

    rescue_from GeographyService::TooManyGSSCodesError, with: :too_many_gss_codes
    rescue_from GeographyService::TooManyGSSCodeTypesError, with: :mixed_gss_codes

    include PublishMyData::CrumbtrailRendering
    
    def new
    end

    def create
      (no_file_uploaded && return) unless params[:csv_upload]

      data = process_csv_upload(params[:csv_upload], { postcode: params[:postcode] })
      (invalid_upload && return) unless data

      @selector = Selector.create(
        geography_type:       data.fetch(:geography_type, 'http://opendatacommunities.org/def/geography#LSOA'),
        row_uris:             data.fetch(:gss_resource_uris),
        secondary_row_uris:   data.fetch(:secondary_resource_uris, nil)
      )

      redirect_to selector_path(@selector, imported: @selector.row_uris.count, not_imported: data.fetch(:non_gss_codes).join(','))
    end

    def show
      @snapshot = @selector.build_snapshot(row_limit: 10)

      if params[:imported]
        @imported_count = params[:imported].to_i
        @non_gss_codes = params[:not_imported].split(',')
      end
    end

    def download
      @selector = @selector.deep_copy
      snapshot = @selector.build_snapshot
      filename = "statistics"
      source_url = selector_url(@selector)
      output_builder = CSVBuilder.build(
        site_name:  PublishMyData.request_root,
        source_url: source_url,
        timestamp:  Time.now
      )
      snapshot.render(output_builder)

      response.headers['Content-Type'] = 'text/csv'
      response.headers['Content-Disposition'] = %'attachment; filename="#{filename}.csv"'
      render(text: output_builder.to_csv)
    end

    private

    def get_selector
      @selector = Selector.find(params[:id])
    end

    def process_csv_upload(upload, opts={})
      is_postcode_data = opts.fetch(:postcode, false)

      geography_service = GeographyService.new

      # The error handling used to live in the Selector, and I've preserved the
      # use of rescue_from for now, hence catching and raising an error within
      # the controller
      uri_candidates =
        begin
          CSV.read(upload.path).map(&:first)
        rescue ArgumentError, CSV::MalformedCSVError
          return nil
        end

      data = nil
      if is_postcode_data
        data = geography_service.uris_for_postcodes(uri_candidates)
        data.merge({ geography_type: 'http://opendatacommunities.org/def/geography#LSOA' })
      else
        data = geography_service.uris_and_geography_type_for_gss_codes(uri_candidates)
      end

      data
    end

    def crumbs
      initialize_empty_crumbtrail
      prepend_crumb(STATSELECTOR_DISPLAY_NAME, new_selector_path)
    end

    def invalid_upload
      flash.now[:error] = 'The uploaded file did not contain valid CSV data, please check and try again.'
      render :new, status: :bad_request
    end

    def mixed_gss_codes
      flash.now[:error] = 'The uploaded file should contain GSS codes at either LSOA or Local Authority level.'
      render :new, status: :bad_request
    end

    def too_many_gss_codes
      flash.now[:error] = 'The uploaded file contains more than 500 GSS codes, please reduce its size and try again.'
      render :new, status: :bad_request
    end

    def no_file_uploaded
      flash.now[:error] = 'Please provide a valid .csv or .txt file'
      render :new, status: :bad_request
    end

    def redirect_if_finished
      redirect_to selector_path(@selector) if @selector.finished
    end

    def redirect_unless_finished
      redirect_to edit_selector_path(@selector) unless @selector.finished
    end
  end
end
