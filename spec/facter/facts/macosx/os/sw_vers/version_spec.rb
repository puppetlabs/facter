# frozen_string_literal: true

describe Facter::Macosx::OsMacosxVersion do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.macosx.version',
                                                   value: { 'full' => '10.9.8', 'major' => '10.9', 'minor' => '8' })
      allow(Facter::Resolvers::SwVers).to receive(:resolve).with(:productversion).and_return('10.9.8')
      allow(Facter::ResolvedFact).to receive(:new)
        .with('os.macosx.version', 'full' => '10.9.8', 'major' => '10.9', 'minor' => '8')
        .and_return(expected_fact)

      fact = Facter::Macosx::OsMacosxVersion.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
