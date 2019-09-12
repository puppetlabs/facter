# frozen_string_literal: true

describe 'FactFilter' do
  it 'filters value inside fact' do
    fact_value = { full: '18.7.0', major: '18', minor: 7 }
    resolved_fact = Facter::ResolvedFact.new('os.release', fact_value)

    resolved_fact.user_query = 'os.release.major'
    resolved_fact.filter_tokens = ['major']

    Facter::FactFilter.new.filter_facts!([resolved_fact])

    expect(resolved_fact.value).to eq('18')
  end
end
