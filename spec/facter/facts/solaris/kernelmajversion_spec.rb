# frozen_string_literal: true

describe 'Solaris Kernelmajversion' do
  after do
    Facter::Resolvers::Uname.invalidate_cache
  end
  context '#call_the_resolver' do
    it 'returns kernel major version by composing versions with the . delimiter' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajversion', value: '11.4')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelversion).and_return('11.4.0.15.0')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelmajversion', '11.4').and_return(expected_fact)

      fact = Facter::Solaris::Kernelmajversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
    it 'returns kernel major version with no min version' do
      expected_fact = double(Facter::ResolvedFact, name: 'kernelmajversion', value: '11test')
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelversion).and_return('11test')
      allow(Facter::ResolvedFact).to receive(:new).with('kernelmajversion', '11test').and_return(expected_fact)
      fact = Facter::Solaris::Kernelmajversion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
