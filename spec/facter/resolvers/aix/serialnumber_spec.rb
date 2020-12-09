# frozen_string_literal: true

describe Facter::Resolvers::Aix::Serialnumber do
  describe '#resolve' do
    before do
      odm = instance_spy('Facter::Util::Aix::ODMQuery')

      allow(Facter::Util::Aix::ODMQuery).to receive(:new).and_return(odm)
      allow(odm).to receive(:equals).with('name', 'sys0').and_return(odm)
      allow(odm).to receive(:equals).with('attribute', 'systemid')
      allow(odm).to receive(:execute).and_return(result)
    end

    after do
      Facter::Resolvers::Aix::Serialnumber.invalidate_cache
    end

    context 'when line contains value' do
      let(:result) { 'value = "IBM,0221684EW"' }

      it 'detects serialnumber' do
        expect(Facter::Resolvers::Aix::Serialnumber.resolve(:serialnumber)).to eql('21684EW')
      end
    end

    context 'when line does not include value key' do
      let(:result) { 'test = IBM,0221684EW' }

      it 'detects serialnumber as nil' do
        expect(Facter::Resolvers::Aix::Serialnumber.resolve(:serialnumber)).to be(nil)
      end
    end

    context 'when fails to retrieve fact' do
      let(:result) { '' }

      it 'detects serialnumber as nil' do
        expect(Facter::Resolvers::Aix::Serialnumber.resolve(:serialnumber)).to be(nil)
      end
    end
  end
end
