# frozen_string_literal: true

require 'net/http'

describe Facter::Util::Resolvers::Http do
  subject(:http) { Facter::Util::Resolvers::Http }

  describe '#get_request' do
    let(:url) { 'http://169.254.169.254/meta-data/' }
    let(:uri) { URI.parse(url) }
    let(:http_spy) { instance_spy(Net::HTTP) }
    let(:http_get_spy) { instance_spy(Net::HTTP::Get) }
    let(:response_spy) { instance_spy(Net::HTTPOK) }
    let(:log_spy) { instance_spy(Facter::Log) }

    before do
      http.instance_variable_set(:@log, log_spy)

      allow(Net::HTTP).to receive(:new).with(uri.host).and_return(http_spy)
      allow(Net::HTTP::Get).to receive(:new).with(uri.request_uri, {}).and_return(http_get_spy)
      allow(http_spy).to receive(:request).with(http_get_spy).and_return(response_spy)

      allow(response_spy).to receive(:code).and_return(200)
      allow(response_spy).to receive(:body).and_return(output)
    end

    context 'when http get request is successful' do
      let(:output) { 'request output' }

      it 'returns the output' do
        expect(http.get_request(url)).to eq(output)
      end
    end

    shared_examples 'logs error and output is empty string' do
      let(:output) { '' }

      it 'returns empty string' do
        expect(http.get_request(url)).to eq(output)
      end

      it 'logs error code' do
        http.get_request(url)
        expect(log_spy).to have_received(:debug).with(log_message)
      end
    end

    context 'when http get request has error code' do
      let(:log_message) { 'Request to api/url failed with error code 404' }

      before do
        allow(response_spy).to receive(:code).and_return(404)
        allow(response_spy).to receive(:uri).and_return('api/url')
      end

      it_behaves_like 'logs error and output is empty string'
    end

    context 'when http get request fails due to timeout' do
      let(:log_message) { 'Trying to connect to http://169.254.169.254/meta-data/ but got: Net::OpenTimeout' }

      before do
        allow(http_spy).to receive(:request).with(http_get_spy).and_raise(Net::OpenTimeout)
      end

      it_behaves_like 'logs error and output is empty string'
    end
  end
end
