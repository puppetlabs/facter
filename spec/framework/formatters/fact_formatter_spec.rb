# frozen_string_literal: true

describe Facter::FormatterFactory do
  it 'creates a json formatter' do
    options = { json: true }
    json_fact_formatter = Facter::FormatterFactory.build(options)

    expect(json_fact_formatter).to be_a Facter::JsonFactFormatter
  end

  it 'creates a yaml formatter' do
    options = { yaml: true }
    json_fact_formatter = Facter::FormatterFactory.build(options)

    expect(json_fact_formatter).to be_a Facter::YamlFactFormatter
  end

  it 'creates a legacy formatter' do
    options = {}
    json_fact_formatter = Facter::FormatterFactory.build(options)

    expect(json_fact_formatter).to be_a Facter::LegacyFactFormatter
  end
end
