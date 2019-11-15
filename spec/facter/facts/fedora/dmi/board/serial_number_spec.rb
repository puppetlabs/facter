# frozen_string_literal: true

describe 'Fedora DmiBoardSerialNumber' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      value = 'None'
      expected_fact = double(Facter::ResolvedFact, name: 'dmi.board.serial_number', value: value)
      allow(Facter::Resolvers::Linux::DmiBios).to receive(:resolve).with(:board_serial).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('dmi.board.serial_number', value).and_return(expected_fact)

      fact = Facter::Fedora::DmiBoardSerialNumber.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
