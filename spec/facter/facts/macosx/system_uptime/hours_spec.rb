# frozen_string_literal: true

describe Facts::Macosx::SystemUptime::Hours do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemUptime::Hours.new }

    let(:hours) { '2' }

    before do
      allow(Facter::Resolvers::Uptime).to \
        receive(:resolve).with(:hours).and_return(hours)
    end

    it 'calls Facter::Resolvers::Uptime' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Uptime).to have_received(:resolve).with(:hours)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.hours', value: hours),
                        an_object_having_attributes(name: 'uptime_hours', value: hours, type: :legacy))
    end
  end
end
