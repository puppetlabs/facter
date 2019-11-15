# frozen_string_literal: true

describe 'Fedora DmiChassisAssetTag' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'No Asset Tag'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.chassis.asset_tag', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:chassis_asset_tag).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.chassis.asset_tag', value).and_return(expected_fact)

      fact = Facter::Fedora::DmiChassisAssetTag.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
