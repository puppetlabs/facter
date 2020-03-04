# frozen_string_literal: true

describe Facts::El::Dmi::Board::Product do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::El::Dmi::Board::Product.new }

    let(:product) { '440BX Desktop Reference Platform' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:board_name).and_return(product)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:board_name)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dmi.board.product', value: product)
    end
  end
end
