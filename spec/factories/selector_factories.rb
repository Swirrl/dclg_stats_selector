FactoryGirl.define do
  factory :selector, class: DclgStatsSelector::Selector do
    geography_type 'http://opendatacommunities.org/def/local-government/LocalAuthority'
    row_uris ['http://statistics.data.gov.uk/id/statistical-geography/E07000008', 'http://statistics.data.gov.uk/id/statistical-geography/E07000036']
  end
end