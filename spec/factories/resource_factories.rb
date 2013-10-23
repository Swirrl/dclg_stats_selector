FactoryGirl.define do
  factory :observation, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/data/resources/1" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/data_cube" }
    end
    after(:build) do |res|
      res.rdf_type = RDF::CUBE.Observation
    end
  end
end