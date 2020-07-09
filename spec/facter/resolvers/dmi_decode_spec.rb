# frozen_string_literal: true

describe Facter::Resolvers::DmiDecode do
  describe '#resolve' do
    subject(:dmidecode) { Facter::Resolvers::DmiDecode }

    let(:command_output) { load_fixture('dmi_decode').read }

    before do
      allow(Facter::Core::Execution).to receive(:execute)
        .with('dmidecode', logger: instance_of(Facter::Log)).and_return(command_output)
    end

    after { dmidecode.invalidate_cache }

    it 'detects virtualbox version' do
      expect(dmidecode.resolve(:virtualbox_version)).to eql('6.1.4')
    end

    it 'detects virtualbox revision' do
      expect(dmidecode.resolve(:virtualbox_revision)).to eql('136177')
    end

    context 'when dmidecode command failed' do
      let(:command_output) { 'command not found: dmidecode' }

      it 'detects virtualbox version as nil' do
        expect(dmidecode.resolve(:virtualbox_version)).to be(nil)
      end

      it 'detects virtualbox revision as nil' do
        expect(dmidecode.resolve(:virtualbox_revision)).to be(nil)
      end
    end
  end
end
