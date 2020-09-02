# frozen_string_literal: true

describe Facter::Framework::Benchmarking::Timer do
  let(:tms_mock) { instance_spy(Benchmark::Tms) }

  describe '#measure' do
    context 'when timing option is true' do
      before do
        allow(Facter::Options).to receive(:[]).with(:timing).and_return(true)
        allow(tms_mock).to receive(:format).with('%r').and_return('(0.123)')
        allow(Benchmark).to receive(:measure).and_return(tms_mock)
      end

      it 'prints fact name and time it took to resolve it' do
        expect do
          Facter::Framework::Benchmarking::Timer.measure('my_fact') {}
        end.to output("fact `my_fact`, took: (0.123) seconds\n").to_stdout
      end
    end

    context 'when timing option is false' do
      before do
        allow(Facter::Options).to receive(:[]).with(:timing).and_return(false)
      end

      it 'does not print any message' do
        expect do
          Facter::Framework::Benchmarking::Timer.measure('my_fact') {}
        end.not_to output.to_stdout
      end
    end
  end
end
