# frozen_string_literal: true

describe Facts::Debian::Dmi::Board::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Dmi::Board::SerialNumber.new }

    let(:serial_number) { 'None' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:board_serial).and_return(serial_number)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:board_serial)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.board.serial_number', value: serial_number)
    end
  end
end
