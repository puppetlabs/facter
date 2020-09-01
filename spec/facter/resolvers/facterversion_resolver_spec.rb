# frozen_string_literal: true

describe Facter::Resolvers::Facterversion do
  describe '#resolve' do
    let(:version) { '4.0.1' }

    after { Facter::Resolvers::Facterversion.invalidate_cache }

    it 'detects facter version' do
      stub_const('Facter::VERSION', version)
      expect(Facter::Resolvers::Facterversion.resolve(:facterversion)).to eql('4.0.1')
    end

    context 'when there are new lines in the version file' do
      let(:version) { '4.0.2' }

      it 'removes them' do
        stub_const('Facter::VERSION', version)
        expect(Facter::Resolvers::Facterversion.resolve(:facterversion)).to eq('4.0.2')
      end
    end
  end
end
