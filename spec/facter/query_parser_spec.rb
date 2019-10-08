# frozen_string_literal: true

describe 'query parser' do
  it 'queries for os fact' do
    query_list = ['os.name']

    os_class = Class.const_get('Facter::Ubuntu::OsName')
    os_name = Class.const_get('Facter::Ubuntu::OsFamily')
    loaded_facts_hash = { 'os.name' => os_class,
                          'os.family' => os_name }
    matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

    expect(matched_facts.size).to eq(1)
    expect(matched_facts[0].fact_class).to eq(os_class)
  end

  it 'queries if param is symbol' do
    query_list = [:path]

    os_class = Class.const_get('Facter::Ubuntu::Path')
    loaded_facts_hash = { 'path' => os_class }
    matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

    expect(matched_facts.size).to eq(1)
    expect(matched_facts[0].fact_class).to eq(os_class)
  end

  it 'finds no facts' do
    query_list = ['no.fact.found']

    os_class = Class.const_get('Facter::Ubuntu::OsName')
    os_name = Class.const_get('Facter::Ubuntu::OsFamily')
    loaded_facts_hash = { 'os.name' => os_class,
                          'os.family' => os_name }
    matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

    expect(matched_facts.size).to eq(0)
  end
end
