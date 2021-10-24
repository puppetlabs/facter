# frozen_string_literal: true

describe Facter do
  let(:fact_name) { 'os.name' }
  let(:fact_user_query) { 'os.name' }
  let(:fact_value) { 'ubuntu' }
  let(:type) { :core }
  let(:os_fact) do
    instance_spy(Facter::ResolvedFact, name: fact_name, value: fact_value,
                                       user_query: fact_user_query, type: type)
  end
  let(:missing_fact) do
    instance_spy(Facter::ResolvedFact, name: 'missing_fact', value: nil,
                                       user_query: 'missing_fact', type: :nil)
  end
  let(:empty_fact_collection) { Facter::FactCollection.new }
  let(:logger) { instance_spy(Facter::Log) }
  let(:fact_manager_spy) { instance_spy(Facter::FactManager) }
  let(:fact_collection_spy) { instance_spy(Facter::FactCollection) }
  let(:key_error) { KeyError.new('key error') }
  let(:config_reader_double) { class_spy(Facter::ConfigReader) }

  before do
    allow(Facter::ConfigReader).to receive(:init).and_return(config_reader_double)
    allow(config_reader_double).to receive(:cli).and_return(nil)
    allow(config_reader_double).to receive(:global).and_return(nil)
    allow(config_reader_double).to receive(:ttls).and_return([])
    allow(config_reader_double).to receive(:block_list).and_return([])
    allow(config_reader_double).to receive(:fact_groups).and_return({})

    allow(Facter::Options).to receive(:[]).and_call_original
    allow(Facter::Options).to receive(:[]).with(:blocked_facts).and_return([])
    allow(Facter::Options).to receive(:[]).with(:block_list).and_return([])

    allow(Facter::Log).to receive(:new).and_return(logger)
    Facter.clear
    allow(Facter::SessionCache).to receive(:invalidate_all_caches)
    allow(Facter::FactManager).to receive(:instance).and_return(fact_manager_spy)
    allow(Facter::FactCollection).to receive(:new).and_return(fact_collection_spy)
  end

  after do
    Facter.instance_variable_set(:@logger, nil)
  end

  def mock_fact_manager(method, return_value)
    allow(fact_manager_spy).to receive(method).and_return(return_value)
    allow(fact_collection_spy)
      .to receive(:build_fact_collection!)
      .with(return_value)
      .and_return(return_value.empty? ? empty_fact_collection : fact_collection_spy)
  end

  def mock_collection(method, os_name = nil, error = nil)
    if error
      allow(fact_collection_spy).to receive(method).with('os', 'name').and_raise(error)
    else
      allow(fact_collection_spy).to receive(method).with('os', 'name').and_return(os_name)
    end
  end

  describe '#resolve' do
    let(:cli_double) { instance_spy(Facter::Cli) }

    before do
      allow(Facter).to receive(:queried_facts)
    end

    context 'when user query and options in arguments' do
      it 'calls queried_facts' do
        Facter.resolve('os --show-legacy')

        expect(Facter).to have_received(:queried_facts).with(['os'])
      end
    end
  end

  describe '#to_hash' do
    before do
      allow(Hash).to receive(:[]).with(fact_collection_spy).and_return({})
      allow(Hash).to receive(:[]).with(empty_fact_collection).and_return({})
    end

    it 'returns one resolved fact' do
      mock_fact_manager(:resolve_facts, [os_fact])

      expect(Facter.to_hash).to eq({})
    end

    it 'return no resolved facts' do
      mock_fact_manager(:resolve_facts, [])

      expect(Facter.to_hash).to eq({})
    end

    context 'when custom fact with nil value' do
      let(:type) { :custom }
      let(:fact_value) { nil }
      let(:fact_user_query) { '' }

      it 'discards the custom fact with nil value' do
        mock_fact_manager(:resolve_facts, [os_fact])

        Facter.to_hash

        expect(fact_collection_spy).to have_received(:build_fact_collection!).with([])
      end
    end
  end

  describe '#to_user_output' do
    let(:json_fact_formatter) { instance_spy(Facter::JsonFactFormatter) }

    before do |example|
      resolved_fact = example.metadata[:multiple_facts] ? [os_fact, missing_fact] : [os_fact]
      expected_json_output = if example.metadata[:multiple_facts]
                               '{"os" : {"name": "ubuntu"}, "missing_fact": null}'
                             else
                               '{"os" : {"name": "ubuntu"}}'
                             end

      allow(fact_manager_spy).to receive(:resolve_facts).and_return(resolved_fact)
      allow(json_fact_formatter).to receive(:format).with(resolved_fact).and_return(expected_json_output)
      allow(Facter::FormatterFactory).to receive(:build).and_return(json_fact_formatter)
    end

    it 'returns one fact with value and status 0', multiple_facts: false do
      user_query = ['os.name']
      expected_json_output = '{"os" : {"name": "ubuntu"}}'

      formatted_facts = Facter.to_user_output({}, [user_query])

      expect(formatted_facts).to eq([expected_json_output, 0])
    end

    it 'returns one fact with value, one without and status 0', multiple_facts: true do
      user_query = ['os.name', 'missing_fact']
      expected_json_output = '{"os" : {"name": "ubuntu"}, "missing_fact": null}'

      formated_facts = Facter.to_user_output({}, [user_query])

      expect(formated_facts).to eq([expected_json_output, 0])
    end

    context 'when provided with --strict option' do
      it 'returns one fact with value, one without and status 1', multiple_facts: true do
        user_query = ['os.name', 'missing_fact']
        expected_json_output = '{"os" : {"name": "ubuntu"}, "missing_fact": null}'
        allow(Facter::Options).to receive(:[]).with(:strict).and_return(true)

        formatted_facts = Facter.to_user_output({}, *user_query)

        expect(formatted_facts).to eq([expected_json_output, 1])
      end

      it 'returns one fact and status 0', multiple_facts: false do
        user_query = 'os.name'
        expected_json_output = '{"os" : {"name": "ubuntu"}}'
        allow(Facter::Options).to receive(:[]).with(anything)
        allow(Facter::Options).to receive(:[]).with(:block_list).and_return([])
        allow(Facter::Options).to receive(:[]).with(:strict).and_return(true)

        formated_facts = Facter.to_user_output({}, user_query)

        expect(formated_facts).to eq([expected_json_output, 0])
      end
    end

    context 'when custom fact with nil value' do
      let(:type) { :custom }
      let(:fact_value) { nil }
      let(:fact_user_query) { '' }

      it 'discards the custom fact with nil value' do
        user_query = ['os.name']

        Facter.to_user_output({}, *user_query)

        expect(json_fact_formatter).to have_received(:format).with([])
      end
    end

    context 'when no facts are returned' do
      let(:type) { :custom }
      let(:fact_value) { nil }
      let(:fact_user_query) { '' }
      let(:expected_json_output) { {} }

      before do
        allow(fact_manager_spy).to receive(:resolve_facts).and_return([])
        allow(json_fact_formatter).to receive(:format).with([]).and_return(expected_json_output)
      end

      it 'does not raise exceptions' do
        expect { Facter.to_user_output({}, '') }.not_to raise_error
      end
    end
  end

  describe '#value' do
    it 'downcases the user query' do
      mock_fact_manager(:resolve_fact, [os_fact])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

      expect(Facter.value('OS.NAME')).to eq('Ubuntu')
    end

    it 'returns a value' do
      mock_fact_manager(:resolve_fact, [os_fact])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

      expect(Facter.value('os.name')).to eq('Ubuntu')
    end

    it 'return no value' do
      mock_fact_manager(:resolve_fact, [])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return(nil)

      expect(Facter.value('os.name')).to be nil
    end

    context 'when custom fact with nil value' do
      let(:type) { :custom }
      let(:fact_value) { nil }
      let(:fact_user_query) { '' }

      it 'returns the custom fact' do
        mock_fact_manager(:resolve_fact, [os_fact])
        allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

        expect(Facter.value('os.name')).to eq('Ubuntu')
      end
    end
  end

  describe '#fact' do
    it 'downcases the user query' do
      mock_fact_manager(:resolve_fact, [os_fact])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

      expect(Facter.fact('OS.NAME')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: 'Ubuntu')
    end

    it 'returns a fact' do
      mock_fact_manager(:resolve_fact, [os_fact])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

      expect(Facter.fact('os.name')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: 'Ubuntu')
    end

    it 'can be interpolated' do
      mock_fact_manager(:resolve_fact, [os_fact])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

      expect("#{Facter.fact('os.name')}-test").to eq('Ubuntu-test')
    end

    it 'returns no value' do
      mock_fact_manager(:resolve_fact, [])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_raise(key_error)

      expect(Facter.fact('os.name')).to be_nil
    end

    context 'when there is a resolved fact with type nil' do
      before do
        allow(fact_manager_spy).to receive(:resolve_fact).and_return([missing_fact])
        allow(fact_collection_spy).to receive(:build_fact_collection!).with([]).and_return(empty_fact_collection)
        allow(fact_collection_spy).to receive(:value).and_raise(KeyError)
      end

      it 'is rejected' do
        Facter.fact('missing_fact')

        expect(fact_collection_spy).to have_received(:build_fact_collection!).with([])
      end

      it 'returns nil' do
        expect(Facter.fact('missing_fact')).to be_nil
      end
    end

    context 'when custom fact with nill value' do
      let(:type) { :custom }
      let(:fact_value) { nil }
      let(:fact_user_query) { '' }

      it 'returns the custom fact' do
        mock_fact_manager(:resolve_fact, [os_fact])
        allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

        expect(Facter.fact('os.name'))
          .to be_instance_of(Facter::ResolvedFact)
          .and have_attributes(value: 'Ubuntu')
      end
    end
  end

  describe '#[]' do
    it 'returns a fact' do
      mock_fact_manager(:resolve_fact, [os_fact])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

      expect(Facter['os.name']).to be_instance_of(Facter::ResolvedFact).and(having_attributes(value: 'Ubuntu'))
    end

    it 'return no value' do
      mock_fact_manager(:resolve_fact, [])
      allow(fact_collection_spy).to receive(:value).with('os.name').and_raise(key_error)

      expect(Facter['os.name']).to be_nil
    end

    context 'when custom fact with nill value' do
      let(:type) { :custom }
      let(:fact_value) { nil }
      let(:fact_user_query) { '' }

      it 'returns the custom fact' do
        mock_fact_manager(:resolve_fact, [os_fact])
        allow(fact_collection_spy).to receive(:value).with('os.name').and_return('Ubuntu')

        expect(Facter['os.name'])
          .to be_instance_of(Facter::ResolvedFact)
          .and have_attributes(value: 'Ubuntu')
      end
    end
  end

  describe '#core_value' do
    it 'searched in core facts and returns a value' do
      mock_fact_manager(:resolve_core, [os_fact])
      mock_collection(:dig, 'Ubuntu')

      expect(Facter.core_value('os.name')).to eq('Ubuntu')
    end

    it 'searches os core fact and returns no value' do
      mock_fact_manager(:resolve_core, [])
      mock_collection(:dig, nil)

      expect(Facter.core_value('os.name')).to be nil
    end
  end

  describe 'LegacyFacter methods' do
    before do
      allow(LegacyFacter).to receive(:clear)
    end

    describe '#clear' do
      it 'sends call to LegacyFacter' do
        Facter.clear
        expect(LegacyFacter).to have_received(:clear).once
      end
    end

    describe '#flush' do
      it 'sends call to LegacyFacter' do
        allow(LegacyFacter).to receive(:flush)

        Facter.flush

        expect(LegacyFacter).to have_received(:flush).once
      end

      it 'invalidates core cache' do
        allow(Facter::SessionCache).to receive(:invalidate_all_caches)

        Facter.flush

        expect(Facter::SessionCache).to have_received(:invalidate_all_caches)
      end
    end

    describe '#load_external' do
      before do
        allow(Facter::Options).to receive(:[]=)
      end

      it 'sends call to Facter::Options' do
        allow(Facter::Options).to receive(:[]=)
        Facter.load_external(true)

        expect(Facter::Options).to have_received(:[]=).with(:no_external_facts, false)
      end

      it 'logs a debug message' do
        Facter.load_external(true)

        expect(logger).to have_received(:debug).with('Facter.load_external(true) called. External facts will be loaded')
      end
    end

    describe '#search' do
      it 'sends call to Facter::Options' do
        allow(Facter::Options).to receive(:[]=)
        dirs = ['/dir1', '/dir2']
        Facter.search(*dirs)

        expect(Facter::Options).to have_received(:[]=).with(:custom_dir, dirs)
      end
    end

    describe '#search_path' do
      it 'sends call to Facter::Options' do
        allow(Facter::Options).to receive(:custom_dir)
        Facter.search_path

        expect(Facter::Options).to have_received(:custom_dir).once
      end
    end

    describe '#search_external' do
      it 'sends call to Facter::Options' do
        allow(Facter::Options).to receive(:[]=)
        dirs = ['/dir1', '/dir2']
        Facter.search_external(dirs)

        expect(Facter::Options).to have_received(:[]=).with(:external_dir, dirs)
      end
    end

    describe '#search_external_path' do
      it 'sends call to Facter::Options' do
        allow(Facter::Options).to receive(:external_dir)

        Facter.search_external_path

        expect(Facter::Options).to have_received(:external_dir).once
      end
    end

    describe '#reset' do
      it 'sends call to LegacyFacter' do
        allow(LegacyFacter).to receive(:reset)

        Facter.reset

        expect(LegacyFacter).to have_received(:reset).once
      end

      it 'adds custom facts dirs' do
        allow(Facter::Options).to receive(:[]=)

        Facter.reset

        expect(Facter::Options).to have_received(:[]=).with(:custom_dir, [])
      end

      it 'add external facts dirs' do
        allow(Facter::Options).to receive(:[]=)

        Facter.reset

        expect(Facter::Options).to have_received(:[]=).with(:external_dir, [])
      end
    end
  end

  describe '#define_fact' do
    it 'sends call to LegacyFacter' do
      allow(LegacyFacter).to receive(:define_fact)

      Facter.define_fact('fact_name') {}

      expect(LegacyFacter).to have_received(:define_fact).once.with('fact_name', { fact_type: :custom })
    end
  end

  describe '#loadfacts' do
    it 'sends calls to LegacyFacter' do
      allow(LegacyFacter).to receive(:loadfacts)

      Facter.loadfacts

      expect(LegacyFacter).to have_received(:loadfacts).once
    end

    it 'returns nil' do
      allow(LegacyFacter).to receive(:loadfacts)

      expect(Facter.loadfacts).to be_nil
    end
  end

  describe '#trace?' do
    it 'returns trace variable' do
      expect(Facter).not_to be_trace
    end
  end

  describe '#trace' do
    after do
      Facter.trace(false)
    end

    it 'trace variable is true' do
      expect(Facter.trace(true)).to be_truthy
    end
  end

  describe '#debug' do
    let(:message) { 'test' }

    before do
      allow(Facter::Options).to receive(:[]).with(:debug).and_return(is_debug)
    end

    context 'when log level is debug' do
      let(:is_debug) { true }

      it 'logs a debug message' do
        allow(logger).to receive(:debug).with('test')

        expect(Facter.debug(message)).to be(nil)
      end
    end

    context 'when log level is not debug' do
      let(:is_debug) { false }

      it "doesn't log anything" do
        Facter.debug(message)

        expect(logger).not_to have_received(:debug).with(message)
      end
    end
  end

  describe '#debugging' do
    it 'sets log level to debug' do
      allow(Facter::Options).to receive(:[]=)
      Facter.debugging(true)

      expect(Facter::Options).to have_received(:[]=).with(:debug, true)
    end
  end

  describe '#debugging?' do
    it 'returns that log_level is not debug' do
      Facter.debugging?

      expect(Facter::Options).to have_received(:[]).with(:debug)
    end
  end

  describe '#log_exception' do
    shared_examples 'when exception param is an exception' do
      it 'logs exception message' do
        exception.set_backtrace(backtrace)

        Facter.log_exception(exception, message)

        expect(logger).to have_received(:error).with(expected_message)
      end
    end

    shared_examples 'when exception param is not an exception' do
      it 'logs exception message' do
        Facter.log_exception(exception, message)

        expect(logger).to have_received(:error).with(expected_message)
      end
    end

    context 'when trace option is false' do
      let(:backtrace) { 'prog.rb:2:in a' }

      context 'when we have an exception and a message' do
        let(:message) { 'Some error message' }
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { 'Some error message' }

        it_behaves_like 'when exception param is an exception'
      end

      context 'when we have an exception and an empty message' do
        let(:message) { '' }
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { 'FlushFakeError' }

        it_behaves_like 'when exception param is an exception'
      end

      context 'when we have an exception and a nil message' do
        let(:message) { nil }
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { 'FlushFakeError' }

        it_behaves_like 'when exception param is an exception'
      end

      context 'when we have an exception and no message' do
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { 'FlushFakeError' }

        it 'logs exception message' do
          exception.set_backtrace(backtrace)

          Facter.log_exception(exception)

          expect(logger).to have_received(:error).with(expected_message)
        end
      end

      context 'when exception and message are strings' do
        let(:message) { 'message' }
        let(:exception) { 'exception' }
        let(:expected_message) { 'message' }

        it_behaves_like 'when exception param is not an exception'
      end

      context 'when exception and message are nil' do
        let(:message) { nil }
        let(:exception) { nil }
        let(:expected_message) { '' }

        it_behaves_like 'when exception param is not an exception'
      end

      context 'when exception and message are hashes' do
        let(:message) { { 'a': 1 } }
        let(:exception) { { 'b': 2 } }
        let(:expected_message) { '{:a=>1}' }

        it_behaves_like 'when exception param is not an exception'
      end
    end

    context 'when trace options is true' do
      before do
        Facter.trace(true)
      end

      after do
        Facter.trace(false)
      end

      let(:backtrace) { 'prog.rb:2:in a' }

      context 'when we have an exception and a message' do
        let(:message) { 'Some error message' }
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { "Some error message\nbacktrace:\nprog.rb:2:in a" }

        it_behaves_like 'when exception param is an exception'
      end

      context 'when we have an exception and an empty message' do
        let(:message) { '' }
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { "FlushFakeError\nbacktrace:\nprog.rb:2:in a" }

        it_behaves_like 'when exception param is an exception'
      end

      context 'when we have an exception and a nil message' do
        let(:message) { nil }
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { "FlushFakeError\nbacktrace:\nprog.rb:2:in a" }

        it_behaves_like 'when exception param is an exception'
      end

      context 'when we have an exception and no message' do
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { "FlushFakeError\nbacktrace:\nprog.rb:2:in a" }

        it 'logs exception message' do
          exception.set_backtrace(backtrace)

          Facter.log_exception(exception)

          expect(logger).to have_received(:error).with(expected_message)
        end
      end

      context 'when we have an exception with no backtrace' do
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { 'FlushFakeError' }

        it 'logs exception message' do
          Facter.log_exception(exception)

          expect(logger).to have_received(:error).with(expected_message)
        end
      end

      context 'when exception and message are strings' do
        let(:message) { 'message' }
        let(:exception) { 'exception' }
        let(:expected_message) { 'message' }

        it_behaves_like 'when exception param is not an exception'
      end

      context 'when exception and message are nil' do
        let(:message) { nil }
        let(:exception) { nil }
        let(:expected_message) { '' }

        it_behaves_like 'when exception param is not an exception'
      end

      context 'when exception and message are hashes' do
        let(:message) { { 'a': 1 } }
        let(:exception) { { 'b': 2 } }
        let(:expected_message) { '{:a=>1}' }

        it_behaves_like 'when exception param is not an exception'
      end
    end
  end

  describe '#debugonce' do
    context 'when debugging is active' do
      before do
        allow(logger).to receive(:debug)
        allow(Facter::Log).to receive(:level=).with(:debug)
        Facter.debugging(true)
      end

      after do
        allow(Facter::Log).to receive(:level=).with(:warn)
        Facter.debugging(false)
      end

      it 'calls logger with the debug message' do
        message = 'Some error message'

        Facter.debugonce(message)

        expect(logger).to have_received(:debugonce).with(message)
      end

      it 'writes empty message when message is nil' do
        Facter.debugonce(nil)

        expect(logger).to have_received(:debugonce).with(nil)
      end

      it 'when message is a hash' do
        Facter.debugonce({ warn: 'message' })

        expect(logger).to have_received(:debugonce).with({ warn: 'message' })
      end

      it 'returns nil' do
        result = Facter.debugonce({ warn: 'message' })

        expect(result).to be_nil
      end
    end

    context 'when debugging is inactive' do
      before do
        allow(logger).to receive(:debug)
      end

      it 'does not call the logger' do
        Facter.debugonce('message')

        expect(logger).not_to have_received(:debug)
      end
    end
  end

  describe '#list' do
    before do
      allow(Facter).to receive(:to_hash).and_return({ 'up_time' => 235, 'timezone' => 'EEST', 'virtual' => 'physical' })
    end

    it 'returns the resolved fact names' do
      result = Facter.list

      expect(result).to eq(%w[timezone up_time virtual])
    end
  end

  describe '#warnonce' do
    before do
      allow(logger).to receive(:warn)
    end

    it 'calls logger with the warning message' do
      message = 'Some error message'

      Facter.warnonce(message)

      expect(logger).to have_received(:warnonce).with(message)
    end

    it 'writes empty message when message is nil' do
      Facter.warnonce(nil)

      expect(logger).to have_received(:warnonce).with(nil)
    end

    it 'when message is a hash' do
      Facter.warnonce({ warn: 'message' })

      expect(logger).to have_received(:warnonce).with({ warn: 'message' })
    end

    it 'returns nil' do
      result = Facter.warnonce({ warn: 'message' })

      expect(result).to be_nil
    end
  end

  describe '#warn' do
    before do
      allow(logger).to receive(:warn)
    end

    it 'calls logger' do
      message = 'Some error message'

      Facter.warn(message)

      expect(logger).to have_received(:warn).with(message)
    end

    it 'when message is nil' do
      Facter.warn(nil)

      expect(logger).to have_received(:warn).with('')
    end

    it 'when message is empty string' do
      Facter.warn('')
      expect(logger).to have_received(:warn).with('')
    end

    it 'when message is a hash' do
      Facter.warn({ warn: 'message' })

      expect(logger).to have_received(:warn).with('{:warn=>"message"}')
    end

    it 'when message is an array' do
      Facter.warn([1, 2, 3])

      expect(logger).to have_received(:warn).with('[1, 2, 3]')
    end

    it 'returns nil' do
      result = Facter.warn('message')

      expect(result).to be_nil
    end
  end

  describe '#each' do
    it 'returns one resolved fact' do
      mock_fact_manager(:resolve_facts, [os_fact])

      result = {}
      Facter.each { |name, value| result[name] = value }
      expect(result).to eq({ fact_name => fact_value })
    end
  end
end
