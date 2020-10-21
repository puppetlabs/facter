# frozen_string_literal: true

describe Facter::Resolvers::Architecture do
  describe '#resolve' do
    before do
      odm1 = instance_double(Facter::ODMQuery)
      odm2 = instance_double(Facter::ODMQuery)

      allow(Facter::ODMQuery).to receive(:new).and_return(odm1, odm2)
      allow(odm1).to receive(:equals).with('PdDvLn', 'processor/sys/proc_rspc').and_return(odm1)
      allow(odm1).to receive(:equals).with('status', '1').and_return(odm1)
      allow(odm1).to receive(:execute).and_return('proc8')

      allow(odm2).to receive(:equals).with('name', 'proc8').and_return(odm2)
      allow(odm2).to receive(:equals).with('attribute', 'type').and_return(odm2)
      allow(odm2).to receive(:execute).and_return(result)
    end

    after do
      Facter::Resolvers::Architecture.invalidate_cache
    end

    context 'when line contains value' do
      let(:result) { 'value = x86' }

      it 'detects architecture' do
        expect(Facter::Resolvers::Architecture.resolve(:architecture)).to eql('x86')
      end
    end

    context 'when line does not value' do
      let(:result) { 'test = x86' }

      it 'detects architecture as nil' do
        expect(Facter::Resolvers::Architecture.resolve(:architecture)).to be(nil)
      end
    end

    context 'when fails to retrieve fact' do
      let(:result) { nil }

      it 'detects architecture as nil' do
        expect(Facter::Resolvers::Architecture.resolve(:architecture)).to be(nil)
      end
    end
  end
end
