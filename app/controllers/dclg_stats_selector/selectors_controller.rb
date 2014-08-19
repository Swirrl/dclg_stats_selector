module DclgStatsSelector
  class SelectorsController < PublishMyData::ApplicationController
    before_filter :get_selector, only: [ :edit, :finish, :show, :download, :duplicate, :destroy ]
    before_filter :redirect_if_finished, only: [ :edit ]
    before_filter :redirect_unless_finished, only: [ :show, :download ]
    before_filter :crumbs

    rescue_from GeographyService::TooManyGSSCodesError, with: :too_many_gss_codes
    rescue_from GeographyService::TooManyGSSCodeTypesError, with: :mixed_gss_codes

    include PublishMyData::CrumbtrailRendering

    def new
    end

    def preview
      (no_file_uploaded && return) unless params[:csv_upload].present?

      geography_service = GeographyService.new

      # The error handling used to live in the Selector, and I've preserved the
      # use of rescue_from for now, hence catching and raising an error within
      # the controller
      uri_candidates =
        begin
          CSV.read(params[:csv_upload].path).map(&:first)
        rescue ArgumentError, CSV::MalformedCSVError
          (invalid_upload && return)
        end

      if params[:postcode]
        data = geography_service.uris_for_postcodes(uri_candidates)

        @gss_resource_uris        = data.fetch(:gss_resource_uris)
        @secondary_resource_uris  = data.fetch(:secondary_resource_uris)
        @non_gss_codes            = data.fetch(:non_gss_codes)
        @geography_type           = 'http://opendatacommunities.org/def/geography#LSOA'

        @secondary_resource_uri_data = @secondary_resource_uris.join(', ')
      else
        data = geography_service.uris_and_geography_type_for_gss_codes(uri_candidates)

        @gss_resource_uris  = data.fetch(:gss_resource_uris)
        @non_gss_codes      = data.fetch(:non_gss_codes)
        @geography_type     = data.fetch(:geography_type)
      end

      @gss_resource_uri_data = @gss_resource_uris.join(', ')

      respond_to do |format|
        format.html
      end
    end

    def create
      gss_resource_uris = params[:gss_resource_uri_data].split(', ')
      secondary_resource_uris = nil
      if params[:secondary_resource_uri_data]
        secondary_resource_uris = params[:secondary_resource_uri_data].split(', ')
      end

      @selector = Selector.create(
        geography_type:       params[:geography_type],
        row_uris:             gss_resource_uris,
        secondary_row_uris:   secondary_resource_uris
      )

      redirect_to edit_selector_path(@selector)
    end

    def edit
      @snapshot = @selector.build_snapshot(row_limit: 7)
    end

    def finish
      @selector.finish!
      redirect_to selector_path(@selector)
    end

    def show
      @snapshot = @selector.build_snapshot(row_limit: 7)
    end

    def duplicate
      @selector = @selector.deep_copy
      @selector.save
      redirect_to @selector
    end

    def download
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

    def crumbs
      initialize_empty_crumbtrail
      prepend_crumb('Foo', '/foo')
    end

    def invalid_upload
      flash.now[:error] = 'The uploaded file did not contain valid CSV data, please check and try again.'
      render :new
    end

    def mixed_gss_codes
      flash.now[:error] = 'The uploaded file should contain GSS codes at either LSOA or Local Authority level.'
      render :new
    end

    def too_many_gss_codes
      flash.now[:error] = 'The uploaded file contains more than 500 GSS codes, please reduce its size and try again.'
      render :new
    end

    def no_file_uploaded
      flash.now[:error] = 'Please select a valid .csv file'
      render :new
    end

    def redirect_if_finished
      redirect_to selector_path(@selector) if @selector.finished
    end

    def redirect_unless_finished
      redirect_to edit_selector_path(@selector) unless @selector.finished
    end
  end
end
