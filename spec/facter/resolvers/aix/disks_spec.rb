# frozen_string_literal: true

describe Facter::Resolvers::Aix::Disks do
  subject(:resolver) { Facter::Resolvers::Aix::Disks }

  let(:logger_spy) { instance_spy(Facter::Log) }

  before do
    resolver.instance_variable_set(:@log, logger_spy)
    allow(Facter::Core::Execution).to receive(:execute).with('lspv', logger: logger_spy)
                                                       .and_return(result)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when retrieving disks name fails' do
    let(:result) { '' }

    it 'returns nil' do
      expect(resolver.resolve(:disks)).to be_nil
    end
  end

  context 'when lspv is successful' do
    let(:result) { load_fixture('lspv_output').read }

    let(:disks) do
      { 'hdisk0' => { size: '30.00 GiB', size_bytes: 32_212_254_720 } }
    end

    before do
      allow(Facter::Core::Execution).to receive(:execute).with('lspv hdisk0', logger: logger_spy)
                                                         .and_return(load_fixture('lspv_disk_output').read)
    end

    it 'returns disks informations' do
      expect(resolver.resolve(:disks)).to eql(disks)
    end

    context 'when second lspv call fails' do
      before do
        allow(Facter::Core::Execution).to receive(:execute).with('lspv hdisk0', logger: logger_spy)
                                                           .and_return('')
      end

      it 'returns disks informations' do
        expect(resolver.resolve(:disks)).to eq({})
      end
    end
  end
end
