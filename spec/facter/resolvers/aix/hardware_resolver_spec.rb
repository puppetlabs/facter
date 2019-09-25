# frozen_string_literal: true

describe 'AIX HardwareResolver' do
  describe '#resolve' do
    before do
      odm = double('ODMQuery')

      allow(Facter::ODMQuery).to receive(:new).and_return(odm)
      allow(odm).to receive(:equals).with('name', 'sys0').and_return(odm)
      allow(odm).to receive(:equals).with('attribute', 'modelname')
      allow(odm).to receive(:execute).and_return(result)
    end
    after do
      Facter::Resolvers::Hardware.invalidate_cache
    end

    context 'when line contains value' do
      let(:result) { 'value = hardware' }
      it 'detects hardware' do
        expect(Facter::Resolvers::Hardware.resolve(:hardware)).to eql('hardware')
      end
    end

    context 'when line does not contain value' do
      let(:result) { 'test = hardware' }
      it 'detects hardware as nil' do
        expect(Facter::Resolvers::Hardware.resolve(:hardware)).to eql(nil)
      end
    end

    context 'when fails to retrieve fact' do
      let(:result) { nil }
      it 'detects hardware as nil' do
        expect(Facter::Resolvers::Hardware.resolve(:hardware)).to eql(nil)
      end
    end
  end
end
