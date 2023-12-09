# frozen_string_literal: true

describe Facts::Sles::Os::Distro::Codename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Distro::Codename.new }

    context 'when codename is not in os-release' do
      let(:value) { nil }
      let(:expected_value) { 'n/a' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve)
          .with(:version_codename).and_return(value)
      end

      it "returns 'n/a' fact value" do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: expected_value)
      end
    end

    context 'when codename is empty' do
      let(:value) { '' }
      let(:expected_value) { 'n/a' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve)
          .with(:version_codename).and_return(value)
      end

      it "returns 'n/a' fact value" do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: expected_value)
      end
    end

    context 'when codename is in os-release' do
      let(:value) { 'SP1' }
      let(:expected_value) { 'SP1' }

      before do
        allow(Facter::Resolvers::OsRelease).to receive(:resolve)
          .with(:version_codename).and_return(value)
      end

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: expected_value)
      end
    end
  end
end
