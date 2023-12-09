# frozen_string_literal: true

describe Facts::Amzn::Os::Distro::Codename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Os::Distro::Codename.new }

    before do
      allow(Facter::Resolvers::SpecificReleaseFile).to receive(:resolve)
        .with(:release, { release_file: '/etc/system-release' }).and_return(value)
    end

    context 'when codename is not in system-release' do
      let(:value) { 'Amazon Linux AMI release 2017.03' }
      let(:expected_value) { 'n/a' }

      it "returns 'n/a' fact value" do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: expected_value)
      end
    end

    context 'when codename is in system-release' do
      let(:value) { 'Amazon Linux release 2 (2017.12) LTS Release Candidate' }
      let(:expected_value) { '2017.12' }

      it 'returns release fact' do
        expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
          have_attributes(name: 'os.distro.codename', value: expected_value)
      end
    end
  end
end
