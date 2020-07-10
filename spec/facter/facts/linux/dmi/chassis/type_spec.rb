# frozen_string_literal: true

describe Facts::Linux::Dmi::Chassis::Type do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Dmi::Chassis::Type.new }

    let(:type) { 'Low Profile Desktop' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:chassis_type).and_return(type)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:chassis_type)
    end

    it 'returns chassis type fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.chassis.type', value: type),
                        an_object_having_attributes(name: 'chassistype', value: type, type: :legacy))
    end
  end
end
