require 'spec_helper'

require 'fileutils'

module DclgStatsSelector
  describe Selector do
    describe "#empty?" do
      subject(:selector) { FactoryGirl.build(:selector) }

      context "new" do
        its(:empty?) { should be_true}
      end

      context "with a fragment" do
        before(:each) do
          # Note that while the fragment has no dimensions, we still
          # consider the selector non-empty here, as we enforce through
          # the UI that fragments must have values for the dimensions
          selector.fragments.build(
            dataset_uri:          'uri:dataset/1',
            measure_property_uri: 'uri:measure-property/1',
            dimensions: { }
          )
        end

        its(:empty?) { should be_false }
      end
    end

    describe "#take_snapshot" do
      let(:snapshot) {
        double(Snapshot,
          dataset_detected:   nil,
          dimension_detected: nil,
          dataset_completed:  nil,
          row_uris_detected:  nil
        )
      }

      let(:observation_source) {
        double(ObservationSource,
          row_uris_detected: nil,
          dataset_detected:   nil
        )
      }

      let(:labeller) {
        double(Labeller, resource_detected: nil)
      }

      subject(:selector) {
        Selector.new(
          geography_type: 'uri:geography-type/1',
          row_uris:       ['uri:row/1', 'uri:row/2', 'uri:row/3']
        )
      }

      before(:each) do
        selector.fragments.build(
          dataset_uri:          'uri:dataset/1',
          measure_property_uri: 'uri:measure-property/1',
          dimensions: {
            'uri:dimension/1' => ['uri:dimension/1/val/1', 'uri:dimension/1/val/2'],
            'uri:dimension/2' => ['uri:dimension/2/val/1', 'uri:dimension/2/val/2']
          }
        )
        selector.fragments.build(
          dataset_uri:          'uri:dataset/2',
          measure_property_uri: 'uri:measure-property/2',
          dimensions: {
            'uri:dimension/3' => ['uri:dimension/3/val/1']
          }
        )
      end

      context "no row limit (usual case)" do
        let!(:snapshot_result) {
          selector.take_snapshot(snapshot, observation_source, labeller)
        }

        it "returns nil, as this is a command method that mutates the snapshot" do
          expect(snapshot_result).to be_nil
        end

        describe "priming the labeller" do
          %w[ uri:row/1 uri:row/2 uri:row/3 ].each do |resource_uri|
            specify {
              expect(labeller).to have_received(:resource_detected).with(resource_uri)
            }
          end
        end

        describe "priming the observation source" do
          it "notifies the observation source of the datasets" do
            # Full interaction is specified in Fragment
            expect(observation_source).to have_received(:dataset_detected).with(
              hash_including(dataset_uri: 'uri:dataset/1')
            )

            expect(observation_source).to have_received(:dataset_detected).with(
              hash_including(dataset_uri: 'uri:dataset/2')
            )
          end

          it "notifies the observation source of the rows" do
            expect(observation_source).to have_received(:row_uris_detected).with(
              'http://opendatacommunities.org/def/ontology/geography/refArea',
              ['uri:row/1', 'uri:row/2', 'uri:row/3']
            )
          end
        end

        describe "priming the snapshot" do
          it "informs the snapshot of the datasets" do
            # Full interaction is specified in Fragment
            # Not sure we need to pass the dataset URI but for now it will
            # do as proof that we told the Fragment to inform the snapshot
            expect(snapshot).to have_received(:dataset_detected).with(
              hash_including(dataset_uri: 'uri:dataset/1')
            )

            expect(snapshot).to have_received(:dataset_detected).with(
              hash_including(dataset_uri: 'uri:dataset/2')
            )
          end

          it "informs the snapshot of the rows" do
            expect(snapshot).to have_received(:row_uris_detected).with(
              ['uri:row/1', 'uri:row/2', 'uri:row/3']
            )
          end
        end
      end

      context "row limit (for preview, only one interesting deviation from above)" do
        let!(:snapshot_result) {
          selector.take_snapshot(snapshot, observation_source, labeller, row_limit: 2)
        }

        describe "priming the labeller" do
          it "fetches labels for rows in the snapshot" do
            expect(labeller).to have_received(:resource_detected).with('uri:row/1')
            expect(labeller).to have_received(:resource_detected).with('uri:row/2')
          end

          # Full interaction is specified in Fragment
          it "tells the fragments to inform the labeller of their resources" do
            expect(labeller).to have_received(:resource_detected).with('uri:dataset/1')
            expect(labeller).to have_received(:resource_detected).with('uri:dataset/2')
          end

          # This only saves us a trivial amount of database query time but
          # seems more correct somehow...
          it "doesn't fetch labels for rows not in the snapshot" do
            expect(labeller).to_not have_received(:resource_detected).with('uri:row/3')
          end
        end

        describe "priming the observation source" do
          it "notifies the observation source of the rows" do
            expect(observation_source).to have_received(:row_uris_detected).with(
              'http://opendatacommunities.org/def/ontology/geography/refArea',
              ['uri:row/1', 'uri:row/2']
            )
          end
        end

        describe "priming the snapshot" do
          it "informs the snapshot of the rows" do
            expect(snapshot).to have_received(:row_uris_detected).with(
              ['uri:row/1', 'uri:row/2']
            )
          end
        end
      end
    end

    describe '#finish!' do
      subject(:selector) { FactoryGirl.build(:selector) }

      it 'should set finished to true' do
        selector.finish!
        selector.finished.should be_true
      end

      it 'should persist its finished status' do
        selector.finish!
        Selector.find(selector.id).finished.should be_true
      end
    end
  end
end