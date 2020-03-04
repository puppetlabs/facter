# frozen_string_literal: true

describe Facts::El::Dmi::Chassis::Type do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Dmi::Chassis::Type.new }

    let(:type) { 'Low Profile Desktop' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:chassis_type).and_return(type)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:chassis_type)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.chassis.type', value: type)
    end
  end
end
