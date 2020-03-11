# frozen_string_literal: true

describe Facter::Resolvers::Linux::DmiBios do
  describe '#resolve' do
    subject(:resolver) { Facter::Resolvers::Linux::DmiBios }

    let(:test_dir) { '/sys/class/dmi' }

    before do
      allow(File).to receive(:directory?).with(test_dir).and_return(true)
      allow(File).to receive(:readable?).with("/sys/class/dmi/id/#{file}").and_return(true)
      allow(File).to receive(:read).with("/sys/class/dmi/id/#{file}").and_return(file_content)
    end

    context 'when bios_date file exists' do
      let(:file_content) { '12/12/2018' }
      let(:file) { 'bios_date' }

      it 'returns bios_release_date' do
        expect(resolver.resolve(:bios_date)).to eq(file_content)
      end
    end

    context 'when bios_vendor file exists' do
      let(:file_content) { 'Phoenix Technologies LTD' }
      let(:file) { 'bios_vendor' }

      it 'returns bios_release_date' do
        expect(resolver.resolve(:bios_vendor)).to eq(file_content)
      end
    end

    context 'when bios_version file exists' do
      let(:file_content) { '6.00' }
      let(:file) { 'bios_version' }

      it 'returns bios_version' do
        expect(resolver.resolve(:bios_version)).to eq(file_content)
      end
    end

    context 'when board_vendor file exists' do
      let(:file_content) { 'Intel Corporation' }
      let(:file) { 'board_vendor' }

      it 'returns board_manufacturer' do
        expect(resolver.resolve(:board_vendor)).to eq(file_content)
      end
    end

    context 'when board_name file exists' do
      let(:file_content) { '440BX Desktop Reference Platform' }
      let(:file) { 'board_name' }

      it 'returns board_product' do
        expect(resolver.resolve(:board_name)).to eq(file_content)
      end
    end

    context 'when board_serial file exists' do
      let(:file_content) { 'None' }
      let(:file) { 'board_serial' }

      it 'returns board_serial_number' do
        expect(resolver.resolve(:board_serial)).to eq(file_content)
      end
    end

    context 'when chassis_asset_tag file exists' do
      let(:file_content) { 'No Asset Tag' }
      let(:file) { 'chassis_asset_tag' }

      it 'returns chassis_asset_tag' do
        expect(resolver.resolve(:chassis_asset_tag)).to eq(file_content)
      end
    end

    context 'when chassis_type file exists' do
      let(:file_content) { '4' }
      let(:file) { 'chassis_type' }

      it 'returns chassis_type' do
        expect(resolver.resolve(:chassis_type)).to eq('Low Profile Desktop')
      end
    end

    context 'when sys_vendor file exists' do
      let(:file_content) { 'VMware, Inc.' }
      let(:file) { 'sys_vendor' }

      it ' returns sys_vendor' do
        expect(resolver.resolve(:sys_vendor)).to eq(file_content)
      end
    end

    context 'when product_name file exists' do
      let(:file_content) { 'VMware Virtual Platform' }
      let(:file) { 'product_name' }

      it 'returns product_name' do
        expect(resolver.resolve(:product_name)).to eq(file_content)
      end
    end

    context 'when product_serial file exists' do
      let(:file_content) { 'VMware-42 1a 02 ea e6 27 76 b8-a1 23 a7 8a d3 12 ee cf' }
      let(:file) { 'product_serial' }

      it 'returns product_serial_number' do
        expect(resolver.resolve(:product_serial)).to eq(file_content)
      end
    end

    context 'when product_uuid file exists' do
      let(:file_content) { 'ea021a42-27e6-b876-a123-a78ad312eecf' }
      let(:file) { 'product_uuid' }

      it 'returns product_uuid' do
        expect(resolver.resolve(:product_uuid)).to eq(file_content)
      end
    end
  end
end
