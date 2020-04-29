# frozen_string_literal: true

describe Facts::Debian::Os::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Release.new }

    shared_examples 'calls Facter::Resolvers::OsRelease with :name' do
      it 'calls Facter::Resolvers::OsRelease with :name' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:name)
      end
    end

    shared_examples 'returns os release fact' do
      it 'returns os release fact' do
        expect(fact.call_the_resolver).to match_array \
          [
            having_attributes(name: 'os.release', value: fact_value),
            having_attributes(name: 'operatingsystemmajrelease', value: fact_value['major'],
                              type: :legacy),
            having_attributes(name: 'operatingsystemrelease', value: fact_value['full'],
                              type: :legacy)
          ]
      end
    end

    shared_examples 'returns os release fact as nil' do
      it 'returns os release fact as nil' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.release', value: fact_value)
      end
    end

    context 'when os is Ubuntu' do
      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:name).and_return(os_name)
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release_value)
      end

      let(:os_name) { 'Ubuntu' }

      context 'when version_id is retrieved successful' do
        let(:os_release_value) { '18.04' }
        let(:fact_value) { { 'full' => '18.04', 'major' => '18.04' } }

        it_behaves_like 'calls Facter::Resolvers::OsRelease with :name'

        it 'calls Facter::Resolvers::OsRelease with :version_id' do
          fact.call_the_resolver
          expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_id)
        end

        it_behaves_like 'returns os release fact'
      end

      context 'when version has no minor' do
        let(:os_release_value) { 'bullseye/sid' }
        let(:fact_value) { { 'full' => 'bullseye/sid', 'major' => 'bullseye/sid' } }

        it_behaves_like 'returns os release fact'
      end

      context 'when version_id could not be retrieve' do
        let(:os_release_value) { nil }
        let(:fact_value) { nil }

        it_behaves_like 'returns os release fact as nil'
      end
    end

    context 'when os is Debian' do
      let(:os_name) { 'Debian' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:name).and_return(os_name)
        allow(Facter::Resolvers::DebianVersion).to receive(:resolve).with(:version).and_return(os_release_value)
      end

      context 'when version_id is retrieved successful' do
        let(:os_release_value) { '10.02' }
        let(:fact_value) { { 'full' => '10.02', 'major' => '10', 'minor' => '2' } }

        it_behaves_like 'calls Facter::Resolvers::OsRelease with :name'

        it 'calls Facter::Resolvers::DebianVersion' do
          fact.call_the_resolver
          expect(Facter::Resolvers::DebianVersion).to have_received(:resolve).with(:version)
        end

        it_behaves_like 'returns os release fact'
      end

      context 'when version has no minor' do
        let(:os_release_value) { 'testing/release' }
        let(:fact_value) { { 'full' => 'testing/release', 'major' => 'testing/release' } }

        it_behaves_like 'returns os release fact'
      end

      context 'when version_id could not §be retrieve' do
        let(:os_release_value) { nil }
        let(:fact_value) { nil }

        it_behaves_like 'returns os release fact as nil'
      end
    end
  end
end
