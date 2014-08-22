# UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

require 'spec_helper'

include DclgStatsSelector

feature "Preparing a Stats Selector document" do
  let(:selector) { FactoryGirl.create(:selector) }
  let(:dataset)  { FactoryGirl.create(:dataset) }

  context 'based on GSS codes', js: true do
    background do
      GeographyTasks.create_some_gss_resources

      visit '/selectors/new'
    end

    scenario 'Visitor uploads a file containing a mix of GSS codes and other text' do
      attach_file 'csv_upload', File.expand_path('spec/support/gss_etc.csv')
      click_on 'Upload'

      page.should have_content 'PREVIEW'

      page.should have_content '2 rows imported'
      page.should have_content '3 rows not imported'

      click_on 'Show data'
      find('#non-imported-data').should have_content 'Ham'
      find('#non-imported-data').should have_content 'Beans'
      find('#non-imported-data').should have_content 'Eggs'

      page.should have_content 'E07000008 Cambridge'
      page.should have_content 'E07000036 Erewash'
    end

    scenario 'Visitor uploads an animal gif' do
      attach_file 'csv_upload', File.expand_path('spec/support/dog.gif')
      click_on 'Upload'

      page.should have_content 'Upload Data'
      page.should have_content 'The uploaded file did not contain valid CSV data'
    end

    scenario 'Visitor uploads a file containing GSS codes at both LA and LSOA level' do
      attach_file 'csv_upload', File.expand_path('spec/support/gss_mixed.csv')
      click_on 'Upload'

      page.should have_content 'Upload Data'
      page.should have_content 'The uploaded file should contain GSS codes at either LSOA or Local Authority level.'
    end

    scenario 'Visitor just clicks upload without selecting a .csv file' do
      click_on 'Upload'

      page.should have_content 'Upload Data'
      page.should have_content 'Please select a valid .csv file'
    end
  end

  context 'based on postcodes', js: true do
    background do
      GeographyTasks.create_some_gss_resources

      visit '/selectors/new'
      choose 'Postcodes'
    end

    scenario 'Visitor uploads a file containing a mix of postcodes and other text' do
      attach_file 'csv_upload', File.expand_path('spec/support/postcodes.csv')
      click_on 'Upload'

      page.should have_content 'PREVIEW'
      page.should have_content '3 rows imported'
      page.should have_content '2 rows not imported'

      click_on 'Show data'
      find('#non-imported-data').should have_content 'V10 L1N'
      find('#non-imported-data').should have_content 'R0 8OT'

      page.should have_content 'SK9 4JF'
      page.should have_content 'Macclesfield 007F'
      page.should have_content 'M4 1HN'
      page.should have_content 'Manchester 014C'
      page.should have_content 'M1 7AR'
      page.should have_content 'Manchester 014A'
    end

    scenario 'Visitor uploads an animal gif' do
      attach_file 'csv_upload', File.expand_path('spec/support/dog.gif')
      click_on 'Upload'

      page.should have_content 'Upload Data'
      page.should have_content 'The uploaded file did not contain valid CSV data'
    end

    scenario 'Visitor just clicks upload without selecting a .csv file' do
      click_on 'Upload'

      page.should have_content 'Upload Data'
      page.should have_content 'Please select a valid .csv file'
    end
  end

  describe 'Selecting a dataset', js: true do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)
    end

    scenario 'Visitor selects a dataset from which to create a fragment' do
      visit "/selectors/#{selector.id}"
      find('#add-data-button').trigger(:click)

      page.should have_css 'div#select-dataset'

      select dataset.title, from: 'dataset_uri'
      click_on 'Select Dataset'

      page.should have_content 'Dataset:'
      page.should have_content dataset.title
    end
  end

  describe 'Selecting some dimension filters for a dataset', js: true do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)

      visit "/selectors/#{selector.id}"
      find('#add-data-button').trigger(:click)
      select dataset.title, from: 'dataset_uri'
      click_on 'Select Dataset'
    end

    scenario 'Visitor selects a dimension filter, leaving another open' do
      click_on '2013 Q1'

      page.should have_content 'Filtered by'
      page.should have_content 'All Ethnicities'
      # filter should have moved from the list of options to the list of applied filters
      find('#filters').should have_content '2013 Q1'
      find('#filter-options').should_not have_content '2013 Q1'
    end

    scenario 'Visitor selects a dimension filter, then unselects it' do
      click_on '2013 Q1'
      find('#filters').should have_content '2013 Q1'
      find('#filter-options').should_not have_content '2013 Q1'

      find('#filters').click_link '×'
      page.should have_content 'All possible combinations of dataset dimension are currently chosen'
      page.should_not have_css('#filters')
      find('#filter-options').should have_content '2013 Q1'
    end
  end

  describe 'Creating a fragment', js: true do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)

      visit "/selectors/#{selector.id}"
      find('#add-data-button').trigger(:click)
      select dataset.title, from: 'dataset_uri'
      click_on 'Select Dataset'
    end

    context '... filtering on all dimensions' do
      background do
        click_on '2013 Q1'
        click_on 'Mixed'
      end

      scenario 'Visitor completes the fragment creation process' do
        click_on 'Add 1 column of data'

        page.should have_content 'PREVIEW'
        page.should have_content '2013 Q1'
        page.should have_content 'Mixed'
        # page.should have_content '234'
        # page.should have_content '2345'
      end
    end

    context '... filtering on a single dimensions' do
      background do
        click_on '2013 Q1'
      end

      scenario 'Visitor completes the fragment creation process' do
        click_on 'Add 3 columns of data'

        page.should have_content 'PREVIEW'
        page.should have_content 'White'
        page.should have_content 'Mixed'
        page.should have_content 'Black' # all values for unfiltered dimension are present
      end
    end
  end

  describe 'removing a fragment' do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)

      selector.fragments.create(
        dataset_uri: dataset.uri.to_s,
        dimensions: {
          'http://opendatacommunities.org/def/ontology/time/refPeriod' => ['http://reference.data.gov.uk/id/quarter/2013-Q1'],
          'http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity' => ['http://opendatacommunities.org/def/concept/general-concepts/ethnicity/mixed']
        },
        measure_property_uri: 'http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/homelessnessAcceptancesObs'
      )

      visit "/selectors/#{selector.id}"
    end

    scenario 'Visitor removes some data from the selector', js: true do
      find('th.fragment-actions').hover
      click_link 'Remove Data'
      page.should_not have_content '2013 Q1'
    end
  end
end
