# frozen_string_literal: true

describe Facter::ClassDiscoverer do
  describe '#discover_classes' do
    it 'loads all classes' do
      allow_any_instance_of(Module).to receive(:constants).and_return(%i[NetworkInterfaces OsName])

      expect(Facter::ClassDiscoverer.instance.discover_classes('Windows')).to eq(%i[NetworkInterfaces OsName])
    end

    it 'loads no classes' do
      allow_any_instance_of(Module).to receive(:constants).and_return([])

      expect(Facter::ClassDiscoverer.instance.discover_classes('Debian')).to eq([])
    end
  end
end
