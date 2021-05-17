# frozen_string_literal: true

describe Facter::Resolvers::Ruby do
  before do
    Facter::Resolvers::Ruby.invalidate_cache
  end

  describe '#resolve ruby facts' do
    it 'detects ruby sitedir' do
      expect(Facter::Resolvers::Ruby.resolve(:sitedir)).to eql(RbConfig::CONFIG['sitelibdir'])
    end

    it 'does not resolve the sitedir fact if sitedir does not exist' do
      allow(RbConfig::CONFIG).to receive(:[]).with('sitedir').and_return(nil)
      expect(Facter::Resolvers::Ruby.resolve(:sitedir)).to be(nil)
    end

    it 'detects ruby platform' do
      expect(Facter::Resolvers::Ruby.resolve(:platform)).to eql(RUBY_PLATFORM)
    end

    it 'detects ruby version' do
      expect(Facter::Resolvers::Ruby.resolve(:version)).to eql(RUBY_VERSION)
    end
  end
end
