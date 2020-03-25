# frozen_string_literal: true

describe Facter do
  let(:fact_name) { 'os.name' }
  let(:fact_value) { 'ubuntu' }
  let(:os_fact) do
    double(Facter::ResolvedFact, name: fact_name, value: fact_value, user_query: fact_name, filter_tokens: [])
  end
  let(:fact_collection) do
    fact_collection = Facter::FactCollection.new
    fact_collection['os'] = Facter::FactCollection['name' => 'Ubuntu']
    fact_collection
  end
  let(:empty_fact_collection) { Facter::FactCollection.new }
  let(:logger) { instance_spy(Facter::Log) }

  before do
    Facter.instance_variable_set(:@logger, logger)
    Facter.clear
    allow(Facter::SessionCache).to receive(:invalidate_all_caches)
  end

  describe '#to_hash' do
    it 'returns one resolved fact' do
      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      resolved_facts_hash = Facter.to_hash
      expect(resolved_facts_hash).to eq(fact_collection)
    end

    it 'return no resolved facts' do
      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      resolved_facts_hash = Facter.to_hash
      expect(resolved_facts_hash).to eq(empty_fact_collection)
    end
  end

  describe '#to_user_output' do
    it 'returns one fact and status 0' do
      user_query = 'os.name'
      expected_json_output = '{"os" : {"name": "ubuntu"}'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])

      json_fact_formatter = double(Facter::JsonFactFormatter)
      allow(json_fact_formatter).to receive(:format).with([os_fact]).and_return(expected_json_output)

      allow(Facter::FormatterFactory).to receive(:build).and_return(json_fact_formatter)

      formated_facts = Facter.to_user_output({}, [user_query])
      expect(formated_facts).to eq([expected_json_output, 0])
    end

    it 'returns no facts and status 0' do
      user_query = 'os.name'
      expected_json_output = '{}'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])

      json_fact_formatter = double(Facter::JsonFactFormatter)
      allow(json_fact_formatter).to receive(:format).with([]).and_return(expected_json_output)

      allow(Facter::FormatterFactory).to receive(:build).and_return(json_fact_formatter)

      formatted_facts = Facter.to_user_output({}, [user_query])
      expect(formatted_facts).to eq([expected_json_output, 0])
    end

    context '--strict' do
      before do
        allow(Facter::Options).to receive(:[]).with(:config)
      end

      it 'returns no fact and status 1' do
        allow(logger).to receive(:error).with('fact "os.name" does not exist.', true)

        user_query = 'os.name'
        expected_json_output = '{}'

        allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
        allow_any_instance_of(Facter::Options).to receive(:[]).with(:strict).and_return(true)
        allow(OsDetector).to receive(:detect).and_return(:solaris)

        json_fact_formatter = double(Facter::JsonFactFormatter)
        allow(json_fact_formatter).to receive(:format).and_return(expected_json_output)

        allow(Facter::FormatterFactory).to receive(:build).and_return(json_fact_formatter)

        formatted_facts = Facter.to_user_output({}, user_query)
        expect(formatted_facts).to eq([expected_json_output, 1])
      end

      it 'returns one fact and status 0' do
        user_query = 'os.name'
        expected_json_output = '{"os" : {"name": "ubuntu"}'

        allow_any_instance_of(Facter::Options).to receive(:[]).with(:strict).and_return(true)
        allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])

        json_fact_formatter = double(Facter::JsonFactFormatter)
        allow(json_fact_formatter).to receive(:format).with([os_fact]).and_return(expected_json_output)

        allow(Facter::FormatterFactory).to receive(:build).and_return(json_fact_formatter)

        formated_facts = Facter.to_user_output({}, user_query)
        expect(formated_facts).to eq([expected_json_output, 0])
      end
    end
  end

  describe '#value' do
    it 'returns a value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      resolved_facts_hash = Facter.value(user_query)
      expect(resolved_facts_hash).to eq('Ubuntu')
    end

    it 'return no value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      resolved_facts_hash = Facter.value(user_query)
      expect(resolved_facts_hash).to be nil
    end
  end

  describe '#fact' do
    it 'returns a fact' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      result = Facter.fact(user_query)
      expect(result).to be_instance_of(Facter::ResolvedFact)
      expect(result.value).to eq('Ubuntu')
    end

    it 'return no value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      result = Facter.fact(user_query)
      expect(result).to be_nil
    end
  end

  describe '#[]' do
    it 'returns a fact' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      result = Facter[user_query]
      expect(result).to be_instance_of(Facter::ResolvedFact)
      expect(result.value).to eq('Ubuntu')
    end

    it 'return no value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_facts).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      result = Facter[user_query]
      expect(result).to be_nil
    end
  end

  describe '#core_value' do
    it 'searched in core facts and returns a value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_core).and_return([os_fact])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([os_fact])
        .and_return(fact_collection)

      resolved_facts_hash = Facter.core_value(user_query)
      expect(resolved_facts_hash).to eq('Ubuntu')
    end

    it 'searches ion core facts and return no value' do
      user_query = 'os.name'

      allow_any_instance_of(Facter::FactManager).to receive(:resolve_core).and_return([])
      allow_any_instance_of(Facter::FactCollection)
        .to receive(:build_fact_collection!)
        .with([])
        .and_return(empty_fact_collection)

      resolved_facts_hash = Facter.core_value(user_query)
      expect(resolved_facts_hash).to be nil
    end
  end

  describe '#clear' do
    it 'sends call to LegacyFacter' do
      expect(LegacyFacter).to receive(:clear).once
      Facter.clear
    end
  end

  describe '#search' do
    it 'sends call to LegacyFacter' do
      dirs = ['/dir1', '/dir2']

      expect(LegacyFacter).to receive(:search).with(dirs)
      Facter.search(dirs)
    end
  end

  describe '#search_path' do
    it 'sends call to LegacyFacter' do
      expect(LegacyFacter).to receive(:search_path).once
      Facter.search_path
    end
  end

  describe '#search_external' do
    it 'sends call to LegacyFacter' do
      dirs = ['/dir1', '/dir2']

      expect(LegacyFacter).to receive(:search_external).with(dirs)
      Facter.search_external(dirs)
    end
  end

  describe '#search_external_path' do
    it 'sends call to LegacyFacter' do
      expect(LegacyFacter).to receive(:search_external_path).once
      Facter.search_external_path
    end
  end

  describe '#reset' do
    it 'sends call to LegacyFacter' do
      allow(LegacyFacter).to receive(:reset)
      Facter.reset
      expect(LegacyFacter).to have_received(:reset).once
    end

    it 'adds custom facts dirs' do
      allow(LegacyFacter).to receive(:search)
      Facter.reset
      expect(LegacyFacter).to have_received(:search).once
    end

    it 'add external facts dirs' do
      allow(LegacyFacter).to receive(:search_external)
      Facter.reset
      expect(LegacyFacter).to have_received(:search_external).once
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
      allow(Facter::Options.instance).to receive(:[]).with(:debug).and_return(is_debug)
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
        expect_any_instance_of(Facter::Log).not_to receive(:debug).with(message)
        expect(Facter.debug(message)).to be(nil)
      end
    end
  end

  describe '#debugging' do
    let(:priority_options) { {} }

    before do
      allow(Facter::Options.instance).to receive(:priority_options).and_return(priority_options)
    end

    it 'sets log level to debug' do
      expect(priority_options).to receive(:[]=).with(:debug, true)
      Facter.debugging(true)
    end
  end

  describe '#debugging?' do
    it 'returns that log_level is not debug' do
      expect(Facter::Options.instance).to receive(:[]).with(:debug).and_return(false)
      Facter.debugging?
    end
  end

  describe '#log_exception' do
    context 'when trace options is true' do
      before do
        Facter.trace(true)
      end

      after do
        Facter.trace(false)
      end

      let(:message) { 'Some error message' }
      let(:exception) { FlushFakeError.new }
      let(:expected_message) { "Some error message\nbacktrace:\nprog.rb:2:in `a'" }

      it 'format exception to display backtrace' do
        exception.set_backtrace("prog.rb:2:in `a'")
        Facter.log_exception(exception, message)
        expect(logger).to have_received(:error).with(expected_message)
      end
    end
  end
end
