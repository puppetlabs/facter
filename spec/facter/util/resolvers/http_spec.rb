# frozen_string_literal: true

describe Facter::Util::Resolvers::Http do
  subject(:http) { Facter::Util::Resolvers::Http }

  let(:url) { 'http://169.254.169.254/meta-data/' }
  let(:log_spy) { instance_spy(Facter::Log) }

  before do
    http.instance_variable_set(:@log, log_spy)
    allow(Gem).to receive(:win_platform?).and_return(false)
  end

  RSpec.shared_examples 'a http request' do
    context 'when success' do
      before do
        stub_request(http_verb, url).to_return(status: 200, body: 'success')
      end

      it 'returns the body of the response' do
        expect(http.send(client_method, url)).to eql('success')
      end
    end

    context 'when setting specific headers' do
      let(:headers) { { 'Content-Type' => 'application/json' } }

      before do
        stub_request(http_verb, url).with(headers: headers).and_return(body: 'success')
      end

      it 'adds them to the request' do
        expect(http.send(client_method, url, headers)).to eql('success')
      end
    end

    context 'when server response with error' do
      before do
        stub_request(http_verb, url).to_return(status: 500, body: 'Internal Server Error')
      end

      it 'returns empty string' do
        expect(http.send(client_method, url)).to eql('')
      end

      it 'logs error code' do
        http.send(client_method, url)
        expect(log_spy).to have_received(:debug).with("Request to #{url} failed with error code 500")
      end
    end

    context 'when timeout is reached' do
      before do
        stub_request(http_verb, url).to_timeout
      end

      it 'returns empty string' do
        expect(http.send(client_method, url)).to eql('')
      end

      it 'logs error message' do
        http.send(client_method, url)
        expect(log_spy).to have_received(:debug)
          .with("Trying to connect to #{url} but got: execution expired")
      end
    end

    context 'when http request raises error' do
      before do
        stub_request(http_verb, url).to_raise(StandardError.new('some error'))
      end

      it 'returns empty string' do
        expect(http.send(client_method, url)).to eql('')
      end

      it 'logs error message' do
        http.send(client_method, url)
        expect(log_spy).to have_received(:debug).with("Trying to connect to #{url} but got: some error")
      end
    end
  end

  RSpec.shared_examples 'a http request on windows' do
    it_behaves_like 'a http request'

    context 'when host is unreachable ' do
      before do
        allow(Socket).to receive(:tcp)
          .with('169.254.169.254', 80, { connect_timeout: 0.6 })
          .and_raise(Errno::ETIMEDOUT)
      end

      it 'returns empty string' do
        expect(http.send(client_method, url)).to eql('')
      end

      it 'logs error message' do
        http.send(client_method, url)
        expect(log_spy).to have_received(:debug)
          .with(/((Operation|Connection) timed out)|(A connection attempt.*)/)
      end
    end

    context 'when timeout is configured' do
      let(:socket_spy) { class_spy(Socket) }

      before do
        stub_const('Socket', socket_spy)
        stub_request(http_verb, url)
        allow(Socket).to receive(:tcp).with('169.254.169.254', 80, { connect_timeout: 10 })
      end

      it 'uses the desired value' do
        http.send(client_method, url, {}, { connection: 10 })
        expect(socket_spy).to have_received(:tcp).with('169.254.169.254', 80, { connect_timeout: 10 })
      end
    end
  end

  describe '#get_request' do
    let(:http_verb) { :get }
    let(:client_method) { :get_request }

    it_behaves_like 'a http request'
  end

  describe '#put_request' do
    let(:http_verb) { :put }
    let(:client_method) { :put_request }

    it_behaves_like 'a http request'
  end

  context 'when windows' do
    before do
      # The Windows implementation of sockets does not respect net/http
      # timeouts, so the http client checks if the target is reachable using Socket.tcp
      allow(Gem).to receive(:win_platform?).and_return(true)
      allow(Socket).to receive(:tcp).with('169.254.169.254', 80, { connect_timeout: 0.6 })
    end

    describe '#get_request' do
      let(:http_verb) { :get }
      let(:client_method) { :get_request }

      it_behaves_like 'a http request on windows'
    end

    describe '#put_request' do
      let(:http_verb) { :put }
      let(:client_method) { :put_request }

      it_behaves_like 'a http request on windows'
    end
  end
end
