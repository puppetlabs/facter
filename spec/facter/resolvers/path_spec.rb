# frozen_string_literal: true

describe Facter::Resolvers::Path do
  describe '#resolve path' do
    it 'detects path' do
      expect(Facter::Resolvers::Path.resolve(:path)).to eql(ENV['PATH'])
    end
  end
end
