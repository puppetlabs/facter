# frozen_string_literal: true

describe Facts::Linux::SystemUptime::Seconds do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::SystemUptime::Seconds.new }

    let(:value) { 3600 }

    context 'when on linux' do
      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve) .with(:hypervisor).and_return(nil)
        allow(Facter::Resolvers::Uptime).to receive(:resolve).with(:seconds).and_return(value)
      end

      it 'calls Facter::Resolvers::Uptime' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:seconds)
      end

      it 'returns minutes since last boot' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'system_uptime.seconds', value: value),
                          an_object_having_attributes(name: 'uptime_seconds', value: value, type: :legacy))
      end
    end

    context 'when in docker container' do
      before do
        allow(Facter::Resolvers::Containers).to receive(:resolve) .with(:hypervisor).and_return({ docker: '123' })
        allow(Facter::Resolvers::Linux::DockerUptime).to receive(:resolve).with(:seconds).and_return(value)
      end

      it 'calls Facter::Resolvers::Uptime' do
        fact.call_the_resolver
        expect(Facter::Resolvers::Linux::DockerUptime).to have_received(:resolve).with(:seconds)
      end

      it 'returns minutes since last boot' do
        expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
          contain_exactly(an_object_having_attributes(name: 'system_uptime.seconds', value: value),
                          an_object_having_attributes(name: 'uptime_seconds', value: value, type: :legacy))
      end
    end
  end
end
