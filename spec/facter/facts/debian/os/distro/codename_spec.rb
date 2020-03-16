# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Codename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Codename.new }

    let(:value) { 'stretch' }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:codename).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:codename)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.distro.codename', value: value),
                        an_object_having_attributes(name: 'lsbdistcodename', value: value, type: :legacy))
    end
  end
end
