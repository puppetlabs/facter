# frozen_string_literal: true

describe Facter::Resolvers::Wpar do
  describe '#oslevel 6.1+' do
    before do
      lparstat_w = load_fixture('lparstat_w').read
      expect(Open3).to receive(:capture2)
        .with('/usr/bin/lparstat -W 2>/dev/null')
        .and_return([lparstat_w, OpenStruct.new(success?: true)])
      Facter::Resolvers::Wpar.invalidate_cache
    end

    it 'returns wpar' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_key))              .to eq(13)
      expect(Facter::Resolvers::Wpar.resolve(:wpar_configured_id))    .to eq(14)
    end
  end

  describe '#oslevel 6.0' do
    before do
      expect(Open3).to receive(:capture2)
        .with('/usr/bin/lparstat -W 2>/dev/null')
        .and_return(['', OpenStruct.new(success?: false)]).twice

      Facter::Resolvers::Wpar.invalidate_cache
    end

    it 'does not return wpar' do
      expect(Facter::Resolvers::Wpar.resolve(:wpar_key))              .to be_nil
      expect(Facter::Resolvers::Wpar.resolve(:wpar_configured_id))    .to be_nil
    end
  end
end
