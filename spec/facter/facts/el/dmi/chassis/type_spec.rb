# frozen_string_literal: true

describe 'Fedora DmiChassisType' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'Low Profile Desktop'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.chassis.type', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:chassis_type).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.chassis.type', value).and_return(expected_fact)

      fact = Facter::El::DmiChassisType.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
