# frozen_string_literal: true

describe Facts::Rhel::Os::Distro::Description do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Rhel::Os::Distro::Description.new }

    let(:value) { 'CentOS Linux release 7.2.1511 (Core)' }

    before do
      allow(Facter::Resolvers::RedHatRelease).to receive(:resolve)
        .with(:description).and_return(value)
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.description', value: value)
    end
  end
end
