module Facter
  module Acceptance
    module BaseFactUtils

      # return a hash of expected facts for os, processors, and kernel facts
      #
      def os_processors_and_kernel_expected_facts(agent)
        if agent['platform'] =~ /aix-/
          aix_expected_facts(agent)
        elsif agent['platform'] =~ /cisco/
          cisco_expected_facts(agent)
        elsif agent['platform'] =~ /cumulus-/
          cumulus_expected_facts(agent)
        elsif agent['platform'] =~ /debian-/
          debian_expected_facts(agent)
        elsif agent['platform'] =~ /el-|centos-/
          el_expected_facts(agent)
        elsif agent['platform'] =~ /eos-/ # arista
          eos_expected_facts(agent)
        elsif agent['platform'] =~ /fedora-/
          fedora_expected_facts(agent)
        elsif agent['platform'] =~ /huaweios-/
          huawei_expected_facts(agent)
        elsif agent['platform'] =~ /osx-/
          osx_expected_facts(agent)
        elsif agent['platform'] =~ /sles-/
          sles_expected_facts(agent)
        elsif agent['platform'] =~ /solaris-/
          solaris_expected_facts(agent)
        elsif agent['platform'] =~ /ubuntu-/
          ubuntu_expected_facts(agent)
        elsif agent['platform'] =~ /windows-/
          windows_expected_facts(agent)
        else
          fail_test("unknown agent type being tested #{agent['platform']}")
        end
      end

      # return the value from the facter json parsed set of results using the fact path separated using '.'s
      #
      def json_result_fact_by_key_path(results, fact)
        fact.split('.').each do |key|
          results = results[key]
        end
        results
      end

      # AIX
      def aix_expected_facts(agent)
        version = agent['platform'].match(/aix-(\d)\.(\d)/)
        if version.nil?
          kernel_major_version = /\d\d00/
        else
          kernel_major_version = /#{version[1]}#{version[2]}00/
        end
        kernel_release = /^#{kernel_major_version}-\d+-\d+-\d+/
        os_arch        = /[Pp]ower[Pp][Cc]/
        os_hardware    = /IBM/

        expected_facts = {
            'os.architecture'   => os_arch,
            'os.family'         => 'AIX',
            'os.hardware'       => os_hardware,
            'os.name'           => 'AIX',
            'os.release.full'   => kernel_release,
            'os.release.major'  => kernel_major_version,
            'processors.count'  => /[1-9]+/,
            'processors.isa'    => os_arch,
            'processors.models' => os_arch,
            'kernel'            => 'AIX',
            'kernelrelease'     => kernel_release,
            'kernelversion'     => kernel_major_version,
            'kernelmajversion'  => kernel_major_version
        }
        expected_facts
      end

      # Cisco
      def cisco_expected_facts(agent)
        os_arch                 = 'x86_64'
        os_hardware             = 'x86_64'
        processor_model_pattern = 'Westmere'

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'cisco-wrlinux',
            'os.hardware'              => os_hardware,
            'os.name'                  => /ios_xr|nexus/,
            'os.release.full'          => /\d+\.\d+(\.\d+)?/,
            'os.release.major'         => /\d+/,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /unknown|#{os_hardware}/,
            'processors.models'        => /#{processor_model_pattern}/,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # Cumulus
      def cumulus_expected_facts(agent)
        os_version       = /\d+\.\d+/
        os_release_major = /\d+/
        os_release_minor = /\d+/
        os_arch          = 'x86_64'
        os_hardware      = 'x86_64'

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.distro.codename'       => /\w+/,
            'os.distro.description'    => /#{os_version}\.\d+-/,
            'os.distro.id'             => 'Cumulus Linux',
            'os.distro.release.full'   => /#{os_version}\.\d+/,
            'os.distro.release.major'  => os_release_major,
            'os.distro.release.minor'  => os_release_minor,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'CumulusLinux',
            'os.release.full'          => /#{os_version}\.\d+/,
            'os.release.major'         => os_release_major,
            'os.release.minor'         => os_release_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /unknown|#{os_hardware}/,
            'processors.models'        => /(Intel\(R\).*)|(AMD.*)/,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # Debian
      def debian_expected_facts(agent)
        version = agent['platform'].match(/debian-(\d)/)
        if version.nil?
          os_version = /\d+/
        else
          os_version = /#{version[1]}/
        end
        if agent['platform'] =~ /amd64/
          os_arch     = 'amd64'
          os_hardware = 'x86_64'
        else
          os_arch     = 'i386'
          os_hardware = 'i686'
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.distro.codename'       => /\w+/,
            'os.distro.description'    => /Debian GNU\/Linux #{os_version}\.\d/,
            'os.distro.id'             => 'Debian',
            'os.distro.release.full'   => /#{os_version}\.\d+/,
            'os.distro.release.major'  => os_version,
            'os.distro.release.minor'  => /\d/,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Debian',
            'os.release.full'          => /#{os_version}\.\d+/,
            'os.release.major'         => os_version,
            'os.release.minor'         => /\d/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /unknown|#{os_hardware}/,
            'processors.models'        => /(Intel\(R\).*)|(AMD.*)/,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # el (RedHat, Centos)
      def el_expected_facts(agent)
        version = agent['platform'].match(/(el|centos)-(\d)/)
        if version.nil?
          os_version = /\d+/
        else
          os_version = /#{version[2]}/
        end
        release_string = on(agent, 'cat /etc/*-release').stdout.downcase
        case release_string
          when /amazon/
            os_name = 'Amazon'
            # This parses: VERSION_ID="2017.09"
            os_version = on(agent, 'grep VERSION_ID /etc/os-release | cut --delimiter=\" --fields=2 | cut --delimiter=. --fields=1').stdout.chomp
          when /centos/
            os_name = 'CentOS'
          when /oracle/
            os_name = 'OracleLinux'
          when /scientific/
            os_name = 'Scientific'
          else
            os_name = 'RedHat'
        end
        if agent['platform'] =~ /x86_64/
          os_arch                 = 'x86_64'
          os_hardware             = 'x86_64'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        elsif agent['platform'] =~ /ppc|power|64le/
          os_arch                 = 'ppc64le'
          os_hardware             = 'ppc64le'
          processor_model_pattern = // # facter doesn't figure out the processor type on these machines
        elsif agent['platform'] =~ /s390x/
          os_arch                 = 's390x'
          os_hardware             = 's390x'
          processor_model_pattern = // # s390x does not populate a model value in /proc/cpuinfo
        elsif agent['platform'] =~ /aarch64/
          os_arch                 = 'aarch64'
          os_hardware             = 'aarch64'
          processor_model_pattern = // # aarch64 does not populate a model value in /proc/cpuinfo
        else
          os_arch                 = 'i386'
          os_hardware             = 'i686'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'RedHat',
            'os.hardware'              => os_hardware,
            'os.name'                  => os_name,
            'os.release.full'          => /#{os_version}\.\d+(\.\d+)?/,
            'os.release.major'         => os_version,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => processor_model_pattern,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # eos Arista
      def eos_expected_facts(agent)
        version = agent['platform'].match(/eos-(\d+)-/)
        if version.nil?
          os_version = /\d+/
        else
          os_version = /#{version[1]}/
        end
        os_arch                 = 'x86_64'
        os_hardware             = 'x86_64'
        processor_model_pattern = 'Intel\(R\)'

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Linux',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'AristaEOS',
            'os.release.full'          => /#{os_version}\.\d+(\.\dF)?/,
            'os.release.major'         => os_version,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /#{processor_model_pattern}/,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # fedora
      def fedora_expected_facts(agent)
        version = agent['platform'].match(/fedora-(\d\d)-/)
        if version.nil?
          os_version = /\d+/
        else
          os_version = /#{version[1]}/
        end
        if agent['platform'] =~ /x86_64/
          os_arch     = 'x86_64'
          os_hardware = 'x86_64'
        else
          os_arch     = 'i386'
          os_hardware = 'i686'
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'RedHat',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Fedora',
            'os.release.full'          => os_version,
            'os.release.major'         => os_version,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => /(Intel\(R\).*)|(AMD.*)/,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # huawei
      def huawei_expected_facts(agent)
        os_version       = /\d+\.\d+/
        os_version_major = /\d+/
        os_version_minor = /\d+/
        os_arch          = 'ppc'
        os_hardware      = 'ppc'

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Debian',
            'os.release.full'          => os_version,
            'os.release.major'         => os_version_major,
            'os.release.minor'         => os_version_minor,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => 'unknown',
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # osx
      def osx_expected_facts(agent)
        version = agent['platform'].match(/osx-(10\.\d+)/)
        if version.nil?
          os_version = /\d+\.\d+/
        else
          os_version = /#{version[1]}/
        end

        expected_facts = {
            'os.architecture'          => 'x86_64',
            'os.family'                => 'Darwin',
            'os.hardware'              => 'x86_64',
            'os.name'                  => 'Darwin',
            'os.macosx.build'          => /\d+[A-Z]\d{2,4}\w?/,
            'os.macosx.product'        => 'Mac OS X',
            'os.macosx.version.full'   => /#{os_version}\.\d+/,
            'os.macosx.version.major'  => os_version,
            'os.macosx.version.minor'  => /\d+/,
            'os.release.full'          => /\d+\.\d+\.\d+/,
            'os.release.major'         => /\d+/,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => 'i386',
            'processors.models'        => /"Intel\(R\).*"/,
            'kernel'                   => 'Darwin',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # SLES
      def sles_expected_facts(agent)
        version = agent['platform'].match(/sles-(\d\d)/)
        if version.nil?
          os_version = /\d+/
        else
          os_version = /#{version[1]}/
        end
        if agent['platform'] =~ /x86_64/
          os_arch                 = 'x86_64'
          os_hardware             = 'x86_64'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        elsif agent['platform'] =~ /ppc|power|64le/
          os_arch                 = 'ppc64le'
          os_hardware             = 'ppc64le'
          processor_model_pattern = // # facter doesn't figure out the processor type on these machines
        elsif agent['platform'] =~ /s390x/
          os_arch                 = 's390x'
          os_hardware             = 's390x'
          processor_model_pattern = // # s390x does not populate a model value in /proc/cpuinfo
        else
          os_arch                 = 'i386'
          os_hardware             = 'i686'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'Suse',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'SLES',
            'os.release.full'          => /#{os_version}\.\d+(\.\d+)?/,
            'os.release.major'         => os_version,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => processor_model_pattern,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # Solaris
      def solaris_expected_facts(agent)
        version = agent['platform'].match(/solaris-(\d\d)/)
        if version.nil?
          os_version = /\d+/
        else
          os_version = /#{version[1]}/
        end
        case agent[:platform]
          when /solaris-10/
            os_release_full = /#{os_version}_u\d+/
            os_kernel       = /Generic_\d+-\d+/
            os_kernel_major = os_kernel
          when /solaris-11/
            os_release_full = /#{os_version}\.\d+/
            os_kernel       = os_release_full
            os_kernel_major = os_version
          else
            fail_test("Unknown Solaris version #{agent['platform']}")
        end
        case agent[:platform]
          when /sparc/
            os_architecture = 'sun4v'
            proc_models     = /.*SPARC.*/
            proc_isa        = /sparc/
          else
            os_architecture = 'i86pc'
            proc_models     = /(Intel.*)|(AMD.*)/
            proc_isa        = /i386/
        end

        expected_facts = {
            'os.architecture'          => os_architecture,
            'os.family'                => 'Solaris',
            'os.hardware'              => os_architecture,
            'os.name'                  => 'Solaris',
            'os.release.full'          => os_release_full,
            'os.release.major'         => os_version,
            'os.release.minor'         => /\d+/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => proc_isa,
            'processors.models'        => proc_models,
            'kernel'                   => 'SunOS',
            'kernelrelease'            => /5\.#{os_version}/,
            'kernelversion'            => os_kernel,
            'kernelmajversion'         => os_kernel_major
        }
        expected_facts
      end

      # Ubuntu
      def ubuntu_expected_facts(agent)
        version = agent['platform'].match(/ubuntu-(\d\d\.\d\d)/)
        if version.nil?
          os_version = /\d+\.\d+/
        else
          os_version = /#{version[1]}/
        end
        if agent['platform'] =~ /x86_64|amd64/
          os_arch     = 'amd64'
          os_hardware = 'x86_64'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        elsif agent['platform'] =~ /ppc|power|64le/
          os_arch                 = 'ppc64le'
          os_hardware             = 'ppc64le'
          processor_model_pattern = // # facter doesn't figure out the processor type on these machines
        else
          os_arch     = 'i386'
          os_hardware = 'i686'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.distro.codename'       => /\w+/,
            'os.distro.description'    => /Ubuntu #{os_version}/,
            'os.distro.id'             => 'Ubuntu',
            'os.distro.release.full'   => os_version,
            'os.distro.release.major'  => os_version,
            'os.family'                => 'Debian',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'Ubuntu',
            'os.release.full'          => os_version,
            'os.release.major'         => os_version,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => os_hardware,
            'processors.models'        => processor_model_pattern,
            'kernel'                   => 'Linux',
            'kernelrelease'            => /\d+\.\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end

      # Windows
      def windows_expected_facts(agent)
        # Get expected values based on platform name
        if agent['platform'] =~ /windows-7/
          os_version = '7'
        elsif agent['platform'] =~ /windows-8.1/
          os_version = '8.1'
        elsif agent['platform'] =~ /2008/
          os_version = '2008 R2'
        elsif agent['platform'] =~ /2012/
          os_version = '2012 R2'
        elsif agent['platform'] =~ /-10/
          os_version = '10'
        elsif agent['platform'] =~ /2016/
          os_version = '2016'
        else
          fail_test "Unknown Windows version #{agent['platform']}"
        end
        if agent['platform'] =~ /64/
          os_arch     = 'x64'
          os_hardware = 'x86_64'
        else
          os_arch     = 'x86'
          os_hardware = 'i686'
        end

        expected_facts = {
            'os.architecture'          => os_arch,
            'os.family'                => 'windows',
            'os.hardware'              => os_hardware,
            'os.name'                  => 'windows',
            'os.release.full'          => os_version,
            'os.release.major'         => os_version,
            'os.windows.system32'      => /C:\\(WINDOWS|Windows)\\(system32|sysnative)/,
            'processors.count'         => /[1-9]/,
            'processors.physicalcount' => /[1-9]/,
            'processors.isa'           => /x86|x64/,
            'processors.models'        => /(Intel\(R\).*)|(AMD.*)/,
            'kernel'                   => 'windows',
            'kernelrelease'            => /\d+\.\d+/,
            'kernelversion'            => /\d+\.\d+/,
            'kernelmajversion'         => /\d+\.\d+/
        }
        expected_facts
      end
    end
  end
end
