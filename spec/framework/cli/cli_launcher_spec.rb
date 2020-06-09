# frozen_string_literal: true

require "#{ROOT_DIR}/lib/framework/cli/cli_launcher"

describe CliLauncher do
  subject(:cli_launcher) { CliLauncher.new(args) }

  let(:args) { [] }

  describe '#validate_options' do
    it 'calls Facter::OptionsValidator.validate' do
      allow(Facter::OptionsValidator).to receive(:validate)
      cli_launcher.validate_options

      expect(Facter::OptionsValidator).to have_received(:validate).with(args)
    end
  end

  describe '#prepare_arguments' do
    let(:task_list) do
      { 'help' => Thor::Command.new('help', 'description', 'long_description', 'usage'),
        'query' => Thor::Command.new('query', 'description', 'long_description', 'usage'),
        'version' => Thor::Command.new('version', 'description', 'long_description', 'usage'),
        'list_block_groups' => Thor::Command.new('list_block_groups', 'description', 'long_description', 'usage'),
        'list_cache_groups' => Thor::Command.new('list_cache_groups', 'description', 'long_description', 'usage') }
    end

    let(:map) do
      { '-h' => :help, '--version' => :version, '--list-block-groups' => :list_block_groups,
        '--list-cache-groups' => :list_cache_groups }
    end

    before do
      allow(Facter::Cli).to receive(:all_tasks).and_return(task_list)
      allow(Facter::Cli).to receive(:instance_variable_get).with(:@map).and_return(map)
    end

    context 'when arguments should be reordered' do
      let(:args) { %w[--debug --list-cache-groups --list-block-groups] }
      let(:expected_arguments) { %w[--list-cache-groups --list-block-groups --debug] }

      it 'reorders arguments' do
        prepare_arguments = cli_launcher.prepare_arguments

        expect(prepare_arguments).to eq(expected_arguments)
      end
    end

    context 'when arguments should not be reordered' do
      let(:args) { %w[--list-cache-groups --list-block-groups --debug] }

      it 'does not reorder arguments' do
        prepare_arguments = cli_launcher.prepare_arguments

        expect(prepare_arguments).to eq(args)
      end
    end

    context 'when default task should be added' do
      let(:args) { %w[fact1 fact2] }
      let(:expected_args) { %w[query fact1 fact2] }

      it 'adds default (query) task' do
        prepare_arguments = cli_launcher.prepare_arguments
        expect(prepare_arguments).to eq(expected_args)
      end
    end
  end

  describe '#start' do
    context 'when no errors' do
      before do
        allow(Facter::Cli).to receive(:start)
      end

      it 'calls Facter::Cli.start' do
        cli_launcher.start

        expect(Facter::Cli).to have_received(:start).with(args, debug: true)
      end
    end

    context 'when errors' do
      before do
        allow(Facter::OptionsValidator).to receive(:write_error_and_exit)
        allow(Facter::Cli).to receive(:start).with(any_args).and_raise(Thor::UnknownArgumentError.new({}, {}))
      end

      it 'calls Facter::OptionsValidator.write_error_and_exit' do
        cli_launcher.start

        expect(Facter::OptionsValidator).to have_received(:write_error_and_exit)
      end
    end
  end
end
