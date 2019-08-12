# frozen_string_literal: true

# rubocop:disable Metric/BlockLength

describe 'FactFormater' do
  it 'formats to json' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    fact_formatter = Facter::FactFormatter.new(fact_collection)

    expected_output = '{"os":{"name":"Darwin"}}'

    expect(fact_formatter.to_j).to eq(expected_output)
  end

  it 'formats to pretty json' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    fact_formatter = Facter::FactFormatter.new(fact_collection)

    expected_output = "{\n  \"os\": {\n    \"name\": \"Darwin\"\n  }\n}"

    expect(fact_formatter.to_pretty_j).to eq(expected_output)
  end

  it 'formats to hash string' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    fact_formatter = Facter::FactFormatter.new(fact_collection)

    expected_output = '{"os"=>{"name"=>"Darwin"}}'

    expect(fact_formatter.to_h).to eq(expected_output)
  end

  it 'formats to pretty hash string' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    fact_formatter = Facter::FactFormatter.new(fact_collection)

    expected_output = "{\n  \"os\" => {\n    \"name\" => \"Darwin\"\n  }\n}"

    expect(fact_formatter.to_pretty_h).to eq(expected_output)
  end
end
# rubocop:enable Metric/BlockLength
