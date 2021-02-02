# frozen_string_literal: true

describe Facts::Ovs::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Ovs::Os::Release.new }

    before do
      allow(Facter::Resolvers::ReleaseFromFirstLine).to receive(:resolve)
        .with(:release, release_file: '/etc/ovs-release')
        .and_return(value)
    end

    context 'when version is retrieved from specific file' do
      let(:value) { '2.13.0' }
      let(:release) { { 'full' => '2.13.0', 'major' => '2', 'minor' => '13' } }

      it 'calls Facter::Resolvers::ReleaseFromFirstLine with version' do
        fact.call_the_resolver
        expect(Facter::Resolvers::ReleaseFromFirstLine).to have_received(:resolve)
          .with(:release, release_file: '/etc/ovs-release')
      end

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
      let(:os_release) { 'beowulf' }
      let(:release) { { 'full' => 'beowulf', 'major' => 'beowulf' } }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release)
      end

      it 'calls Facter::Resolvers::OsRelease with version' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_id)
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
