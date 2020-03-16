# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Description do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Description.new }

    let(:value) { 'Debian GNU/Linux 9.0 (stretch)' }

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
