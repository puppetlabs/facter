# frozen_string_literal: true

describe Facts::El::Dmi::Board::Manufacturer do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Dmi::Board::Manufacturer.new }

    let(:manufacturer) { 'Intel Corporation' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:board_vendor).and_return(manufacturer)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:board_vendor)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.board.manufacturer', value: manufacturer)
    end
  end
end
