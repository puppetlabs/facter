# frozen_string_literal: true

describe Facts::Macosx::Os::Release do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.release',
                                                   value: { full: '10.9', major: '10', minor: '9' })
      allow(Facter::Resolvers::Uname).to receive(:resolve).with(:kernelrelease).and_return('10.9')
      allow(Facter::ResolvedFact).to receive(:new)
        .with('os.release', full: '10.9', major: '10', minor: '9')
        .and_return(expected_fact)

      fact = Facts::Macosx::Os::Release.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
