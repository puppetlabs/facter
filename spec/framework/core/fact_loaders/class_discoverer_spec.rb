# frozen_string_literal: true

describe Facter::ClassDiscoverer do
  describe '#discover_classes' do
    let(:result) { [Facts::Windows::NetworkInterfaces, Facts::Windows::FipsEnabled] }

    it 'loads all classes' do
      allow(Module).to receive(:const_get).with('Facts::Windows').and_return(Facts::Windows)
      allow(Facts::Windows).to receive(:constants).and_return(%i[NetworkInterfaces FipsEnabled])

      expect(Facter::ClassDiscoverer.instance.discover_classes('Windows')).to eq(result)
    end

    it 'loads no classes' do
      allow(Module).to receive(:const_get).and_return([])

      expect(Facter::ClassDiscoverer.instance.discover_classes('Debian')).to eq([])
    end
  end
end
