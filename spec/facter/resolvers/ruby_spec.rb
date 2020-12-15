# frozen_string_literal: true

describe Facter::Resolvers::Ruby do
  describe '#resolve ruby facts' do
    it 'detects ruby sitedir' do
      expect(Facter::Resolvers::Ruby.resolve(:sitedir)).to eql(RbConfig::CONFIG['sitelibdir'])
    end

    it 'detects ruby platform' do
      expect(Facter::Resolvers::Ruby.resolve(:platform)).to eql(RUBY_PLATFORM)
    end

    it 'detects ruby version' do
      expect(Facter::Resolvers::Ruby.resolve(:version)).to eql(RUBY_VERSION)
    end
  end
end
