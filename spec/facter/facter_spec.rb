# frozen_string_literal: true

describe Facter do
  let(:os_fact) do
    Facter::ResolvedFact.new('os.name', 'ubuntu', :core, 'os.name')
  end
  let(:missing_fact) do
    # NOTE: the type is the :nil symbol
    Facter::ResolvedFact.new('missing_fact', nil, :nil, 'missing_fact')
  end
  let(:hash_fact) do
    Facter::ResolvedFact.new('mountpoints', { '/boot' => { 'filesystem' => 'ext4', 'device' => 'dev1' },
                                              '/' => { 'filesystem' => 'ext4', 'device' => 'dev2' } },
                             :core, 'mountpoints')
  end

  let(:config_reader_double) { class_spy(Facter::ConfigReader) }
  let(:logger) { Facter.send(:logger) }

  sorted_fact_hash = { 'mountpoints' => { '/' => { 'device' => 'dev2', 'filesystem' => 'ext4' },
                                          '/boot' => { 'device' => 'dev1', 'filesystem' => 'ext4' } } }

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

    Facter.clear
    allow(Facter::SessionCache).to receive(:invalidate_all_caches)
  end

  def stub_facts(resolved_facts)
    allow(Facter::FactManager.instance).to receive(:resolve_facts).and_return(resolved_facts)
  end

  def stub_no_facts
    stub_facts([])
  end

  def stub_one_fact(resolved_facts)
    allow(Facter::FactManager.instance).to receive(:resolve_fact).and_return([resolved_facts])
  end

  def stub_no_fact
    allow(Facter::FactManager.instance).to receive(:resolve_fact).and_return([])
  end

  describe '#resolve' do
    it 'returns hash object when API called' do
      stub_no_facts

      expect(Facter.resolve('')).to be_an_instance_of(Hash)
    end

    context 'when user query in arguments' do
      it 'returns a stable order hash' do
        stub_facts([hash_fact])
        expect(Facter.resolve('mountpoints')).to eq(sorted_fact_hash)
      end
    end

    context 'when user query and options in arguments' do
      it 'returns one resolved fact' do
        stub_facts([os_fact])

        expect(Facter.resolve('os.name --show-legacy')).to eq('os.name' => 'ubuntu')
      end
    end

    context 'when there is no user query' do
      let(:hash_fact_no_user_query) do
        Facter::ResolvedFact.new('mountpoints', { '/boot' => { 'filesystem' => 'ext4', 'device' => 'dev1' },
                                                  '/' => { 'filesystem' => 'ext4', 'device' => 'dev2' } }, :core, '')
      end

      it 'returns a stable order hash' do
        stub_facts([hash_fact_no_user_query])
        expect(Facter.resolve('')).to eq(sorted_fact_hash)
      end
    end
  end

  describe '#to_hash' do
    it 'returns one resolved fact' do
      stub_facts([os_fact])

      expect(Facter.to_hash).to eq('os' => { 'name' => 'ubuntu' })
    end

    it 'return no resolved facts' do
      stub_no_facts

      expect(Facter.to_hash).to eq({})
    end

    context 'when custom fact with nil value' do
      it 'discards the custom fact with nil value' do
        stub_facts([Facter::ResolvedFact.new('custom', nil, :custom, '')])

        expect(Facter.to_hash).to eq({})
      end
    end

    it 'returns a stable order hash' do
      stub_facts([hash_fact])
      expect(Facter.to_hash).to eq(sorted_fact_hash)
    end
  end

  describe '#to_user_output' do
    it 'returns one fact with value and status 0' do
      user_query = ['os.name']
      stub_facts([os_fact])

      formatted_facts = Facter.to_user_output({}, [user_query])
      expect(formatted_facts).to eq(['ubuntu', 0])
    end

    it 'returns one fact with value, one without and status 0' do
      user_query = ['os.name', 'missing_fact']
      stub_facts([os_fact, missing_fact])

      formated_facts = Facter.to_user_output({ json: true }, *user_query)
      expect(JSON.parse(formated_facts[0])).to eq('missing_fact' => nil, 'os.name' => 'ubuntu')
      expect(formated_facts[1]).to eq(0)
    end

    context 'when provided with --strict option' do
      it 'returns one fact with value, one without and status 1' do
        user_query = ['os.name', 'missing_fact']
        stub_facts([os_fact, missing_fact])

        allow(Facter::Options).to receive(:[]).with(:strict).and_return(true)

        formatted_facts = Facter.to_user_output({ json: true }, *user_query)
        expect(JSON.parse(formatted_facts[0])).to eq('missing_fact' => nil, 'os.name' => 'ubuntu')
        expect(formatted_facts[1]).to eq(1)
      end

      it 'returns one fact and status 0' do
        user_query = 'os.name'
        stub_facts([os_fact])
        allow(Facter::Options).to receive(:[]).with(anything)
        allow(Facter::Options).to receive(:[]).with(:block_list).and_return([])
        allow(Facter::Options).to receive(:[]).with(:strict).and_return(true)

        formated_facts = Facter.to_user_output({ json: true }, user_query)
        expect(JSON.parse(formated_facts[0])).to eq('os.name' => 'ubuntu')
        expect(formated_facts[1]).to eq(0)
      end
    end

    context 'when custom fact with nil value' do
      it 'discards the custom fact with nil value if user query is empty' do
        user_query = ''
        os_fact = Facter::ResolvedFact.new('os.name', 'ubuntu', :core, user_query)
        custom_fact = Facter::ResolvedFact.new('custom', nil, :custom, user_query)
        stub_facts([os_fact, custom_fact])

        formated_facts = Facter.to_user_output({ json: true }, user_query)
        expect(JSON.parse(formated_facts[0])).to eq('os' => { 'name' => 'ubuntu' })
        expect(formated_facts[1]).to eq(0)
      end

      it 'includes the custom fact with nil value if user query is not empty' do
        user_query = %w[os custom]
        os_fact = Facter::ResolvedFact.new('os.name', 'ubuntu', :core, 'os')
        custom_fact = Facter::ResolvedFact.new('custom', nil, :custom, 'custom')
        stub_facts([os_fact, custom_fact])

        formated_facts = Facter.to_user_output({ json: true }, *user_query)
        expect(JSON.parse(formated_facts[0])).to eq('custom' => nil, 'os' => { 'name' => 'ubuntu' })
        expect(formated_facts[1]).to eq(0)
      end
    end

    context 'when no facts are returned' do
      it 'does not raise exceptions' do
        stub_facts([])

        expect { Facter.to_user_output({ json: true }, '') }.not_to raise_error
      end
    end
  end

  describe '#value' do
    it 'downcases the user query' do
      stub_one_fact(os_fact)

      expect(Facter.value('OS.NAME')).to eq('ubuntu')
    end

    it 'returns a value' do
      stub_one_fact(os_fact)

      expect(Facter.value('os.name')).to eq('ubuntu')
    end

    it 'resolves facts once' do
      expect(Facter::FactManager.instance).to receive(:resolve_fact).with('os.name').once.and_return([os_fact])

      Facter.value('os.name')
      Facter.value('os.name')
    end

    it 'returns nil' do
      stub_no_fact

      expect(Facter.value('os.name')).to be nil
    end

    context 'when fact value is false' do
      it 'resolves facts once' do
        boolean_fact = Facter::ResolvedFact.new('boolean', false, :core, '')
        expect(Facter::FactManager.instance).to receive(:resolve_fact).with('boolean').once.and_return([boolean_fact])

        Facter.value('boolean')
        Facter.value('boolean')
      end
    end

    context 'when custom fact with nil value' do
      it 'returns the custom fact' do
        stub_one_fact(Facter::ResolvedFact.new('nil_fact', nil, :custom, ''))

        expect(Facter.value('nil_fact')).to eq(nil)
      end
    end
  end

  describe '#fact' do
    it 'downcases the user query' do
      stub_one_fact(os_fact)

      expect(Facter.fact('OS.NAME')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: 'ubuntu')
    end

    it 'returns a fact' do
      stub_one_fact(os_fact)

      expect(Facter.fact('os.name')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: 'ubuntu')
    end

    it 'can be interpolated' do
      stub_one_fact(os_fact)

      expect("#{Facter.fact('os.name')}-test").to eq('ubuntu-test')
    end

    it 'returns nil' do
      stub_no_fact

      expect(Facter.fact('os.name')).to be_nil
    end

    context 'when there is a resolved fact with type :nil' do
      it 'returns nil' do
        stub_one_fact(missing_fact)

        expect(Facter.fact('missing_fact')).to be_nil
      end
    end

    context 'when custom fact with nil value' do
      it 'returns the custom fact' do
        custom_fact = Facter::ResolvedFact.new('custom', 'yes', :custom, '')
        stub_one_fact(custom_fact)

        expect(Facter.fact('custom'))
          .to be_instance_of(Facter::ResolvedFact)
          .and have_attributes(value: 'yes')
      end
    end
  end

  describe '#[]' do
    it 'returns a fact' do
      stub_one_fact(os_fact)

      expect(Facter['os.name']).to be_instance_of(Facter::ResolvedFact).and(having_attributes(value: 'ubuntu'))
    end

    it 'return nil' do
      stub_no_fact

      expect(Facter['os.name']).to be_nil
    end

    context 'when custom fact with nil value' do
      it 'returns the custom fact' do
        stub_one_fact(Facter::ResolvedFact.new('custom', 'yes', :custom, ''))

        expect(Facter['custom'])
          .to be_instance_of(Facter::ResolvedFact)
          .and have_attributes(value: 'yes')
      end
    end
  end

  describe '#core_value' do
    it 'searched in core facts and returns a value' do
      allow(Facter::FactManager.instance).to receive(:resolve_core).with(['os.name']).and_return([os_fact])

      expect(Facter.core_value('os.name')).to eq('ubuntu')
    end

    it 'searches os core fact and returns nil' do
      allow(Facter::FactManager.instance).to receive(:resolve_core).with(['os.name']).and_return([])

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
        expect(logger).to receive(:debug).with('Facter.load_external(true) called. External facts will be loaded')

        Facter.load_external(true)
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
        expect(logger).not_to receive(:debug).with(message)

        Facter.debug(message)
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

        expect(logger).to receive(:error).with(expected_message)

        Facter.log_exception(exception, message)
      end
    end

    shared_examples 'when exception param is not an exception' do
      it 'logs exception message' do
        expect(logger).to receive(:error).with(expected_message)

        Facter.log_exception(exception, message)
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

          expect(logger).to receive(:error).with(expected_message)

          Facter.log_exception(exception)
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

          expect(logger).to receive(:error).with(expected_message)

          Facter.log_exception(exception)
        end
      end

      context 'when we have an exception with no backtrace' do
        let(:exception) { FlushFakeError.new }
        let(:expected_message) { 'FlushFakeError' }

        it 'logs exception message' do
          expect(logger).to receive(:error).with(expected_message)

          Facter.log_exception(exception)
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

        expect(logger).to receive(:debugonce).with(message)

        Facter.debugonce(message)
      end

      it 'writes empty message when message is nil' do
        expect(logger).to receive(:debugonce).with(nil)

        Facter.debugonce(nil)
      end

      it 'when message is a hash' do
        expect(logger).to receive(:debugonce).with({ warn: 'message' })

        Facter.debugonce({ warn: 'message' })
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
        expect(logger).not_to receive(:debug)

        Facter.debugonce('message')
      end
    end
  end

  describe '#list' do
    before do
      allow(Facter).to receive(:to_hash).and_return({ 'up_time' => 235, 'timezone' => 'EEST', 'virtual' => 'physical' })
    end

    it 'sorts the resolved fact names' do
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

      expect(logger).to receive(:warnonce).with(message)

      Facter.warnonce(message)
    end

    it 'writes empty message when message is nil' do
      expect(logger).to receive(:warnonce).with(nil)

      Facter.warnonce(nil)
    end

    it 'when message is a hash' do
      expect(logger).to receive(:warnonce).with({ warn: 'message' })

      Facter.warnonce({ warn: 'message' })
    end

    it 'returns nil' do
      result = Facter.warnonce({ warn: 'message' })

      expect(result).to be_nil
    end
  end

  describe '#warn' do
    it 'calls logger' do
      message = 'Some error message'

      expect(logger).to receive(:warn).with(message)

      Facter.warn(message)
    end

    it 'when message is nil' do
      expect(logger).to receive(:warn).with('')

      Facter.warn(nil)
    end

    it 'when message is empty string' do
      expect(logger).to receive(:warn).with('')

      Facter.warn('')
    end

    it 'when message is a hash' do
      expect(logger).to receive(:warn).with('{:warn=>"message"}')

      Facter.warn({ warn: 'message' })
    end

    it 'when message is an array' do
      expect(logger).to receive(:warn).with('[1, 2, 3]')

      Facter.warn([1, 2, 3])
    end

    it 'returns nil' do
      result = Facter.warn('message')

      expect(result).to be_nil
    end
  end

  describe '#each' do
    it 'enumerates no facts' do
      stub_facts([])

      expect(Facter.enum_for(:each).to_h).to eq({})
    end

    it 'enumerates one fact' do
      stub_facts([os_fact])

      expect(Facter.enum_for(:each).to_h).to eq('os.name' => 'ubuntu')
    end
  end
end
