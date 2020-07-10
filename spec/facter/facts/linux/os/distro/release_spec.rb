# frozen_string_literal: true

describe Facts::Linux::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Os::Distro::Release.new }

    let(:value) { '7.2.1511' }
    let(:release) { { 'full' => '7.2.1511', 'major' => '7', 'minor' => '2' } }

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

    context 'when lsb_release is not installed' do
      let(:value) { nil }

      before do
        allow(Facter::Resolvers::LsbRelease).to receive(:resolve).with(:release).and_return(value)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'os.distro.release', value: value)
      end
    end
  end
end
