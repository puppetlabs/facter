# frozen_string_literal: true

describe 'Facter::Util::Resolvers::Http' do
  subject(:aws_token) { Facter::Util::Resolvers::AwsToken }

  before do
    Facter::Util::Resolvers::AwsToken.reset
  end

  after do
    Facter::Util::Resolvers::AwsToken.reset
  end

  describe '#get' do
    it 'calls Facter::Util::Resolvers::Http.put_request' do
      allow(Facter::Util::Resolvers::Http).to receive(:put_request)
      aws_token.get
      expect(Facter::Util::Resolvers::Http).to have_received(:put_request)
    end

    it 'does make a second request if token is still available' do
      allow(Facter::Util::Resolvers::Http).to receive(:put_request).and_return('token')
      aws_token.get(1000)
      aws_token.get(1000)
      expect(Facter::Util::Resolvers::Http).to have_received(:put_request).once
    end

    it 'makes a second request if token is expired' do
      allow(Facter::Util::Resolvers::Http).to receive(:put_request).and_return('token')
      aws_token.get(1)
      now = Time.now
      allow(Time).to receive(:now).and_return(now + 2)
      aws_token.get(1)
      expect(Facter::Util::Resolvers::Http).to have_received(:put_request).twice
    end
  end
end
