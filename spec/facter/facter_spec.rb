# frozen_string_literal: true

describe 'facter' do
  before do
    RbConfig::CONFIG['host_os'] = 'linux'
    allow(Facter::Resolver::OsReleaseResolver).to receive(:resolve).with(:identifier).and_return('Ubuntu')
    allow(Facter::Resolver::OsReleaseResolver).to receive(:resolve).with(:version).and_return('18.04')
  end
  it 'returns one fact' do
    ubuntu_os_name = double(Facter::Ubuntu::OsName)
    loaded_facts = { 'os.name' => ubuntu_os_name }
    fact_name = 'os.name'
    fact_value = 'ubuntu'

    allow(CurrentOs.instance).to receive(:identifier).and_return('ubuntu')
    os_fact = double(Facter::ResolvedFact, name: fact_name, value: fact_value, user_query: '', filter_tokens: [])
    allow(os_fact).to receive(:value=).with('ubuntu')
    allow_any_instance_of(Facter::Ubuntu::OsName).to receive(:call_the_resolver).and_return(os_fact)

    allow_any_instance_of(Facter::FactLoader).to receive(:load_with_legacy).with(fact_value).and_return(loaded_facts)
    allow_any_instance_of(Facter::QueryParser).to receive(:parse).with([fact_name], loaded_facts)

    fact_hash = Facter::Base.new.resolve_facts([fact_name])

    expected_resolved_fact_list = [os_fact]

    expect(fact_hash).to eq(expected_resolved_fact_list)
  end
end
