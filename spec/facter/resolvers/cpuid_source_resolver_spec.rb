# frozen_string_literal: true

describe 'CpuidSource' do
  before do
    allow(Cpuid).to receive(:find).with(leaf).and_return(array_result)
  end
  after do
    Facter::Resolvers::CpuidSource.invalidate_cache
  end

  describe '#resolve' do
    context 'when it can retrieve vendor but is not xen' do
      let(:leaf) { 0x40000000 }
      let(:array_result) { [3, 'string'] }

      it 'detects vendor' do
        expect(Facter::Resolvers::CpuidSource.resolve(:vendor)).to eql('string')
      end

      it "detects that isn't a xen hypervisor" do
        expect(Facter::Resolvers::CpuidSource.resolve(:xen)).to eql(false)
      end
    end

    context 'when hypervisor is xen' do
      let(:leaf) { 0x40000000 }
      let(:array_result) { [256, 'string'] }
      let(:array_result2) { [256, 'XenVMMXenVMM'] }

      it 'detects that is a xen hypervisor' do
        allow(Cpuid).to receive(:find).with(leaf + 0x100).and_return(array_result2)
        expect(Facter::Resolvers::CpuidSource.resolve(:xen)).to eql(true)
      end
    end
  end
end
