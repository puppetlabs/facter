# frozen_string_literal: true

describe 'DmiResolver' do
  describe '#resolve' do
    context 'when it detects model' do
      let(:macosx_model) { 'MacBookPro11,4' }
      it 'detects model' do
        allow(Open3).to receive(:capture2).with('sysctl -n hw.model').and_return(macosx_model)
        expect(Facter::Resolvers::Macosx::DmiBios.resolve(:macosx_model)).to eql(macosx_model)
      end
    end
  end
end
