# frozen_string_literal: true

describe 'FacterversionResolver' do
  context '#resolve' do
    it 'detects facter version' do
      allow(File).to receive(:read).with("#{ROOT_DIR}/VERSION").and_return('4.0.1')
      expect(Facter::Resolver::FacterversionResolver.resolve(:facterversion)).to eql('4.0.1')
    end
  end
end
