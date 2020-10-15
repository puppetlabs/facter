# frozen_string_literal: true

describe Facter::OsHierarchy do
  subject(:os_hierarchy) { Facter::OsHierarchy.new }

  before do
    stub_const('Facter::Config::OS_HIERARCHY', JSON.parse(load_fixture('os_hierarchy').read))
    allow(Facter::Log).to receive(:new).and_return(log)
  end

  let(:log) { instance_spy(Facter::Log) }

  describe '#construct_hierarchy' do
    context 'when searched_os is ubuntu' do
      it 'constructs hierarchy' do
        hierarchy = os_hierarchy.construct_hierarchy(:ubuntu)

        expect(hierarchy).to eq(%w[Linux Debian Ubuntu])
      end
    end

    context 'when searched_os is debian' do
      it 'constructs hierarchy' do
        hierarchy = os_hierarchy.construct_hierarchy(:debian)

        expect(hierarchy).to eq(%w[Linux Debian])
      end
    end

    context 'when searched_os is linux' do
      it 'constructs hierarchy' do
        hierarchy = os_hierarchy.construct_hierarchy(:linux)

        expect(hierarchy).to eq(%w[Linux])
      end
    end

    context 'when there is no os hierarchy' do
      let(:my_os_name) { 'Myos' }

      before do
        stub_const('Facter::Config::OS_HIERARCHY', nil)
      end

      it 'returns the searched os as the hierarchy' do
        hierarchy = os_hierarchy.construct_hierarchy(:myos)

        expect(hierarchy).to eq([my_os_name])
      end

      it 'logs debug message' do
        os_hierarchy.construct_hierarchy(:myos)

        expect(log).to have_received(:debug).with("There is no os_hierarchy, will fall back to: #{my_os_name}")
      end
    end

    context 'when searched_os is nil' do
      it 'constructs hierarchy' do
        hierarchy = os_hierarchy.construct_hierarchy(nil)

        expect(hierarchy).to eq([])
      end
    end

    context 'when searched_os is not in hierarchy' do
      it 'constructs hierarchy' do
        hierarchy = os_hierarchy.construct_hierarchy(:my_os)

        expect(hierarchy).to eq([])
      end
    end
  end
end
