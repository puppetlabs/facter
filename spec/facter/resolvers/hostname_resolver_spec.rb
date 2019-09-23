# frozen_string_literal: true

describe 'HostnameResolver' do
  before do
    allow(Open3).to receive(:capture2).with('hostname').and_return(host)
  end

  context '#resolve' do
    let(:host) { 'hostname' }

    it 'detects that hostname is nil' do
      expect(Facter::Resolvers::Hostname.resolve(:hostname)).to eql('hostname')
    end
  end
end
