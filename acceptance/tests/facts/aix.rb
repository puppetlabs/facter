test_name "Facts should resolve as expected in AIX 5.3, 6.1, and 7.1"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in AIX 5.3, 6.1, and 7.1.
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /aix/

agents.each do |agent|
  case agent['platform']
  when /aix-5.3/
    kernel_release = /^5300-\d+-\d+-\d+/
    kernel_major_version = '5300'
  when /aix-6.1/
    kernel_release = /^6100-\d+-\d+-\d+/
    kernel_major_version = '6100'
  when /aix-7.1/
    kernel_release = /^7100-\d+-\d+-\d+/
    kernel_major_version = '7100'
  end

  os_arch     = /[Pp]ower[Pp][Cc]/
  os_hardware = /IBM/

  step "Ensure the OS fact resolves as expected"

  expected_os = {
                  'os.architecture'         => os_arch,
                  'os.family'               => 'AIX',
                  'os.hardware'             => os_hardware,
                  'os.name'                 => 'AIX',
                  'os.release.full'         => kernel_release,
                  'os.release.major'        => kernel_major_version,
                }

  expected_os.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Processors fact resolves with reasonable values"

  expected_processors = {
                          'processors.count'         => /[1-9]+/,
                          'processors.isa'           => os_arch,
                          'processors.models'        => os_arch
                        }

  expected_processors.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Networking fact resolves with reasonable values for at least one interface"

  expected_networking = {
                          "networking.ip"       => /10\.\d+\.\d+\.\d+/,
                          "networking.mac"      => /[a-f0-9]{2}:/,
                          "networking.mtu"      => /\d+/,
                          "networking.netmask"  => /\d+\.\d+\.\d+\.\d+/,
                          "networking.network"  => /10\.\d+\.\d+\.\d+/,
                        }

  expected_networking.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure a primary networking interface was determined."
  primary_interface = fact_on(agent, 'networking.primary')
  refute_empty(primary_interface)

  step "Ensure bindings for the primary networking interface are present."
  expected_bindings = {
                        "networking.interfaces.#{primary_interface}.bindings.0.address" => /\d+\.\d+\.\d+\.\d+/,
                        "networking.interfaces.#{primary_interface}.bindings.0.netmask" => /\d+\.\d+\.\d+\.\d+/,
                        "networking.interfaces.#{primary_interface}.bindings.0.network" => /\d+\.\d+\.\d+\.\d+/,
                      }
  expected_bindings.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the identity fact resolves as expected"
  expected_identity = {
                        'identity.gid'       => '0',
                        'identity.group'     => 'system',
                        'identity.uid'       => '0',
                        'identity.user'      => 'root',
                        'identity.superuser' => true
                      }

  expected_identity.each do |fact, value|
    assert_equal(value, fact_on(agent, fact))
  end

  step "Ensure the kernel fact resolves as expected"
  expected_kernel = {
                      'kernel'           => 'AIX',
                      'kernelrelease'    => kernel_release,
                      'kernelversion'    => kernel_major_version,
                      'kernelmajversion' => kernel_major_version
                    }

  expected_kernel.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end
end
