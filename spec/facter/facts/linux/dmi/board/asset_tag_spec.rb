# frozen_string_literal: true

describe Facts::Linux::Dmi::Board::AssetTag do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Dmi::Board::AssetTag.new }

    let(:asset_tag) { 'Not Specified' }

    before do
      allow(Facter::Resolvers::Linux::DmiBios).to \
        receive(:resolve).with(:board_asset_tag).and_return(asset_tag)
    end

    it 'calls Facter::Resolvers::Linux::DmiBios' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Linux::DmiBios).to have_received(:resolve).with(:board_asset_tag)
    end

    it 'returns board asset_tag fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'dmi.board.asset_tag', value: asset_tag),
                        an_object_having_attributes(name: 'boardassettag', value: asset_tag, type: :legacy))
    end
  end
end
