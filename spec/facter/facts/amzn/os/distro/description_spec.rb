# frozen_string_literal: true

describe Facts::Amzn::Os::Distro::Description do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Amzn::Os::Distro::Description.new }

    let(:value) { 'Amazon Linux AMI release 2017.03' }

    before do
      allow(Facter::Resolvers::SpecificReleaseFile).to receive(:resolve)
        .with(:release, release_file: '/etc/system-release').and_return(value)
    end

    it 'calls Facter::Resolvers::SpecificReleaseFile' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SpecificReleaseFile).to have_received(:resolve)
        .with(:release, release_file: '/etc/system-release')
    end

    it 'returns release fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.description', value: value)
    end
  end
end
