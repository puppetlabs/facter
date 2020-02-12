# frozen_string_literal: true

describe 'Solaris Path' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = '/Users/User/.rvm/gems/ruby-2.4.6/bin:/Users/User/.rvm/gems/ruby-2.4.6@global/bin'
      expected_fact = double(Facter::ResolvedFact, name: 'path', value: value)
      allow(Facter::Resolvers::Path).to receive(:resolve).with(:path).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('path', value).and_return(expected_fact)

      fact = Facter::Solaris::Path.new

      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
