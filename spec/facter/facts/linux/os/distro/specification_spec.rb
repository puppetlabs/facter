# frozen_string_literal: true

describe Facts::Linux::Os::Distro::Specification do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Os::Distro::Specification.new }

    let(:value) { ':core-4.1-amd64:core-4.1-noarch:cxx-4.1-amd64' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:lsb_version).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:lsb_version)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.distro.specification', value: value),
                        an_object_having_attributes(name: 'lsbrelease', value: value, type: :legacy))
    end
  end
end
