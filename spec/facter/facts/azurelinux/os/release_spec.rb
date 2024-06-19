# frozen_string_literal: true

describe Facts::Azurelinux::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Azurelinux::Os::Release.new }

    before do
      allow(Facter::Resolvers::SpecificReleaseFile).to receive(:resolve)
        .with(:release, { release_file: '/etc/azurelinux-release',
                          regex: /AZURELINUX_BUILD_NUMBER=([0-9.]+)/ })
        .and_return(value)
    end

    context 'when version is retrieved from specific file' do
      let(:value) { /AZURELINUX_BUILD_NUMBER=([0-9.]+)/.match('AZURELINUX_BUILD_NUMBER=3.0.20240401') }
      let(:release) { { 'full' => '3.0.20240401', 'major' => '3', 'minor' => '0' } }

      it 'returns operating system name fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: release),
                          an_object_having_attributes(name: 'operatingsystemmajrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease',
                                                      value: release['full'], type: :legacy))
      end
    end

    context 'when version is retrieved from os-release file' do
      let(:value) { nil }
      let(:os_release) { '3.0.20240401' }
      let(:release) { { 'full' => '3.0.20240401', 'major' => '3', 'minor' => '0' } }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release)
      end

      it 'returns operating system name fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: release),
                          an_object_having_attributes(name: 'operatingsystemmajrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease',
                                                      value: release['full'], type: :legacy))
      end

      context 'when release can\'t be received' do
        let(:os_release) { nil }

        it 'returns operating system name fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'os.release', value: nil)
        end
      end
    end
  end
end
