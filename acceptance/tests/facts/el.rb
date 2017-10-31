test_name "Facts should resolve as expected on EL" do
  tag 'risk:high'

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected on EL.
#
# Facts tested: os, processors, networking, identity, kernel
#

# Don't test on RedHat 4, as is does not include yum (See BKR-512)
  confine :to, :platform => /el-[5-7]|centos-[4-7]/

  agents.each do |agent|
    # TODO: It might be time to start abstracting all of this logic away as more versions are continually added.
    case agent['platform']
      when /centos-4/
        os_version     = '4'
        kernel_version = '2.6'
      when /(el|centos)-5/
        os_version     = '5'
        kernel_version = '2.6'
      when /(el|centos)-6/
        os_version     = '6'
        kernel_version = '2.6'
      when /el-7-aarch64/
        # We're using CentOS 7.4 for our aarch64 builds and testing
        # because older versions have significant (kernel) differences
        # with RHEL 7 aarch64:
        os_version = '7'
        kernel_version = '4.11'
      else
        os_version = '7'
        agent['template'] =~ /oracle/ ? kernel_version = '3.8' : kernel_version = '3.1'
    end

    release_string = on(agent, 'cat /etc/*-release').stdout.downcase
    case release_string
      when /centos/
        os_name = 'CentOS'
      when /oracle/
        os_name = 'OracleLinux'
      when /scientific/
        os_name = 'Scientific'
      when /amazon/
        os_name = 'Amazon'
        if os_version == '6'
          os_version = '2017'
          kernel_version = '4.9'
        end
      else
        os_name = 'RedHat'
    end

    if agent['platform'] =~ /x86_64/
      os_arch                 = 'x86_64'
      os_hardware             = 'x86_64'
      processor_model_pattern = 'Intel\(R\)'
    elsif agent['platform'] =~ /s390x/
      os_arch                 = 's390x'
      os_hardware             = 's390x'
      processor_model_pattern = '' # s390x does not populate a model value in /proc/cpuinfo
    elsif agent['platform'] =~ /ppc64le/
      os_arch                 = 'ppc64le'
      os_hardware             = 'ppc64le'
      processor_model_pattern = 'POWER8'
    elsif agent['platform'] =~ /aarch64/
      os_arch                 = 'aarch64'
      os_hardware             = 'aarch64'
      processor_model_pattern = '' # aarch64 does not populate a model value in /proc/cpuinfo
    else
      os_arch                 = 'i386'
      os_hardware             = 'i686'
      processor_model_pattern = 'Intel\(R\)'
    end

    step "Ensure the OS fact resolves as expected" do
      expected_os = {
          'os.architecture'  => os_arch,
          'os.family'        => 'RedHat',
          'os.hardware'      => os_hardware,
          'os.name'          => os_name,
          'os.release.full'  => /#{os_version}\.\d(\.\d)?/,
          'os.release.major' => os_version,
          'os.release.minor' => /\d/,
      }

      expected_os.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end

    step "Ensure the Processors fact resolves with reasonable values" do
      expected_processors = {
          'processors.count'         => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa'           => os_hardware,
          'processors.models'        => /#{processor_model_pattern}/
      }

      expected_processors.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end

    step "Ensure the identity fact resolves as expected" do
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
    end

    step "Ensure the kernel fact resolves as expected" do
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
  end
end
