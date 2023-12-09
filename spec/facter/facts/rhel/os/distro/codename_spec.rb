# frozen_string_literal: true

describe Facts::Rhel::Os::Distro::Codename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Rhel::Os::Distro::Codename.new }

    let(:value) { 'Fedora' }

    before do
      allow(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:codename).and_return(value)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.codename', value: value)
    end
  end
end
