# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Release.new }

    context 'when os is Ubuntu' do
      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:name).and_return(name)
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(value)
      end

      let(:name) { 'Ubuntu' }

      context 'when version_id is retrieved successful' do
        let(:value) { '18.04' }
        let(:value_final) { { 'full' => '18.04', 'major' => '18', 'minor' => '4' } }

        it 'calls Facter::Resolvers::OsRelease with :name' do
          fact.call_the_resolver
          expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:name)
        end

        it 'calls Facter::Resolvers::OsRelease with :version_id' do
          fact.call_the_resolver
          expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_id)
        end

        it 'returns release fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
            contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: value_final),
                            an_object_having_attributes(name: 'lsbdistrelease', value: value, type: :legacy),
                            an_object_having_attributes(name: 'lsbmajdistrelease',
                                                        value: value_final['major'], type: :legacy),
                            an_object_having_attributes(name: 'lsbminordistrelease',
                                                        value: value_final['minor'], type: :legacy))
        end
      end

      context 'when version_id could not be retrieve' do
        let(:value) { nil }

        it 'returns release fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'os.distro.release', value: value)
        end
      end
    end

    context 'when os is Debian' do
      let(:name) { 'Debian' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:name).and_return(name)
        allow(Facter::Resolvers::DebianVersion).to receive(:resolve).with(:version).and_return(value)
      end

      context 'when version_id is retrieved successful' do
        let(:value) { '10.02' }
        let(:value_final) { { 'full' => '10.02', 'major' => '10', 'minor' => '2' } }

        it 'calls Facter::Resolvers::OsRelease with :name' do
          fact.call_the_resolver
          expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:name)
        end

        it 'calls Facter::Resolvers::DebianVersion' do
          fact.call_the_resolver
          expect(Facter::Resolvers::DebianVersion).to have_received(:resolve).with(:version)
        end

        it 'returns release fact' do
          expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
            contain_exactly(an_object_having_attributes(name: 'os.distro.release', value: value_final),
                            an_object_having_attributes(name: 'lsbdistrelease', value: value, type: :legacy),
                            an_object_having_attributes(name: 'lsbmajdistrelease',
                                                        value: value_final['major'], type: :legacy),
                            an_object_having_attributes(name: 'lsbminordistrelease',
                                                        value: value_final['minor'], type: :legacy))
        end
      end

      context 'when version_id could not be retrieve' do
        let(:value) { nil }

        it 'returns release fact as nil' do
          expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
            have_attributes(name: 'os.distro.release', value: value)
        end
      end
    end
  end
end
