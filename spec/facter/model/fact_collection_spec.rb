# frozen_string_literal: true

describe 'FactCollector' do
  it 'adds elements to fact collector' do
    fact_collection = Facter::FactCollection.new
    fact_collection.bury('os', 'version', '1.2.3')
    expected_hash = { 'os' => { 'version' => '1.2.3' } }

    expect(fact_collection).to eq(expected_hash)
  end
end
