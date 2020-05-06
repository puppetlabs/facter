# frozen_string_literal: true

describe Facts::Linux::Dmi::Chassis::AssetTag do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Dmi::Chassis::AssetTag.new }

    let(:tag) { 'No Asset Tag' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:chassis_asset_tag).and_return(tag)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:chassis_asset_tag)
    end

    it 'returns chassis asset tag fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.chassis.asset_tag', value: tag),
                        an_object_having_attributes(name: 'chassisassettag', value: tag, type: :legacy))
    end
  end
end
