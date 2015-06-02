test_name "Facts should resolve as expected in EL 5, 6 and 7"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in EL 5, 6 and 7.
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /el-5|el-6|el-7|centos-5|centos-6|centos-7/

agents.each do |agent|
  if agent['platform'] =~ /el-5|centos-5/
    os_version = '5'
  elsif agent['platform'] =~ /el-6|centos-6/
    os_version = '6'
  else
    os_version = '7'
  end

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
                  'os.name'                 => /(RedHat|CentOS)/,
                  'os.release.full'         => /#{os_version}\.\d(\.\d)?/,
                  'os.release.major'        => os_version,
                  'os.release.minor'        => /\d/,
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
                          "networking.ip6"      => /[a-z0-9]+:+/,
                          "networking.mac"      => /[a-z0-9]{2}:/,
                          "networking.mtu"      => /\d+/,
                          "networking.netmask"  => /\d+\.\d+\.\d+\.\d+/,
                          "networking.netmask6" => /[a-z0-9]+:/,
                          "networking.network"  => /10\.\d+\.\d+\.\d+/,
                          "networking.network6" => /([a-z0-9]+)?:([a-z0-9]+)?/
                        }

  expected_networking.each do |fact, value|
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
  if os_version == '5' || os_version == '6'
    kernel_version = '2.6'
  else
    kernel_version = '3.1'
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
