# frozen_string_literal: true

describe 'FactFormater' do
  it 'formats to json' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    searched_fact = ['os.name']
    fact_formatter = Facter::FactFormatter.new(searched_fact, fact_collection)

    expected_output = "{\n  \"os\": {\n    \"name\": \"Darwin\"\n  }\n}"

    expect(fact_formatter.to_j).to eq(expected_output)
  end

  it 'formats to hash string' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    searched_fact = ['os.name']
    fact_formatter = Facter::FactFormatter.new(searched_fact, fact_collection)

    expected_output = "{\n  \"os\" => {\n    \"name\" => \"Darwin\"\n  }\n}"

    expect(fact_formatter.to_h).to eq(expected_output)
  end

  it 'formats to hocon with 1 value' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin' })
    searched_fact = ['os.name']
    fact_formatter = Facter::FactFormatter.new(searched_fact, fact_collection)

    expected_output = 'Darwin'

    expect(fact_formatter.to_hocon).to eq(expected_output)
  end

  it 'formats to hocon with 2 values' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin', 'architecture' => 'x86_64' })
    searched_fact = ['os.name', 'os.architecture']
    fact_formatter = Facter::FactFormatter.new(searched_fact, fact_collection)

    expected_output = ['os.architecture => "x86_64",', 'os.name => "Darwin"']

    expect(fact_formatter.to_hocon).to eq(expected_output)
  end

  it 'formats to hocon with no values' do
    fact_collection = Facter::FactCollection.new
    fact_collection.merge!('os' => { 'name' => 'Darwin', 'architecture' => 'x86_64' })
    searched_fact = []
    fact_formatter = Facter::FactFormatter.new(searched_fact, fact_collection)

    expected_output = ['os => {', '  architecture => "x86_64",', '  name => "Darwin"', '}']

    expect(fact_formatter.to_hocon).to eq(expected_output)
  end
end
