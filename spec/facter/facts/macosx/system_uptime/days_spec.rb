# frozen_string_literal: true

describe Facts::Macosx::SystemUptime::Days do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::SystemUptime::Days.new }

    let(:days) { '11' }

    before do
      allow(Facter::Resolvers::Uptime).to \
        receive(:resolve).with(:days).and_return(days)
    end

    it 'returns a resolved fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'system_uptime.days', value: days),
                        an_object_having_attributes(name: 'uptime_days', value: days, type: :legacy))
    end
  end
end
