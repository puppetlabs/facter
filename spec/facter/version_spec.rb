# frozen_string_literal: true

describe Facter do
  describe '#reported and gemspec files version' do
    it 'checks that reported and facter.gemspec versions are the same' do
      gemspec_file_path = File.join(File.dirname(__FILE__), '..', '..', 'facter.gemspec')
      gemspec_facter_version = Gem::Specification.load(gemspec_file_path).version.to_s

      expect(gemspec_facter_version).to eq(Facter::VERSION)
    end
  end
end
