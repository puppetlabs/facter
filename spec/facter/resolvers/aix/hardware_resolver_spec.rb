# frozen_string_literal: true

describe 'AIX HardwareResolver' do
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

  context '#resolve' do
    let(:result) { 'value = hardware' }
    it 'detects architecture' do
      expect(Facter::Resolvers::Hardware.resolve(:hardware)).to eql('hardware')
    end
  end

  context '#resolve when fails to retrieve fact' do
    let(:result) { nil }
    it 'detects virtual machine manufacturer' do
      expect(Facter::Resolvers::Hardware.resolve(:hardware)).to eql(nil)
    end
  end
end
