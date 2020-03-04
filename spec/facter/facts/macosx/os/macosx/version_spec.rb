# frozen_string_literal: true

describe Facts::Macosx::Os::Macosx::Version do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Os::Macosx::Version.new }

    let(:resolver_output) { '10.9.8' }
    let(:version) { { 'full' => '10.9.8', 'major' => '10.9', 'minor' => '8' } }

    before do
      allow(Facter::Resolvers::SwVers).to \
        receive(:resolve).with(:productversion).and_return(resolver_output)
    end

    it 'calls Facter::Resolvers::SwVers' do
      fact.call_the_resolver
      expect(Facter::Resolvers::SwVers).to have_received(:resolve).with(:productversion)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.macosx.version', value: version)
    end
  end
end
