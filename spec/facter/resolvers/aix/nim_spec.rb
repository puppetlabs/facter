# frozen_string_literal: true

describe Facter::Resolvers::Aix::Nim do
  subject(:nim_resolver) { Facter::Resolvers::Aix::Nim }

  after do
    nim_resolver.invalidate_cache
  end

  before do
    allow(Facter::Util::FileHelper).to receive(:safe_readlines)
      .with('/etc/niminfo')
      .and_return(niminfo_content)
  end

  context 'when niminfo file is not readable' do
    let(:type) { nil }
    let(:niminfo_content) { nil }

    it 'returns nil' do
      expect(nim_resolver.resolve(:type)).to eq(type)
    end
  end

  context 'when niminfo file is readable' do
    context 'when NIM_CONFIGURATION field is missing from file' do
      let(:type) { nil }
      let(:niminfo_content) { load_fixture('niminfo_wo_nim_configuration').read }

      it 'returns nil' do
        expect(nim_resolver.resolve(:type)).to eq(type)
      end
    end

    context 'when NIM_CONFIGURATION field is not master nor standalone' do
      let(:type) { nil }
      let(:niminfo_content) { load_fixture('niminfo_w_wrong_nim_configuration').read }

      it 'returns nil' do
        expect(nim_resolver.resolve(:type)).to eq(type)
      end
    end

    context 'when NIM_CONFIGURATION field is correct' do
      let(:type) { nil }
      let(:niminfo_content) { load_fixture('niminfo_nim_configuration').read }

      it 'returns master' do
        expect(nim_resolver.resolve(:type)).to eq(type)
      end
    end
  end
end
