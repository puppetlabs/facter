# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Description do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Description.new }

    let(:value) { 'Debian GNU/Linux 9.0 (stretch)' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:pretty_name).and_return(value)
    end

    it 'calls Facter::Resolvers::OsRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:pretty_name)
    end

    it 'returns os.distro.description fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.description', value: value)
    end
  end
end
