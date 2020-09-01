# frozen_string_literal: true

describe Facter::Resolvers::Freebsd::DmiBios do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Freebsd::DmiBios }

    let(:bios_date) { '12/12/2018' }
    let(:bios_vendor) { 'Phoenix Technologies LTD' }
    let(:bios_version) { '6.00' }
    let(:product_name) { 'VMware Virtual Platform' }
    let(:product_serial) { 'VMware-42 1a 02 ea e6 27 76 b8-a1 23 a7 8a d3 12 ee cf' }
    let(:product_uuid) { 'ea021a42-27e6-b876-a123-a78ad312eecf' }
    let(:sys_vendor) { 'VMware, Inc.' }

    before do
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.bios.reldate')
        .and_return(bios_date)
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.bios.vendor')
        .and_return(bios_vendor)
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.bios.version')
        .and_return(bios_version)
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.system.product')
        .and_return(product_name)
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.system.serial')
        .and_return(product_serial)
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.system.uuid')
        .and_return(product_uuid)
      allow(Facter::Freebsd::FfiHelper).to receive(:kenv)
        .with(:get, 'smbios.system.maker')
        .and_return(sys_vendor)
    end

    after do
      Facter::Resolvers::Freebsd::DmiBios.invalidate_cache
    end

    context 'when bios_date is available' do
      it 'returns bios_release_date' do
        expect(resolver.resolve(:bios_date)).to eq(bios_date)
      end
    end

    context 'when bios_vendor is available' do
      it 'returns bios_release_date' do
        expect(resolver.resolve(:bios_vendor)).to eq(bios_vendor)
      end
    end

    context 'when bios_version is available' do
      it 'returns bios_version' do
        expect(resolver.resolve(:bios_version)).to eq(bios_version)
      end
    end

    context 'when sys_vendor is available' do
      it ' returns sys_vendor' do
        expect(resolver.resolve(:sys_vendor)).to eq(sys_vendor)
      end
    end

    context 'when product_name is available' do
      it 'returns product_name' do
        expect(resolver.resolve(:product_name)).to eq(product_name)
      end
    end

    context 'when product_serial is available' do
      it 'returns product_serial_number' do
        expect(resolver.resolve(:product_serial)).to eq(product_serial)
      end
    end

    context 'when product_uuid is available' do
      it 'returns product_uuid' do
        expect(resolver.resolve(:product_uuid)).to eq(product_uuid)
      end
    end
  end
end
