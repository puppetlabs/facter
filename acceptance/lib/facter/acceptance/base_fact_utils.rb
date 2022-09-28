# frozen_string_literal: true

module Facter
  module Acceptance
    module BaseFactUtils
      # return a hash of expected facts for os, processors, and kernel facts
      #
      def os_processors_and_kernel_expected_facts(agent)
        if agent['platform'] =~ /aix-/
          aix_expected_facts(agent)
        elsif agent['platform'] =~ /debian-/
          debian_expected_facts(agent)
        elsif agent['platform'] =~ /el-|centos-/
          el_expected_facts(agent)
        elsif agent['platform'] =~ /fedora-/
          fedora_expected_facts(agent)
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
        kernel_major_version = if version.nil?
                                 /\d\d00/
                               else
                                 /#{version[1]}#{version[2]}00/
                               end
        kernel_release = /^#{kernel_major_version}-\d+-\d+-\d+/
        os_arch        = /[Pp]ower[Pp][Cc]/
        os_hardware    = /IBM/

        expected_facts = {
          'os.architecture' => os_arch,
          'os.family' => 'AIX',
          'os.hardware' => os_hardware,
          'os.name' => 'AIX',
          'os.release.full' => kernel_release,
          'os.release.major' => kernel_major_version,
          'processors.count' => /[1-9]+/,
          'processors.isa' => os_arch,
          'processors.models' => os_arch,
          'kernel' => 'AIX',
          'kernelrelease' => kernel_release,
          'kernelversion' => kernel_major_version,
          'kernelmajversion' => kernel_major_version
        }
        expected_facts
      end

      # Debian
      def debian_expected_facts(agent)
        version = agent['platform'].match(/debian-(\d{1,2})/)
        os_version = if version.nil?
                       /\d+/
                     else
                       /#{version[1]}/
                     end
        if agent['platform'] =~ /amd64/
          os_arch     = 'amd64'
          os_hardware = 'x86_64'
        else
          os_arch     = 'i386'
          os_hardware = 'i686'
        end

        expected_facts = {
          'os.architecture' => os_arch,
          'os.distro.codename' => /\w+/,
          'os.distro.description' => %r{Debian GNU/Linux #{os_version}(\.\d)?},
          'os.distro.id' => 'Debian',
          'os.distro.release.full' => /#{os_version}\.\d+/,
          'os.distro.release.major' => os_version,
          'os.distro.release.minor' => /\d/,
          'os.family' => 'Debian',
          'os.hardware' => os_hardware,
          'os.name' => 'Debian',
          'os.release.full' => /#{os_version}\.\d+/,
          'os.release.major' => os_version,
          'os.release.minor' => /\d/,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa' => /unknown|#{os_hardware}/,
          'processors.models' => /(Intel\(R\).*)|(AMD.*)/,
          'kernel' => 'Linux',
          'kernelrelease' => /\d+\.\d+\.\d+/,
          'kernelversion' => /\d+\.\d+/,
          'kernelmajversion' => /\d+\.\d+/
        }
        expected_facts
      end

      # el (RedHat, Centos)
      def el_expected_facts(agent)
        version = agent['platform'].match(/(el|centos)-(\d)/)
        os_version = if version.nil?
                       /\d+/
                     else
                       /#{version[2]}/
                     end
        release_string = on(agent, 'cat /etc/*-release').stdout.downcase
        case release_string
        when /almalinux/
          os_name = 'AlmaLinux'
          os_distro_description = /AlmaLinux release #{os_version}\.\d+ \(.+\)/
          os_distro_id = 'AlmaLinux'
          os_distro_release_full = /#{os_version}\.\d+/
        when /amazon/
          os_name = 'Amazon'
          # This parses: VERSION_ID="2017.09"
          os_version = on(agent, 'grep VERSION_ID /etc/os-release | cut --delimiter=\" --fields=2 | cut --delimiter=. --fields=1').stdout.chomp
          os_distro_description = /Amazon Linux( AMI)? release (\d )?(\()?#{os_version}(\))?/
          os_distro_id = /^Amazon(AMI)?$/
          os_distro_release_full = /#{os_version}(\.\d+)?/
        when /rocky/
          os_name = 'Rocky'
          os_distro_description = /Rocky Linux release #{os_version}\.\d+ \(.+\)/
          os_distro_id = 'Rocky'
          os_distro_release_full = /#{os_version}\.\d+/
        when /centos/
          os_name = 'CentOS'
          os_distro_description = /CentOS( Linux)? release #{os_version}\.\d+(\.\d+)? \(\w+\)/
          os_distro_id = 'CentOS'
          os_distro_release_full = /#{os_version}\.\d+/
        else
          os_name = 'RedHat'
          if '9'.match?(os_version) # FIXME: special case to be removed when ISO is updated to release ISO
            os_distro_description = /Red Hat Enterprise Linux( Server)? release #{os_version}\.\d+ Beta \(\w+\)/
          else
            os_distro_description = /Red Hat Enterprise Linux( Server)? release #{os_version}\.\d+ \(\w+\)/
          end
          os_distro_id = /^RedHatEnterprise(Server)?$/
          os_distro_release_full = /#{os_version}\.\d+/
        end
        if agent['platform'] =~ /x86_64/
          os_arch                 = 'x86_64'
          os_hardware             = 'x86_64'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        elsif agent['platform'] =~ /aarch64/
          os_arch                 = 'aarch64'
          os_hardware             = 'aarch64'
          processor_model_pattern = // # aarch64 does not populate a model value in /proc/cpuinfo
        elsif agent['platform'] =~ /ppc64le/
          os_arch                 = 'ppc64le'
          os_hardware             = 'ppc64le'
          processor_model_pattern = /(POWER.*)/
        else
          os_arch                 = 'i386'
          os_hardware             = 'i686'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        end

        {}.tap do |expected_facts|
          expected_facts['os.architecture'] = os_arch
          expected_facts['os.distro.codename'] = /\w+/
          expected_facts['os.distro.description'] = os_distro_description
          expected_facts['os.distro.id'] = os_distro_id
          expected_facts['os.distro.release.full'] = os_distro_release_full
          expected_facts['os.distro.release.major'] = os_version
          expected_facts['os.distro.release.minor'] = /\d/ if os_version != '2' # Amazon Linux 2
          expected_facts['os.family'] = 'RedHat'
          expected_facts['os.hardware'] = os_hardware
          expected_facts['os.name'] = os_name
          expected_facts['os.release.full'] = /#{os_version}(\.\d+)?(\.\d+)?/
          expected_facts['os.release.major'] = os_version
          expected_facts['os.release.minor'] = /(\d+)?/
          expected_facts['processors.count'] = /[1-9]/
          expected_facts['processors.physicalcount'] = /[1-9]/
          expected_facts['processors.isa'] = os_hardware
          expected_facts['processors.models'] = processor_model_pattern
          expected_facts['kernel'] = 'Linux'
          expected_facts['kernelrelease'] = /\d+\.\d+\.\d+/
          expected_facts['kernelversion'] = /\d+\.\d+/
          expected_facts['kernelmajversion'] = /\d+\.\d+/
        end
      end

      # fedora
      def fedora_expected_facts(agent)
        version = agent['platform'].match(/fedora-(\d\d)-/)
        os_version = if version.nil?
                       /\d+/
                     else
                       /#{version[1]}/
                     end
        if agent['platform'] =~ /x86_64/
          os_arch     = 'x86_64'
          os_hardware = 'x86_64'
        else
          os_arch     = 'i386'
          os_hardware = 'i686'
        end

        expected_facts = {
          'os.architecture' => os_arch,
          'os.distro.codename' => /\w+/,
          'os.distro.description' => /Fedora release #{os_version} \(\w+( \w+)?\)/,
          'os.distro.id' => 'Fedora',
          'os.distro.release.full' => os_version,
          'os.distro.release.major' => os_version,
          'os.family' => 'RedHat',
          'os.hardware' => os_hardware,
          'os.name' => 'Fedora',
          'os.release.full' => os_version,
          'os.release.major' => os_version,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa' => os_hardware,
          'processors.models' => /(Intel\(R\).*)|(AMD.*)/,
          'kernel' => 'Linux',
          'kernelrelease' => /\d+\.\d+\.\d+/,
          'kernelversion' => /\d+\.\d+\.\d+/,
          'kernelmajversion' => /\d+\.\d+/
        }
        expected_facts
      end

      # osx
      def osx_expected_facts(agent)
        version = agent['platform'].match(/osx-(\d+)\.?(\d+)?/)
        major_version = /#{Regexp.escape(version.captures.compact.join('.'))}/
        if agent['platform'] =~ /x86_64/
          os_arch                 = 'x86_64'
          os_hardware             = 'x86_64'
          processors_isa          = 'i386'
          processors_models       = /"Intel\(R\).*"/
        elsif agent['platform'] =~ /arm64/
          os_arch                 = 'arm64'
          os_hardware             = 'arm64'
          processors_isa          = 'arm'
          processors_models       = /"Apple M1.*"/
        end
        expected_facts = {
          'os.architecture' => os_arch,
          'os.family' => 'Darwin',
          'os.hardware' => os_hardware,
          'os.name' => 'Darwin',
          'os.macosx.build' => /\d+[A-Z]\d{1,4}\w?/,
          'os.macosx.product' => agent['platform'] =~ /osx-10/ ? 'Mac OS X' : 'macOS',
          'os.macosx.version.major' => major_version,
          'os.macosx.version.minor' => /\d+/,
          'os.release.full' => /\d+\.\d+\.\d+/,
          'os.release.major' => /\d+/,
          'os.release.minor' => /\d+/,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa'           => processors_isa,
          'processors.models'        => processors_models,
          'kernel' => 'Darwin',
          'kernelrelease' => /\d+\.\d+\.\d+/,
          'kernelversion' => /\d+\.\d+\.\d+/,
          'kernelmajversion' => /\d+\.\d+/
        }

        if agent['platform'] =~ /osx-10/
          expected_facts['os.macosx.version.full'] = /#{expected_facts['os.macosx.version.major']}\.#{expected_facts['os.macosx.version.minor']}/
        else
          expected_facts['os.macosx.version.patch'] = /\d+/
          if agent['platform'] =~ /arm64/
            expected_facts['os.macosx.version.full'] = /^#{expected_facts['os.macosx.version.major']}\.#{expected_facts['os.macosx.version.minor']}$/
          else
            expected_facts['os.macosx.version.full'] = /^#{expected_facts['os.macosx.version.major']}\.#{expected_facts['os.macosx.version.minor']}\.*#{expected_facts['os.macosx.version.patch']}*$/
          end
        end
        expected_facts
      end

      # SLES
      def sles_expected_facts(agent)
        version = agent['platform'].match(/sles-(\d\d)/)
        os_version = if version.nil?
                       /\d+/
                     else
                       /#{version[1]}/
                     end
        if agent['platform'] =~ /x86_64/
          os_arch                 = 'x86_64'
          os_hardware             = 'x86_64'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        else
          os_arch                 = 'i386'
          os_hardware             = 'i686'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        end

        expected_facts = {
          'os.architecture' => os_arch,
          'os.distro.codename' => /\w+/,
          'os.distro.description' => /SUSE Linux Enterprise Server/,
          'os.distro.id' => /^SUSE( LINUX)?$/,
          'os.distro.release.full' => /#{os_version}\.\d+/,
          'os.distro.release.major' => os_version,
          'os.distro.release.minor' => /\d/,
          'os.family' => 'Suse',
          'os.hardware' => os_hardware,
          'os.name' => 'SLES',
          'os.release.full' => /#{os_version}\.\d+(\.\d+)?/,
          'os.release.major' => os_version,
          'os.release.minor' => /\d+/,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa' => os_hardware,
          'processors.models' => processor_model_pattern,
          'kernel' => 'Linux',
          'kernelrelease' => /\d+\.\d+\.\d+/,
          'kernelversion' => /\d+\.\d+\.\d+/,
          'kernelmajversion' => /\d+\.\d+/
        }
        expected_facts
      end

      # Solaris
      def solaris_expected_facts(agent)
        version = agent['platform'].match(/solaris-(\d\d)/)
        os_version = if version.nil?
                       /\d+/
                     else
                       /#{version[1]}/
                     end
        case agent[:platform]
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
          'os.architecture' => os_architecture,
          'os.family' => 'Solaris',
          'os.hardware' => os_architecture,
          'os.name' => 'Solaris',
          'os.release.full' => os_release_full,
          'os.release.major' => os_version,
          'os.release.minor' => /\d+/,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa' => proc_isa,
          'processors.models' => proc_models,
          'kernel' => 'SunOS',
          'kernelrelease' => /5\.#{os_version}/,
          'kernelversion' => os_kernel,
          'kernelmajversion' => os_kernel_major
        }
        expected_facts
      end

      # Ubuntu
      def ubuntu_expected_facts(agent)
        version = agent['platform'].match(/ubuntu-(\d\d\.\d\d)/)
        os_version = if version.nil?
                       /\d+\.\d+/
                     else
                       /#{version[1]}/
                     end
        if agent['platform'] =~ /x86_64|amd64/
          os_arch     = 'amd64'
          os_hardware = 'x86_64'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        elsif agent['platform'] =~ /aarch64/
          os_arch                 = 'aarch64'
          os_hardware             = 'aarch64'
          processor_model_pattern = // # facter doesn't figure out the processor type on these machines
        else
          os_arch     = 'i386'
          os_hardware = 'i686'
          processor_model_pattern = /(Intel\(R\).*)|(AMD.*)/
        end

        expected_facts = {
          'os.architecture' => os_arch,
          'os.distro.codename' => /\w+/,
          'os.distro.description' => /Ubuntu #{os_version}/,
          'os.distro.id' => 'Ubuntu',
          'os.distro.release.full' => os_version,
          'os.distro.release.major' => os_version,
          'os.family' => 'Debian',
          'os.hardware' => os_hardware,
          'os.name' => 'Ubuntu',
          'os.release.full' => os_version,
          'os.release.major' => os_version,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa' => os_hardware,
          'processors.models' => processor_model_pattern,
          'kernel' => 'Linux',
          'kernelrelease' => /\d+\.\d+\.\d+/,
          'kernelversion' => /\d+\.\d+\.\d+/,
          'kernelmajversion' => /\d+\.\d+/
        }
        expected_facts
      end

      # Windows
      def windows_expected_facts(agent)
        # Get expected values based on platform name
        if agent['platform'] =~ /2012/
          os_version = agent['platform'] =~ /R2/ ? '2012 R2' : '2012'
        elsif agent['platform'] =~ /-10/
          os_version = '10'
        elsif agent['platform'] =~ /-11/
          os_version = '11'
        elsif agent['platform'] =~ /2016/
          os_version = '2016'
        elsif agent['platform'] =~ /2019/
          os_version = '2019'
        elsif agent['platform'] =~ /2022/
          os_version = '2022'
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
          'os.architecture' => os_arch,
          'os.family' => 'windows',
          'os.hardware' => os_hardware,
          'os.name' => 'windows',
          'os.release.full' => os_version,
          'os.release.major' => os_version,
          'os.windows.system32' => /C:\\(WINDOWS|[Ww]indows)\\(system32|sysnative)/,
          'processors.count' => /[1-9]/,
          'processors.physicalcount' => /[1-9]/,
          'processors.isa' => /x86|x64/,
          'processors.models' => /(Intel\(R\).*)|(AMD.*)/,
          'kernel' => 'windows',
          'kernelrelease' => /\d+\.\d+/,
          'kernelversion' => /\d+\.\d+/,
          'kernelmajversion' => /\d+\.\d+/
        }
        expected_facts
      end
    end
  end
end
