# frozen_string_literal: true

describe 'FormatterFactory' do
  it 'creates a json formatte' do
    options = { json: true }
    json_fact_formatter = Facter::FormatterFactory.build(options)

    expect(json_fact_formatter).to be_a Facter::JsonFactFormatter
  end

  it 'creates a yaml formatte' do
    options = { yaml: true }
    json_fact_formatter = Facter::FormatterFactory.build(options)

    expect(json_fact_formatter).to be_a Facter::YamlFactFormatter
  end

  it 'creates a hocon formatte' do
    options = {}
    json_fact_formatter = Facter::FormatterFactory.build(options)

    expect(json_fact_formatter).to be_a Facter::HoconFactFormatter
  end
end
