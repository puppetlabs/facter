# frozen_string_literal: true

describe Facter::Resolvers::Solaris::Disks do
  subject(:resolver) { Facter::Resolvers::Solaris::Disks }

  before do
    allow(File).to receive(:executable?).with('/usr/bin/kstat').and_return(status)
    allow(Facter::Core::Execution)
      .to receive(:execute)
      .with('/usr/bin/kstat sderr', logger: resolver.log)
      .and_return(output)
  end

  after do
    resolver.invalidate_cache
  end

  context 'when kstat is present and can retrieve information' do
    let(:value) do
      {
        'sd0' => {
          product: 'VMware IDE CDR00Revision',
          size: '0 bytes',
          size_bytes: 0,
          vendor: 'NECVMWar'
        },
        'sd1' => {
          product: 'Virtual disk    Revision',
          size: '20.00 GiB',
          size_bytes: 21_474_836_480,
          vendor: 'VMware'
        }
      }
    end
    let(:status) { true }
    let(:output) { load_fixture('kstat_sderr').read }

    it 'returns disks info' do
      expect(resolver.resolve(:disks)).to eq(value)
    end
  end

  context 'when kstat is not present' do
    let(:output) { '' }
    let(:status) { false }

    it 'returns nil' do
      expect(resolver.resolve(:disks)).to be_nil
    end
  end

  context 'when kstat is present but fails' do
    let(:output) { '' }
    let(:status) { true }

    it 'returns nil' do
      expect(resolver.resolve(:disks)).to be_nil
    end
  end
end
