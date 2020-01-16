# frozen_string_literal: true

describe 'Ubuntu OsLsbRelease' do
  context '#call_the_resolver' do
    let(:value) do
      { 'codename' => 'value1',
        'description' => 'value2',
        'id' => 'value3',
        'release' => { 'full' => '10.9', 'major' => '10', 'minor' => '9' } }
    end

    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.distro', value: value)
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:codename).and_return('value1')
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:description).and_return('value2')
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:distributor_id).and_return('value3')
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:release).and_return('10.9')
      allow(Facter::ResolvedFact).to receive(:new).with('os.distro', value).and_return(expected_fact)

      fact = Facter::Debian::OsLsbRelease.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
