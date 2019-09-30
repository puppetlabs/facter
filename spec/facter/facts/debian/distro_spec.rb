# frozen_string_literal: true

describe 'Debian OsLsbRelease' do
  context '#call_the_resolver' do
    let(:value) do
      { 'codename' => 'value1',
        'description' => 'value2',
        'id' => 'value3',
        'release' => { 'full' => 'full', 'major' => 'major', 'minor' => 'minor' } }
    end

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.distro', value: value)
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:codename).and_return('value1')
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:description).and_return('value2')
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return('value3')
      allow(Facter::Resolvers::DebianVersion).to receive(:resolve).with(:full).and_return('full')
      allow(Facter::Resolvers::DebianVersion).to receive(:resolve).with(:major).and_return('major')
      allow(Facter::Resolvers::DebianVersion).to receive(:resolve).with(:minor).and_return('minor')
      allow(Facter::ResolvedFact).to receive(:new).with('os.distro', value).and_return(expected_fact)

      fact = Facter::Debian::OsLsbRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
