# frozen_string_literal: true

describe Facts::Sles::Os::Distro::Id do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Distro::Id.new }

    context 'when sles 12' do
      let(:expected_value) { 'SUSE LINUX' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve)
          .with(:version_id).and_return('12.1')
      end

      it 'calls Facter::Resolvers::OsRelease' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve)
          .with(:version_id)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.id', value: expected_value)
      end
    end

    context 'when sles 15' do
      let(:expected_value) { 'SUSE' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve)
          .with(:version_id).and_return('15')
      end

      it 'calls Facter::Resolvers::OsRelease' do
        fact.call_the_resolver
        expect(Facter::Resolvers::OsRelease).to have_received(:resolve)
          .with(:version_id)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.id', value: expected_value)
      end
    end
  end
end
