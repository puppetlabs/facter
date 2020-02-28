# frozen_string_literal: true

describe Facter::Debian::DmiChassisAssetTag do
  describe '#call_the_resolver' do
    subject(:fact) { Facter::Debian::DmiChassisAssetTag.new }

    let(:tag) { 'No Asset Tag' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:chassis_asset_tag).and_return(tag)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:chassis_asset_tag)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.chassis.asset_tag', value: tag)
    end
  end
end
