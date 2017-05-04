test_name "C15496: Facts should resolve as expected on Solaris" do
  tag 'risk:high'

#
# This test is intended to ensure that facts specific to an OS configuration
# resolve as expected on Solaris
#
# Facts tested: os, processors, networking, identity, kernel
#

  confine :to, :platform => /solaris-1[01]/

  agents.each do |agent|
    case agent[:platform]
      when /solaris-10/
        os_version      = '10'
        os_release_full = /#{os_version}_u\d+/
        os_kernel       = /Generic_\d+-\d+/
        os_kernel_major = os_kernel
      when /solaris-11/
        os_version      = '11'
        os_release_full = /#{os_version}\.\d+/
        os_kernel       = os_release_full
        os_kernel_major = os_version
    end

    case agent[:platform]
      when /sparc/
        os_architecture = 'sun4v'
        proc_models     = /.*SPARC.*/
        proc_isa        = /sparc/
      else
        os_architecture = 'i86pc'
        proc_models     = /"Intel\(r\).*"/
        proc_isa        = /i386/
    end

    step "Ensure the OS fact resolves as expected" do
      expected_os = {
          'os.architecture'  => os_architecture,
          'os.family'        => 'Solaris',
          'os.hardware'      => os_architecture,
          'os.name'          => 'Solaris',
          'os.release.full'  => os_release_full,
          'os.release.major' => os_version,
          'os.release.minor' => /\d+/,
      }

      expected_os.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end

    step "Ensure the Processors fact resolves with reasonable values" do
      expected_processors = {
          'processors.count'         => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa'           => proc_isa,
          'processors.models'        => proc_models
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
          'kernel'           => 'SunOS',
          'kernelrelease'    => "5.#{os_version}",
          'kernelversion'    => os_kernel,
          'kernelmajversion' => os_kernel_major
      }

      expected_kernel.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end
  end
end
