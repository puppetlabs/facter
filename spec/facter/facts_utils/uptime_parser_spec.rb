# frozen_string_literal: true

describe Facter::UptimeParser do
  describe '.uptime_seconds_unix' do
    let(:uptime_proc_file_cmd) { '/bin/cat /proc/uptime 2>/dev/null' }
    let(:kern_boottime_cmd) { 'sysctl -n kern.boottime 2>/dev/null' }
    let(:uptime_cmd) { 'uptime 2>/dev/null' }

    context 'when a /proc/uptime file exists' do
      let(:proc_uptime_value) { '2672.69 20109.75' }

      it 'returns the correct result' do
        allow(Open3)
          .to receive(:capture3)
          .with(uptime_proc_file_cmd)
          .and_return(proc_uptime_value)

        expect(Facter::UptimeParser.uptime_seconds_unix).to eq(2672)
      end
    end

    context 'when a sysctl kern.boottime command is available only' do
      let!(:time_now) { Time.parse('2019-10-10 11:00:00 +0100') }
      let(:kern_boottime_value) do
        '{ sec = 60, usec = 0 } Tue Oct  10 10:59:00 2019'
      end

      it 'returns the correct result' do
        allow(Time).to receive(:at).with(60) { Time.parse('2019-10-10 10:59:00 +0100') }
        allow(Time).to receive(:now) { time_now }

        allow(Open3)
          .to receive(:capture3)
          .with(uptime_proc_file_cmd)
          .and_return('')

        allow(Open3)
          .to receive(:capture3)
          .with(kern_boottime_cmd)
          .and_return(kern_boottime_value)

        expect(Facter::UptimeParser.uptime_seconds_unix).to eq(60)
      end
    end

    context 'when the uptime executable is available only' do
      before do
        allow(Open3)
          .to receive(:capture3)
          .with(uptime_proc_file_cmd)
          .and_return('')

        allow(Open3)
          .to receive(:capture3)
          .with(kern_boottime_cmd)
          .and_return('')
      end

      shared_examples 'uptime executable regex expectation' do |cmd_output, result|
        it 'returns the correct result' do
          allow(Open3)
            .to receive(:capture3)
            .with(uptime_cmd)
            .and_return(cmd_output)

          expect(Facter::UptimeParser.uptime_seconds_unix).to eq(result)
        end
      end

      context 'when the output matches days, hours and minutes regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 2 days, 1:00, 1 user, load average: 1.00, 0.75, 0.66',
          176_400
        )
      end

      context 'when the output matches days and hours regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 2 days, 1 hr(s), 1 user, load average: 1.00, 0.75, 0.66',
          176_400
        )
      end

      context 'when the output matches days and minutes regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 2 days, 60 min(s), 1 user, load average: 1.00, 0.75, 0.66',
          176_400
        )
      end

      context 'when the output matches days regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 2 days, 1 user, load average: 1.00, 0.75, 0.66',
          172_800
        )
      end

      context 'when the output matches hours and minutes regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 49:00, 1 user, load average: 1.00, 0.75, 0.66',
          176_400
        )
      end

      context 'when the output matches hours regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 49 hr(s), 1 user, load average: 1.00, 0.75, 0.66',
          176_400
        )
      end

      context 'when the output matches minutes regex' do
        include_examples(
          'uptime executable regex expectation',
          '10:00AM up 2940 mins, 1 user, load average: 1.00, 0.75, 0.66',
          176_400
        )
      end

      context 'when the output does not match any conditional regex' do
        include_examples(
          'uptime executable regex expectation',
          'running for 2 days',
          0
        )
      end
    end
  end
end
