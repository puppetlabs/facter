# frozen_string_literal: true

describe Facts::Sles::Os::Distro::Description do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Distro::Description.new }

    let(:value) { 'CentOS Linux release 7.2.1511 (Core)' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:description).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:description)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.distro.description', value: value),
                        an_object_having_attributes(name: 'lsbdistdescription', value: value, type: :legacy))
    end
  end
end
