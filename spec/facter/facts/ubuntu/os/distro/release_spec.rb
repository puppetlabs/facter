# frozen_string_literal: true

describe Facts::Ubuntu::Os::Distro::Release do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Ubuntu::Os::Distro::Release.new }

    shared_examples 'returns distro release fact' do
      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.release', value: fact_value)
      end
    end

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_id).and_return(os_release_value)
    end

    context 'when version_id is retrieved successful' do
      let(:os_release_value) { '18.04' }
      let(:fact_value) { { 'full' => '18.04', 'major' => '18.04' } }

      it 'calls Facter::Resolvers::OsRelease with :version_id' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_id)
      end

      it_behaves_like 'returns distro release fact'
    end

    context 'when version_id could not be retrieved' do
      let(:os_release_value) { nil }
      let(:fact_value) { nil }

      it_behaves_like 'returns distro release fact'
    end

    context 'when version has no minor' do
      let(:os_release_value) { 'experimental_release' }
      let(:fact_value) { { 'full' => 'experimental_release', 'major' => 'experimental_release' } }

      it_behaves_like 'returns distro release fact'
    end
  end
end
