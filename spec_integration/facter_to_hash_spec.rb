# frozen_string_literal: true

require_relative 'spec_helper'

describe Facter do
  context 'when calling facter cli' do
    context 'with no user query' do
      it 'returns no stderr' do
        _, err, = IntegrationHelper.exec_facter

        expect(err).not_to match(/ERROR Facter/)
      end

      it 'returns 0 exit code' do
        _, _, status = IntegrationHelper.exec_facter

        expect(status.exitstatus).to eq(0)
      end

      it 'returns valid output' do
        out, = IntegrationHelper.exec_facter

        root_facts = ['memory => {', 'networking => {',
                      'os => {', 'path =>', 'processors => {']

        expect(out).to include(*root_facts)
      end

      it 'returns valid json output' do
        out, = IntegrationHelper.exec_facter('-j')

        expect do
          JSON.parse(out)
        end.not_to raise_exception
      end
    end

    context 'when concatenating short options' do
      context 'when using valid flags' do
        it 'returns no error' do
          _, err = IntegrationHelper.exec_facter('-pjdt')

          expect(err).not_to match(/ERROR Facter::OptionsValidator - unrecognised option/)
        end
      end

      context 'when using flags and subcommands' do
        it 'returns validation error' do
          _, err = IntegrationHelper.exec_facter('-pjdtz')

          expect(err).to match(/ERROR Facter::OptionsValidator - .*unrecognised option '-z'/)
        end
      end

      context 'when concatenating JSON and DEBUG flags' do
        out, err = IntegrationHelper.exec_facter('-jd')

        it 'outputs in valid JSON format' do
          expect do
            JSON.parse(out)
          end.not_to raise_exception
        end

        it 'outputs DEBUG logs' do
          expect(err).to match(/DEBUG/)
        end
      end

      context 'when concatenating timing and DEBUG flags' do
        out, err = IntegrationHelper.exec_facter('-td')

        it 'outputs timings of facts' do
          expect(out).to match(/fact .*, took: .* seconds/)
        end

        it 'outputs DEBUG logs' do
          expect(err).to match(/DEBUG/)
        end
      end
    end

    context 'with user query' do
      it 'returns fqdn' do
        out, = IntegrationHelper.exec_facter('fqdn')

        expect(out).not_to be_empty
      end

      it 'returns ip' do
        out, = IntegrationHelper.exec_facter('ipaddress')

        expect(out).to match(/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)
      end

      it 'returns ipaddress6' do
        out, = IntegrationHelper.exec_facter('ipaddress6')

        expect(out).to match(/([a-z0-9]{1,4}:{1,2})+[a-z0-9]{1,4}/)
      end

      it 'returns hostname' do
        out, = IntegrationHelper.exec_facter('hostname')

        expect(out).not_to be_empty
      end

      it 'returns domain', if: IntegrationHelper.jruby? do
        out, = IntegrationHelper.exec_facter('domain')

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
