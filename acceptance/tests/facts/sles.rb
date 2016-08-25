test_name "Facts should resolve as expected in SLES 10, 11 and 12"

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected in SLES 10, 11 and 12.
#
# Facts tested: os, processors, networking, identity, kernel
#

confine :to, :platform => /sles-10|sles-11|sles-12/

agents.each do |agent|
  if agent['platform'] =~ /sles-10/
    os_version = '10'
  elsif agent['platform'] =~ /sles-11/
    os_version = '11'
  elsif agent['platform'] =~ /sles-12/
    os_version = '12'
  end

  if agent['platform'] =~ /x86_64/
    os_arch     = 'x86_64'
    os_hardware = 'x86_64'
    processor_model_pattern = 'Intel\(R\)'
  elsif agent['platform'] =~ /s390x/
    os_arch     = 's390x'
    os_hardware = 's390x'
    processor_model_pattern = '' # s390x does not populate a model value in /proc/cpuinfo
  else
    os_arch     = 'i386'
    os_hardware = 'i686'
    processor_model_pattern = 'Intel\(R\)'
  end

  step "Ensure the OS fact resolves as expected"

  expected_os = {
                  'os.architecture'         => os_arch,
                  'os.family'               => 'Suse',
                  'os.hardware'             => os_hardware,
                  'os.name'                 => 'SLES',
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
                          'processors.models'        => /#{processor_model_pattern}/
                        }

  expected_processors.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure the identity fact resolves as expected"
  expected_identity = {
                        'identity.gid'        => '0',
                        'identity.group'      => 'root',
                        'identity.uid'        => '0',
                        'identity.user'       => 'root',
                        'identity.privileged' => 'true'
                      }

  expected_identity.each do |fact, value|
    assert_equal(value, fact_on(agent, fact))
  end

  step "Ensure the kernel fact resolves as expected"
  if os_version == '10'
    kernel_version = '2.6'
  elsif os_version == '11'
    kernel_version = '3.0'
  elsif os_version == '12'
    kernel_version = '3.12'
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
