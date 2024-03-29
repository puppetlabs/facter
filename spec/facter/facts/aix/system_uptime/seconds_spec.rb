# frozen_string_literal: true

describe Facts::Aix::SystemUptime::Seconds do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::SystemUptime::Seconds.new }

    let(:seconds) { '123094' }

    before do
      allow(Facter::Resolvers::Uptime).to \
        receive(:resolve).with(:seconds).and_return(seconds)
    end

    it 'returns system uptime seconds fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(have_attributes(name: 'system_uptime.seconds', value: seconds),
                        have_attributes(name: 'uptime_seconds', value: seconds, type: :legacy))
    end
  end
end
