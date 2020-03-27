# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe Facter::Core::Execution do
  subject(:execution) { Facter::Core::Execution }

  let(:impl) { Facter::Core::Execution.impl }

  it 'delegates #search_paths to the implementation' do
    expect(impl).to receive(:search_paths)
    execution.search_paths
  end

  it 'delegates #which to the implementation' do
    expect(impl).to receive(:which).with('waffles')
    execution.which('waffles')
  end

  it 'delegates #absolute_path? to the implementation' do
    expect(impl).to receive(:absolute_path?).with('waffles', nil)
    execution.absolute_path?('waffles')
  end

  it 'delegates #absolute_path? with an optional platform to the implementation' do
    expect(impl).to receive(:absolute_path?).with('waffles', :windows)
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
end
