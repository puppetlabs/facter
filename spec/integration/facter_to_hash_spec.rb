# frozen_string_literal: true

require_relative 'helper'

describe Facter, :integration do
  context 'when calling facter cli' do
    context 'with no user query' do
      it 'returns no stderr' do
        _, err, = IntegrationHelper.facter_exec

        expect(err).to be_empty
      end

      it 'returns 0 exit code' do
        _, _, status = IntegrationHelper.facter_exec

        expect(status.exitstatus).to eq(0)
      end

      it 'returns valid output' do
        out, = IntegrationHelper.facter_exec

        root_facts = ['memory => {', 'mountpoints =>', 'networking => {',
                      'os => {', 'path =>', 'processors => {']

        expect(out).to include(*root_facts)
      end

      it 'returns valid json output' do
        out, = IntegrationHelper.facter_exec('-j')

        expect do
          JSON.parse(out)
        end.not_to raise_exception
      end
    end

    context 'with user query' do
      it 'returns fqdn' do
        out, = IntegrationHelper.facter_exec('fqdn')

        expect(out).not_to be_empty
      end

      it 'returns ip' do
        out, = IntegrationHelper.facter_exec('ipaddress')

        expect(out).to match(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)
      end

      it 'returns ipaddress6' do
        out, = IntegrationHelper.facter_exec('ipaddress6')

        expect(out).to match(/([a-z0-9]{1,4}:{1,2})+[a-z0-9]{1,4}/)
      end

      it 'returns hostname' do
        out, = IntegrationHelper.facter_exec('hostname')

        expect(out).not_to be_empty
      end

      it 'returns domain', if: IntegrationHelper.jruby? do
        out, = IntegrationHelper.facter_exec('domain')

        expect(out).not_to be_empty
      end
    end
  end

  context 'when calling the ruby API to_hash' do
    it 'returns a hash with values' do
      fact_hash = Facter.to_hash

      expect(fact_hash).to be_instance_of(Hash)
    end

    it 'contains fqdn' do
      fact_hash = Facter.to_hash

      expect(fact_hash['fqdn']).not_to be_empty
    end

    it 'contains ipaddress' do
      fact_hash = Facter.to_hash

      expect(fact_hash['ipaddress']).to match(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)
    end

    it 'contains ipaddress6' do
      fact_hash = Facter.to_hash

      expect(fact_hash['ipaddress6']).to match(/([a-z0-9]{1,4}:{1,2})+[a-z0-9]{1,4}/)
    end

    it 'contains hostname' do
      fact_hash = Facter.to_hash

      expect(fact_hash['hostname']).not_to be_empty
    end

    it 'contains domain', if: IntegrationHelper.jruby? do
      fact_hash = Facter.to_hash

      expect(fact_hash['domain']).not_to be_empty
    end
  end
end
