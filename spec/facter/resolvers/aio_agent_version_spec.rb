# frozen_string_literal: true

describe 'AgentResolver' do
  context '#resolve' do
    it 'detects puppet version' do
      allow(File).to receive(:read).with("#{ROOT_DIR}/lib/puppet/VERSION").and_return('7.0.1')
      expect(Facter::Resolvers::AgentResolver.resolve(:aio_agent_version)).to eql('7.0.1')
    end
  end
end
