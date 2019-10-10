# frozen_string_literal: true

describe 'ClassDiscoverer' do
  describe '#discover_classes' do
    it 'loads all classes' do
      allow_any_instance_of(Module).to receive(:constants).and_return(%i[NetworkInterface OsName])

      expect(Facter::ClassDiscoverer.instance.discover_classes('Ubuntu')).to eq(%i[NetworkInterface OsName])
    end

    it 'loads no classes' do
      allow_any_instance_of(Module).to receive(:constants).and_return([])

      expect(Facter::ClassDiscoverer.instance.discover_classes('Ubuntu')).to eq([])
    end
  end
end
