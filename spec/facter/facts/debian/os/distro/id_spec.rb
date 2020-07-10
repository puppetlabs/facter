# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Id do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Id.new }

    let(:value) { 'debian' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:id).and_return(value)
    end

    it 'calls Facter::Resolvers::OsRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:id)
    end

    it 'returns os.distro.id fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.id', value: value.capitalize)
    end
  end
end
