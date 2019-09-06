# frozen_string_literal: true

describe 'FactCollector' do
  it 'adds elements to fact collection' do
    fact_collection = Facter::FactCollection.new
    fact = Facter::SearchedFact.new('os.version', nil, [], 'os')
    fact.value = '1.2.3'
    fact_collection.build_fact_collection!([fact])
    expected_hash = { 'os' => { 'version' => '1.2.3' } }

    expect(fact_collection).to eq(expected_hash)
  end

  it 'does not add elements to fact collection if fact value is nil' do
    fact_collection = Facter::FactCollection.new
    fact = Facter::SearchedFact.new('os.version', nil, [], 'os')
    fact.value = nil
    fact_collection.build_fact_collection!([fact])
    expected_hash = {}

    expect(fact_collection).to eq(expected_hash)
  end
end
