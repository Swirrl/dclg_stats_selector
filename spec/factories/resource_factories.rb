FactoryGirl.define do
  factory :observation, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "#{PublishMyData.linked_data_root}/data/resources/1" }
      graph_uri { "#{PublishMyData.linked_data_root}/graph/data_cube" }
    end
    after(:build) do |res|
      res.rdf_type = RDF::CUBE.Observation
    end
  end
end
