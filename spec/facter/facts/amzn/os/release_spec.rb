# frozen_string_literal: true

describe Facts::Amzn::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Os::Release.new }

    before do
      allow(Facter::Resolvers::ReleaseFromFirstLine).to receive(:resolve)
        .with(:release, { release_file: '/etc/system-release' })
        .and_return(system_release_value)
    end

    context 'when version is retrieved from rpm on AL2023' do
      let(:system_release_value) { '2023' }
      let(:os_release_value) { '2023.1.20230912' }
      let(:release) { { 'full' => '2023.1.20230912', 'major' => '2023', 'minor' => '1' } }

      it 'returns os release fact excluding patch' do
        allow(Facter::Resolvers::Amzn::OsReleaseRpm).to receive(:resolve)
          .with(:version)
          .and_return(os_release_value)

        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: release),
                          an_object_having_attributes(name: 'operatingsystemmajrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease',
                                                      value: release['full'], type: :legacy))
      end
    end

    context 'when version is retrieved from os-release file on AL1' do
      let(:system_release_value) { nil }
      let(:os_release_value) { '2017.03' }
      let(:release) { { 'full' => '2017.03', 'major' => '2017', 'minor' => '03' } }

      it 'returns os release fact' do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release_value)

        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: release),
                          an_object_having_attributes(name: 'operatingsystemmajrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease',
                                                      value: release['full'], type: :legacy))
      end
    end

    context 'when version is retrieved from os-release file on AL2' do
      let(:system_release_value) { '2' }
      let(:release) { { 'full' => '2', 'major' => '2' } }

      it 'returns os release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'os.release', value: release),
                          an_object_having_attributes(name: 'operatingsystemmajrelease',
                                                      value: release['major'], type: :legacy),
                          an_object_having_attributes(name: 'operatingsystemrelease',
                                                      value: release['full'], type: :legacy))
      end
    end

    context 'when version can\'t be retrieved' do
      let(:system_release_value) { nil }
      let(:os_release_value) { nil }

      it 'returns os release fact as nil' do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release_value)

        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.release', value: nil)
      end
    end
  end
end
