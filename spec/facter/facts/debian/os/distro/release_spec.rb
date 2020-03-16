# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Release.new }

    let(:value) { '9.0' }
    let(:release) { { 'full' => '9.0', 'major' => '9', 'minor' => '0' } }

    before do
      allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:release).and_return(value)
    end

    it 'calls Facter::Resolvers::LsbRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::LsbRelease).to have_received(:resolve).with(:release)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: release),
                        an_object_having_attributes(name: 'lsbdistrelease', value: value, type: :legacy),
                        an_object_having_attributes(name: 'lsbmajdistrelease',
                                                    value: release['major'], type: :legacy),
                        an_object_having_attributes(name: 'lsbminordistrelease',
                                                    value: release['minor'], type: :legacy))
    end
  end
end
