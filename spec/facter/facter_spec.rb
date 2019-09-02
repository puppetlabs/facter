# frozen_string_literal: true

describe 'facter' do
  it 'return one fact' do
    allow(OsDetector).to receive(:detect_family).and_return('ubuntu')
    os_fact = Facter::Fact.new('os.name', 'ubuntu')
    allow_any_instance_of(Facter::Ubuntu::OsName).to receive(:call_the_resolver).and_return(os_fact)
    fact_hash = Facter::Base.new.resolve_facts(['os.name'])

    expected_fact_hash = { 'os' => { 'name' => 'ubuntu' } }

    expect(fact_hash).to eq(expected_fact_hash)
  end
end
