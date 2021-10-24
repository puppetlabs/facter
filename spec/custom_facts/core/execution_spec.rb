# frozen_string_literal: true

describe Facter::Core::Execution do
  subject(:execution) { Facter::Core::Execution }

  let(:windows_impl) { instance_spy(Facter::Core::Execution::Windows) }
  let(:impl) { Facter::Core::Execution.impl }
  let(:logger) { impl.instance_variable_get(:@log) }

  before do
    allow(Facter::Core::Execution::Windows).to receive(:new).and_return(windows_impl)
  end

  it 'delegates #search_paths to the implementation' do
    expect(impl).to receive(:search_paths)
    execution.search_paths
  end

  it 'delegates #which to the implementation' do
    expect(impl).to receive(:which).with('waffles')
    execution.which('waffles')
  end

  it 'delegates #absolute_path? to the implementation' do
    expect(impl).to receive(:absolute_path?).with('waffles')
    execution.absolute_path?('waffles')
  end

  it 'delegates #absolute_path? with an optional platform to the implementation' do
    expect(windows_impl).to receive(:absolute_path?).with('waffles')
    execution.absolute_path?('waffles', :windows)
  end

  it 'delegates #expand_command to the implementation' do
    expect(impl).to receive(:expand_command).with('waffles')
    execution.expand_command('waffles')
  end

  it 'delegates #exec to #execute' do
    expect(impl).to receive(:execute).with('waffles', on_fail: nil)
    execution.exec('waffles')
  end

  it 'delegates #execute to the implementation' do
    expect(impl).to receive(:execute).with('waffles', {})
    execution.execute('waffles')
  end

  context 'when running an actual command' do
    before do
      allow(impl).to receive(:which).with('waffles').and_return('/under/the/honey/are/the/waffles')
      allow(impl).to receive(:execute_command)
      allow(logger).to receive(:warn)
    end

    context 'with default parameters' do
      it 'execute the found command' do
        execution.execute('waffles')
        expect(impl).to have_received(:execute_command).with('/under/the/honey/are/the/waffles', :raise, nil, nil)
      end
    end

    context 'with a timeout' do
      it 'execute the found command with a timeout' do
        execution.execute('waffles', timeout: 90)
        expect(impl).to have_received(:execute_command).with('/under/the/honey/are/the/waffles', :raise, nil, 90)
      end
    end

    context 'with a deprecated time_limit' do
      it 'execute the found command with a timeout' do
        execution.execute('waffles', time_limit: 90)
        expect(impl).to have_received(:execute_command).with('/under/the/honey/are/the/waffles', :raise, nil, 90)
      end

      it 'emits a warning' do
        execution.execute('waffles', time_limit: 90)
        expect(logger).to have_received(:warn)
          .with('Unexpected key passed to Facter::Core::Execution.execute option: time_limit')
      end
    end

    context 'with a deprecated limit' do
      it 'execute the found command with a timeout' do
        execution.execute('waffles', limit: 90)
        expect(impl).to have_received(:execute_command).with('/under/the/honey/are/the/waffles', :raise, nil, 90)
      end

      it 'emits a warning' do
        execution.execute('waffles', limit: 90)
        expect(logger).to have_received(:warn)
          .with('Unexpected key passed to Facter::Core::Execution.execute option: limit')
      end
    end
  end
end
