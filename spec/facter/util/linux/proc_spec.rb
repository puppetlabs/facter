# frozen_string_literal: true

describe Facter::Util::Linux::Proc do
  describe '#getenv_for_pid' do
    before do
      allow(Facter::Util::FileHelper).to receive(:safe_readlines)
        .with('/proc/1/environ', [], "\0", { chomp: true })
        .and_return(proc_environ.readlines("\0", chomp: true))
    end

    context 'when field exists' do
      let(:proc_environ) { load_fixture('proc_environ_podman') }

      it 'returns the field' do
        result = Facter::Util::Linux::Proc.getenv_for_pid(1, 'container')
        expect(result).to eq('podman')
      end
    end

    context 'when field does not exist' do
      let(:proc_environ) { load_fixture('proc_environ_podman') }

      it 'returns nil' do
        result = Facter::Util::Linux::Proc.getenv_for_pid(1, 'butter')
        expect(result).to eq(nil)
      end
    end

    context 'when field is empty' do
      let(:proc_environ) { load_fixture('proc_environ_no_value') }

      it 'returns an empty string' do
        result = Facter::Util::Linux::Proc.getenv_for_pid(1, 'bubbles')
        expect(result).to eq('')
      end
    end
  end
end
