# frozen_string_literal: true

describe 'FacterversionResolver' do
  describe '#resolve' do
    let(:version) { '4.0.1' }

    before { allow(File).to receive(:read).with("#{ROOT_DIR}/VERSION").and_return(version) }
    after { Facter::Resolvers::Facterversion.invalidate_cache }

    it 'detects facter version' do
      expect(Facter::Resolvers::Facterversion.resolve(:facterversion)).to eql('4.0.1')
    end

    context 'when there are new lines in the version file' do
      let(:version) { "4.0.2\n\n" }

      it 'removes them' do
        expect(Facter::Resolvers::Facterversion.resolve(:facterversion)).to eq('4.0.2')
      end
    end
  end
end
