# frozen_string_literal: true

describe Facts::Linux::Dmi::Board::Manufacturer do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Dmi::Board::Manufacturer.new }

    let(:manufacturer) { 'Intel Corporation' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:board_vendor).and_return(manufacturer)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:board_vendor)
    end

    it 'returns board manufacturer fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.board.manufacturer', value: manufacturer),
                        an_object_having_attributes(name: 'boardmanufacturer', value: manufacturer, type: :legacy))
    end
  end
end
