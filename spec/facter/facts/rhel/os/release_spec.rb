# frozen_string_literal: true

describe Facts::Rhel::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Rhel::Os::Release.new }

    before do
      allow(Facter::Resolvers::RedHatRelease).to receive(:resolve).with(:version).and_return(value)
    end

    context 'when os is RedHat' do
      context 'when version has only major and minor' do
        let(:value) { '6.2' }
        let(:release) { { 'full' => '6.2', 'major' => '6', 'minor' => '2' } }

        it 'calls Facter::Resolvers::RedHatRelease with version' do
          fact.call_the_resolver
          expect(Facter::Resolvers::RedHatRelease).to have_received(:resolve).with(:version)
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

      context 'when version also contains build number' do
        let(:value) { '7.4.1708' }
        let(:release) { { 'full' => '7.4.1708', 'major' => '7', 'minor' => '4' } }

        it 'calls Facter::Resolvers::RedHatRelease with version' do
          fact.call_the_resolver
          expect(Facter::Resolvers::RedHatRelease).to have_received(:resolve).with(:version)
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
    end

    context 'when os is Centos' do
      let(:value) { nil }
      let(:red_release) { '6.2' }
      let(:release) { { 'full' => '6.2', 'major' => '6', 'minor' => '2' } }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(red_release)
      end

      it 'calls Facter::Resolvers::OsRelease with version_id' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_id)
      end

      it 'calls Facter::Resolvers::RedHatRelease with version' do
        fact.call_the_resolver
        expect(Facter::Resolvers::RedHatRelease).to have_received(:resolve).with(:version)
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
  end
end
