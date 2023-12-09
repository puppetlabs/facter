# frozen_string_literal: true

describe Facts::Amzn::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Os::Distro::Release.new }

    before do
      allow(Facter::Resolvers::Amzn::OsReleaseRpm).to receive(:resolve)
        .with(:version)
        .and_return(value)
    end

    context 'when version is retrieved from rpm' do
      let(:value) { '2.13.0' }
      let(:release) { { 'full' => '2.13.0', 'major' => '2', 'minor' => '13', 'patch' => '0' } }

      it 'returns os distro release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: release),
                          an_object_having_attributes(name: 'lsbdistrelease',
                                                      value: release['full'], type: :legacy),
                          an_object_having_attributes(name: 'lsbmajdistrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'lsbminordistrelease',
                                                      value: release['minor'], type: :legacy))
      end
    end

    context 'when version is retrieved from os-release file' do
      let(:value) { nil }
      let(:os_release) { '2' }
      let(:release) { { 'full' => '2', 'major' => '2' } }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release)
      end

      it 'returns os distro release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: release),
                          an_object_having_attributes(name: 'lsbdistrelease',
                                                      value: release['full'], type: :legacy),
                          an_object_having_attributes(name: 'lsbmajdistrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'lsbminordistrelease',
                                                      value: release['minor'], type: :legacy))
      end

      context 'when release can\'t be received' do
        let(:os_release) { nil }

        it 'returns os distro release fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'os.distro.release', value: nil)
        end
      end
    end
  end
end
