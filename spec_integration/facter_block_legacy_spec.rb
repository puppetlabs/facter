# frozen_string_literal: true

require 'json'
require_relative 'integration_helper'

describe 'Facter' do
  context 'when legacy facts is blocked' do
    let(:facter_conf_content) do
      'facts : {
  blocklist : [ "legacy" ],
}'
    end

    let(:core_facts) do
      %w[dmi facterversion identity is_virtual kernel kernelmajversion kernelrelease
         kernelversion memory networking os path processors ruby system_uptime timezone virtual]
    end

    let(:legacy_facts) do
      %w[architecture augeasversion dhcp_servers fqdn gid hardwareisa hardwaremodel hostname id interfaces
         ipaddress ipaddress6 ipaddress6_.* ipaddress_.* macaddress macaddress_.* memoryfree
         memoryfree_mb memorysize memorysize_mb mtu_.* netmask netmask6 netmask6_.*
         netmask_.* network network6 network6_.* network_.* operatingsystem operatingsystemmajrelease
         operatingsystemrelease osfamily physicalprocessorcount processor[0-9]+.*
         processorcount productname rubyplatform rubysitedir rubyversion scope6 scope6_.* sp_boot_mode
         sp_boot_volume sp_cpu_type sp_current_processor_speed sp_kernel_version sp_l2_cache_core
         sp_l3_cache sp_local_host_name sp_machine_model sp_machine_name sp_number_processors sp_os_version
         sp_packages sp_physical_memory sp_platform_uuid sp_secure_vm sp_serial_number sp_uptime
         sp_user_name swapencrypted swapfree swapfree_mb swapsize swapsize_mb uptime uptime_days
         uptime_hours uptime_seconds]
    end

    let(:facter_output) do
      facter_conf_path = IntegrationHelper.create_file('./temp/facter.conf', facter_conf_content)
      out, = IntegrationHelper.exec_facter('-c', facter_conf_path, '--show-legacy', '-j')
      JSON.parse(out)
    end

    after do
      FileUtils.rm_rf('./temp')
    end

    it 'checks legacy facts are blocked' do
      expect(facter_output.keys).not_to match_array(legacy_facts)
    end

    it 'checks core fact are not blocked' do
      expect(facter_output.keys).to include(*core_facts)
    end
  end
end
