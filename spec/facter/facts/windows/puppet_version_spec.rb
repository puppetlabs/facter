# frozen_string_literal: true

describe Facts::Windows::PuppetVersion do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::PuppetVersion.new }

    let(:puppet_version) { '6.11.0' }

    before do
      allow(Facter::Resolvers::PuppetVersionResolver).to \
        receive(:resolve).with(:puppetversion).and_return(puppet_version)
    end

    it 'calls Facter::Resolvers::Puppetversion' do
      fact.call_the_resolver
      expect(Facter::Resolvers::PuppetVersionResolver).to have_received(:resolve).with(:puppetversion)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'puppetversion', value: puppet_version)
    end
  end
end
