FactoryGirl.define do
  factory :fragment, class: DclgStatsSelector::Fragment do
    dataset_uri          'uri:dataset/1'
    measure_property_uri 'uri:measure-property/1'
    dimensions ({
      'uri:dimension/1' => ['uri:dimension/1/val/1', 'uri:dimension/1/val/2'],
      'uri:dimension/2' => ['uri:dimension/2/val/1', 'uri:dimension/2/val/2']
    })
  end
end