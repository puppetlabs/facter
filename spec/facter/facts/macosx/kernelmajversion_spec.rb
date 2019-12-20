# frozen_string_literal: true

describe 'Macosx Kernelmajversion' do
  context '#call_the_resolver' do
    let(:resolver_result) { '18.7.0' }
    let(:fact_value) { '18.7' }

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajversion', value: fact_value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(fact_value)
      allow(Facter::ResolvedFact).to receive(:new).with('kernelmajversion', fact_value).and_return(expected_fact)

      fact = Facter::Macosx::Kernelmajversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end

    it 'corectly resolves the fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajversion', value: fact_value)
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return(resolver_result)

      fact = Facter::Macosx::Kernelmajversion.new.call_the_resolver
      expect(fact.name).to eq(expected_fact.name)
      expect(fact.value).to eq(expected_fact.value)
    end
  end
end
