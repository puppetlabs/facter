# frozen_string_literal: true

describe Facter::Resolvers::Wpar do
  before do
    allow(Open3).to receive(:capture2)
      .with('/usr/bin/lparstat -W 2>/dev/null')
      .and_return(open3_result)
  end

  after do
    Facter::Resolvers::Wpar.invalidate_cache
  end

  describe '#oslevel 6.1+' do
    let(:lparstat_w) { load_fixture('lparstat_w').read }
    let(:open3_result) { [lparstat_w, OpenStruct.new(success?: true)] }

    it 'returns wpar_key' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_key)).to eq(13)
    end

    it 'returns wpar_configured_id' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_configured_id)).to eq(14)
    end
  end

  describe '#oslevel 6.0' do
    let(:open3_result) { ['', OpenStruct.new(success?: false)] }

    it 'does not return wpar_key' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_key)).to be_nil
    end

    it 'does not return wpar_configured_id' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_configured_id)).to be_nil
    end
  end
end
