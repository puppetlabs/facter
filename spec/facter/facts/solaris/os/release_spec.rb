# frozen_string_literal: true

describe 'Solaris OsRelease' do
  context '#call_the_resolver' do
    let(:release_fact) { { full: '10_u11', minor: '11', major: '10' } }

    it 'returns a os_release fact' do
      expected_fact = double(Facter::Solaris::OsRelease, name: 'os.release', value: release_fact)
      allow(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:full).and_return('10_u11')
      allow(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:major).and_return('10')
      allow(Facter::Resolvers::SolarisRelease).to receive(:resolve).with(:minor).and_return('11')
      allow(Facter::ResolvedFact).to receive(:new).with('os.release', release_fact).and_return(expected_fact)
      fact = Facter::Solaris::OsRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
