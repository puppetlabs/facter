# frozen_string_literal: true

describe Facter::Macosx::OsMacosxBuild do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.macosx.build', value: '10.9.8')
      allow(Facter::Resolvers::SwVers).to receive(:resolve).with(:buildversion).and_return('10.9.8')
      allow(Facter::ResolvedFact).to receive(:new).with('os.macosx.build', '10.9.8').and_return(expected_fact)

      fact = Facter::Macosx::OsMacosxBuild.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
