require 'spec_helper'

module DclgStatsSelector
  describe SelectorsController do
    let(:selector) { FactoryGirl.create(:selector) }

    describe "#preview" do
      context "given an uploaded text file containing GSS codes" do
        let(:csv_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_etc.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: csv_upload, use_route: :dclg_stats_selector
          response.should be_success
        end
      end

      context "given a file of invalid format" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/dog.gif'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a mangled CSV file" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/malformed.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing a mix of LA and LSOA GSS codes" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_mixed.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: invalid_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing more than 500 GSS codes" do
        let(:large_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_big.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: large_upload, use_route: :dclg_stats_selector
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: large_upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing double-quoted values" do
        let(:upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_with_quotes.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: upload, use_route: :dclg_stats_selector
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: upload, use_route: :dclg_stats_selector
          flash[:error].should_not be_nil
        end
      end
    end

    describe '#edit' do
      it 'should respond successfully' do
        get :edit, id: selector.to_param, use_route: :dclg_stats_selector
        response.should be_success
      end

      context 'given a finished selector' do
        before { selector.finish! }

        it 'should redirect to show' do
          get :edit, id: selector.to_param, use_route: :dclg_stats_selector
          response.should redirect_to(selector)
        end
      end
    end

    describe '#show' do
      it 'should redirect to edit' do
        get :show, id: selector.to_param, use_route: :dclg_stats_selector
        response.should redirect_to( [:edit, selector] )
      end

      context 'given a finished selector' do
        before { selector.finish! }

        it 'should respond successfully' do
          response.should be_success
        end
      end
    end

    describe '#download' do
      it 'should redirect to edit' do
        get :download, id: selector.to_param, use_route: :dclg_stats_selector
        response.should redirect_to( [:edit, selector] )
      end

      context 'given a finished selector' do
        before { selector.finish! }

        it 'should respond with valid csv' do
          get :download, id: selector.to_param, use_route: :dclg_stats_selector
          CSV.parse(response.body).should_not be_empty
        end
      end
    end
  end
end