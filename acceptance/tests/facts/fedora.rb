test_name "Facts should resolve as expected in Fedora 20, 21, and 22"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in Fedora 20, 21, and 22.
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /fedora-2[0-2]/

agents.each do |agent|
  /fedora-(?<os_version>\d\d)/ =~ agent['platform']

  if agent['platform'] =~ /x86_64/
    os_arch     = 'x86_64'
    os_hardware = 'x86_64'
  else
    os_arch     = 'i386'
    os_hardware = 'i686'
  end

  step "Ensure the OS fact resolves as expected"
  expected_os = {
                  'os.architecture'         => os_arch,
                  'os.family'               => 'RedHat',
                  'os.hardware'             => os_hardware,
                  'os.name'                 => /Fedora/,
                  'os.release.full'         => os_version,
                  'os.release.major'        => os_version,
                }

  expected_os.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Processors fact resolves with reasonable values"
  expected_processors = {
                          'processors.count'         => /[1-9]/,
                          'processors.physicalcount' => /[1-9]/,
                          'processors.isa'           => os_hardware,
                          'processors.models'        => /"Intel\(R\).*"/
                        }

  expected_processors.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the Networking fact resolves with reasonable values for at least one interface"

  expected_networking = {
                          "networking.dhcp"     => /10\.\d+\.\d+\.\d+/,
                          "networking.ip"       => /10\.\d+\.\d+\.\d+/,
                          "networking.ip6"      => /[a-f0-9]+:+/,
                          "networking.mac"      => /[a-f0-9]{2}:/,
                          "networking.mtu"      => /\d+/,
                          "networking.netmask"  => /\d+\.\d+\.\d+\.\d+/,
                          "networking.netmask6" => /[a-f0-9]+:/,
                          "networking.network"  => /10\.\d+\.\d+\.\d+/,
                          "networking.network6" => /([a-f0-9]+)?:([a-f0-9]+)?/
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
                        "networking.interfaces.#{primary_interface}.bindings6.0.address" => /[a-f0-9:]+/,
                        "networking.interfaces.#{primary_interface}.bindings6.0.netmask" => /[a-f0-9:]+/,
                        "networking.interfaces.#{primary_interface}.bindings6.0.network" => /[a-f0-9:]+/
                      }
  expected_bindings.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the identity fact resolves as expected"
  expected_identity = {
                        'identity.gid'   => '0',
                        'identity.group' => 'root',
                        'identity.uid'   => '0',
                        'identity.user'  => 'root'
                      }

  expected_identity.each do |fact, value|
    assert_equal(value, fact_on(agent, fact))
  end

  step "Ensure the kernel fact resolves as expected"
  kernel_version = case os_version
    when '20' then '3.11'
    when '21' then '3.17'
    when '22' then '4.0'
    else 'undefined'
  end

  expected_kernel = {
                      'kernel'           => 'Linux',
                      'kernelrelease'    => kernel_version,
                      'kernelversion'    => kernel_version,
                      'kernelmajversion' => kernel_version
                    }

  expected_kernel.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end
end
