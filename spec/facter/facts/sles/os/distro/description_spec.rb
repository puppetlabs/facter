# frozen_string_literal: true

describe Facts::Sles::Os::Distro::Description do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Sles::Os::Distro::Description.new }

    let(:value) { 'SUSE Linux Enterprise Server 15' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve)
        .with(:pretty_name).and_return(value)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.description', value: value)
    end
  end
end
