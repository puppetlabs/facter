# frozen_string_literal: true

describe Facts::Rhel::Os::Distro::Id do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Rhel::Os::Distro::Id.new }

    let(:value) { 'RedHatEnterprise' }

    before do
      allow(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:distributor_id).and_return(value)
    end

    it 'calls Facter::Resolvers::RedHatRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::RedHatRelease).to have_received(:resolve).with(:distributor_id)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.id', value: value)
    end
  end
end
