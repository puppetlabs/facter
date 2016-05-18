test_name "Facts should resolve as expected on Windows platforms"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected on Windows platforms.
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /windows-/

agents.each do |agent|

  # Get expected values based on platform name
  if agent['platform'] =~ /2003/
    os_version  = '2003 R2'
    kernel_version = '5.2'
  elsif agent['platform'] =~ /2008/
    os_version  = '2008 R2'
    kernel_version = '6.1'
  elsif agent['platform'] =~ /2012/
    os_version  = '2012 R2'
    kernel_version = '6.3'
  elsif agent['platform'] =~ /-10/
    os_version  = /^10\./
    kernel_version = /^10\./
  else
    raise "Unknown agent platform of #{agent['platform']}"
  end


  step "Ensure the OS fact resolves as expected"

  expected_os = {
                  'os.architecture'         => agent['platform'] =~ /64/ ? 'x64' : 'x86',
                  'os.family'               => 'windows',
                  'os.hardware'             => agent['platform'] =~ /64/ ? 'x86_64' : 'i686',
                  'os.name'                 => 'windows',
                  'os.release.full'         => os_version,
                  'os.release.major'        => os_version,
                  'os.windows.system32'     => /C:\\(WINDOWS|Windows)\\(system32|sysnative)/,
                }

  expected_os.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Processors fact resolves with reasonable values"

  expected_processors = {
                          'processors.count'         => /[1-9]/,
                          'processors.physicalcount' => /[1-9]/,
                          'processors.isa'           => /(x64|x86)/,
                          'processors.models'        => /"Intel\(R\).*"/
                        }

  expected_processors.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Networking fact resolves with reasonable values for at least one interface"

  expected_networking = {
                          "networking.dhcp"     => /10\.\d+\.\d+\.\d+/,
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
                        "networking.interfaces.\"#{primary_interface}\".bindings.0.address" => /\d+\.\d+\.\d+\.\d+/,
                        "networking.interfaces.\"#{primary_interface}\".bindings.0.netmask" => /\d+\.\d+\.\d+\.\d+/,
                        "networking.interfaces.\"#{primary_interface}\".bindings.0.network" => /\d+\.\d+\.\d+\.\d+/
                      }
  expected_bindings.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the identity fact resolves as expected"
  expected_identity = {
                        'identity.user'   => /.*\\cyg_server/,
                      }

  expected_identity.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the kernel fact resolves as expected"

  expected_kernel = {
                      'kernel'           => 'windows',
                      'kernelrelease'    => kernel_version,
                      'kernelversion'    => kernel_version,
                      'kernelmajversion' => kernel_version
                    }

  expected_kernel.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end
end
