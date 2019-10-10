# frozen_string_literal: true

describe 'QueryParser' do
  describe '#parse' do
    it 'creates one core searched fact' do
      query_list = ['os.name']

      os_class = Class.const_get('Facter::Ubuntu::OsName')
      os_name = Class.const_get('Facter::Ubuntu::OsFamily')
      loaded_facts_hash = { 'os.name' => os_class,
                            'os.family' => os_name }
      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

      expect(matched_facts.size).to eq(1)
      expect(matched_facts.first.fact_class).to eq(os_class)
    end

    it 'creates one legacy fact' do
      query_list = ['ipaddress_ens160']

      networking_class = Class.const_get('Facter::Ubuntu::NetworkInterface')
      os_name = Class.const_get('Facter::Ubuntu::OsFamily')
      loaded_facts_hash = { 'ipaddress_.*' => networking_class,
                            'os.family' => os_name }
      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

      expect(matched_facts.size).to eq(1)
      expect(matched_facts.first.fact_class).to eq(networking_class)
    end

    it 'creates one custom searched fact' do
      query_list = ['custom_fact']

      os_class = Class.const_get('Facter::Ubuntu::OsName')
      os_name = Class.const_get('Facter::Ubuntu::OsFamily')
      loaded_facts_hash = { 'os.name' => os_class,
                            'os.family' => os_name }
      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

      expect(matched_facts.size).to eq(1)
      expect(matched_facts.first.fact_class).to be_nil
    end

    it 'queries if param is symbol' do
      query_list = [:path]

      os_class = Class.const_get('Facter::Ubuntu::Path')
      loaded_facts_hash = { 'path' => os_class }
      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts_hash)

      expect(matched_facts.size).to eq(1)
      expect(matched_facts[0].fact_class).to eq(os_class)
    end
  end
end
