# frozen_string_literal: true

describe 'AIX ArchitectureResolver' do
  describe '#resolve' do
    before do
      odm = double('ODMQuery')

      allow(Facter::ODMQuery).to receive(:new).and_return(odm)
      allow(odm).to receive(:equals).with('name', 'proc0').and_return(odm)
      allow(odm).to receive(:equals).with('attribute', 'type')
      allow(odm).to receive(:execute).and_return(result)
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
        expect(Facter::Resolvers::Architecture.resolve(:architecture)).to eql(nil)
      end
    end

    context 'when fails to retrieve fact' do
      let(:result) { nil }
      it 'detects architecture as nil' do
        expect(Facter::Resolvers::Architecture.resolve(:architecture)).to eql(nil)
      end
    end
  end
end
