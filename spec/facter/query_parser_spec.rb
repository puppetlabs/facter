# frozen_string_literal: true

describe Facter::QueryParser do
  describe '#parse' do
    it 'creates one core searched fact' do
      query_list = ['os.name']

      os_name_class = 'Facter::Ubuntu::OsName'
      os_family_class = 'Facter::Ubuntu::OsFamily'

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.name', klass: os_name_class, type: :core)
      loaded_fact_os_family = double(Facter::LoadedFact, name: 'os.family', klass: os_family_class, type: :core)
      loaded_facts = [loaded_fact_os_name, loaded_fact_os_family]

      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts)

      expect(matched_facts).to be_an_instance_of(Array).and \
        contain_exactly(an_instance_of(Facter::SearchedFact).and(having_attributes(fact_class: os_name_class)))
    end

    it 'compose filter_tokens correctly' do
      query_list = ['os.release.arry.1.val2']

      os_name_class = 'Facter::Ubuntu::OsName'

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.release', klass: os_name_class, type: :core)
      loaded_facts = [loaded_fact_os_name]

      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts)

      expect(matched_facts.first.filter_tokens).to eq(['arry', 1, 'val2'])
    end

    it 'creates one legacy fact' do
      query_list = ['ipaddress_ens160']

      networking_class = 'Facter::Ubuntu::NetworkInterface'
      os_family_class = 'Facter::Ubuntu::OsFamily'

      loaded_fact_networking = double(Facter::LoadedFact, name: 'ipaddress_.*', klass: networking_class, type: :legacy)
      loaded_fact_os_family = double(Facter::LoadedFact, name: 'os.family', klass: os_family_class, type: :core)
      loaded_facts = [loaded_fact_networking, loaded_fact_os_family]

      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts)

      expect(matched_facts).to be_an_instance_of(Array).and \
        contain_exactly(an_instance_of(Facter::SearchedFact).and(having_attributes(fact_class: networking_class)))
    end

    it 'creates one custom searched fact' do
      query_list = ['custom_fact']
      os_name_class = 'Facter::Ubuntu::OsName'

      loaded_fact_os_name = double(Facter::LoadedFact, name: 'os.name', klass: os_name_class, type: :core)
      loaded_fact_custom_fact = double(Facter::LoadedFact, name: 'custom_fact', klass: nil, type: :custom)
      loaded_facts = [loaded_fact_os_name, loaded_fact_custom_fact]

      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts)

      expect(matched_facts).to be_an_instance_of(Array).and \
        contain_exactly(an_instance_of(Facter::SearchedFact).and(having_attributes(fact_class: nil, type: :custom)))
    end

    it 'queries if param is symbol' do
      query_list = [:path]
      path_class = 'Facter::Ubuntu::Path'
      loaded_fact_path = double(Facter::LoadedFact, name: 'path', klass: path_class, type: :core)
      loaded_facts = [loaded_fact_path]

      matched_facts = Facter::QueryParser.parse(query_list, loaded_facts)

      expect(matched_facts).to be_an_instance_of(Array).and \
        contain_exactly(an_instance_of(Facter::SearchedFact).and(having_attributes(fact_class: path_class)))
    end
  end
end
