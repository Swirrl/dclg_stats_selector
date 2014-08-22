require 'spec_helper'

module DclgStatsSelector
  describe SelectorsController, type: :controller do
    let(:selector) { FactoryGirl.create(:selector) }

    describe "#create" do
      context "given an uploaded text file containing valid GSS codes" do
        let(:csv_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_etc.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        before { GeographyTasks.create_some_gss_resources }

        it "should redirect to show the selector, passing along import info" do
          post :create, csv_upload: csv_upload, use_route: :dclg_stats_selector
          expected_path = selector_path(assigns[:selector], imported: 2, not_imported: 'Ham,Beans,Eggs')
          response.should redirect_to(expected_path)
        end

        it "should create a selector" do
          expect { post :create, csv_upload: csv_upload, use_route: :dclg_stats_selector}.to change { Selector.count }.by(1)
        end
      end

      context "given a file of invalid format" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/dog.gif'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :create, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          response.should be_bad_request
        end

        it "should flash an error message" do
          post :create, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a mangled CSV file" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/malformed.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :create, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          response.should be_bad_request
        end

        it "should flash an error message" do
          post :create, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing a mix of LA and LSOA GSS codes" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_mixed.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :create, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          response.should be_bad_request
        end

        it "should flash an error message" do
          post :create, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing more than 500 GSS codes" do
        let(:large_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_big.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :create, csv_upload: large_upload, use_route: :dclg_stats_selector
          response.should be_bad_request
        end

        it "should flash an error message" do
          post :create, csv_upload: large_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing double-quoted values" do
        let(:upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_with_quotes.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :create, csv_upload: upload, use_route: :dclg_stats_selector
          response.should be_bad_request
        end

        it "should flash an error message" do
          post :create, csv_upload: upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end
    end

    describe '#show' do
      it 'should respond successfully' do
        get :show, id: selector.to_param, use_route: :dclg_stats_selector
        response.should be_success
      end

      context "given an imported rows count" do
        let(:imported_count) { 1234 }
        let(:non_gss_codes) { ['Ham', 'Beans', 'Eggs'] }

        it 'should assign the imported count' do
          get :show, id: selector.to_param, imported: imported_count, not_imported: non_gss_codes.join(','), use_route: :dclg_stats_selector
          expect(assigns[:imported_count]).to eq(imported_count)
        end

        it 'should assign the non-imported gss codes' do
          get :show, id: selector.to_param, imported: imported_count, not_imported: non_gss_codes.join(','), use_route: :dclg_stats_selector
          expect(assigns[:non_gss_codes]).to eq(non_gss_codes)
        end
      end
    end

    describe '#download' do
      it 'should respond with valid csv' do
        get :download, id: selector.to_param, use_route: :dclg_stats_selector
        CSV.parse(response.body).should_not be_empty
      end

      it 'should make a copy of the given selector' do
        get :download, id: selector.to_param, use_route: :dclg_stats_selector
        expect(assigns[:selector].id).to_not eq(selector.id)
      end
    end
  end
end
