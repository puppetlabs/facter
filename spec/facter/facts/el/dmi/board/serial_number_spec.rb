# frozen_string_literal: true

describe Facts::El::Dmi::Board::SerialNumber do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Dmi::Board::SerialNumber.new }

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
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.board.serial_number', value: serial_number),
                        an_object_having_attributes(name: 'boardserialnumber', value: serial_number, type: :legacy))
    end
  end
end
