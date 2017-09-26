module Facter
  module Acceptance
    module UserFactUtils

      # Determine paths for testing custom and external facts.
      # Paths vary by platform.

      # Retrieve the path of a non-standard directory for custom or external facts.
      #
      def get_user_fact_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            File.join('C:', 'Documents and Settings', 'All Users', 'Application Data', 'PuppetLabs', 'facter', 'custom')
          else
            File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'custom')
          end
        else
          File.join('/', 'opt', 'puppetlabs', 'facter', 'custom')
        end
      end

      # Retrieve the path of the standard facts.d directory.
      #
      def get_factsd_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            File.join('C:', 'Documents and Settings', 'All Users', 'Application Data', 'PuppetLabs', 'facter', 'facts.d')
          else
            File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'facts.d')
          end
        else
          File.join('/', 'opt', 'puppetlabs', 'facter', 'facts.d')
        end
      end

      # Retrieve the path of the standard cached facts directory.
      #
      def get_cached_facts_dir(platform, version)
        if platform =~ /windows/
          if version < 6.0
            File.join('C:', 'Documents and Settings', 'All Users', 'Application Data', 'PuppetLabs', 'facter', 'cache', 'cached_facts')
          else
            File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'cache', 'cached_facts')
          end
        else
          File.join('/', 'opt', 'puppetlabs', 'facter', 'cache', 'cached_facts')
        end
      end

      # Retrieve the path of the facts.d directory in /etc/facter on Unix systems
      #
      def get_etc_factsd_dir(platform)
        if platform =~ /windows/
          raise "get_etc_factsd_dir: not a supported directory on Windows"
        else
          File.join('/', 'etc', 'facter', 'facts.d')
        end
      end

      # Retrieve the path of the facts.d diretory in /etc/puppetlabs/facter on Unix systems
      #
      def get_etc_puppetlabs_factsd_dir(platform)
        if platform =~ /windows/
          raise "get_etc_puppetlabs_factsd_dir: not a supported directory on Windows"
        else
          File.join('/', 'etc', 'puppetlabs', 'facter', 'facts.d')
        end
      end

      # Retrieve the extension to use for an external fact script.
      # Windows uses '.bat' and everything else uses '.sh'
      def get_external_fact_script_extension(platform)
        if platform =~ /windows/
          '.bat'
        else
          '.sh'
        end
      end

      # Retrieve the path to default location of facter.conf file.
      #
      def get_default_fact_dir(platform, version)
        if platform =~ /windows/
          File.join('C:', 'ProgramData', 'PuppetLabs', 'facter', 'etc')
        else
          File.join('/', 'etc', 'puppetlabs', 'facter')
        end
      end

      # Return the content for an external fact based on the platform supplied
      #
      def external_fact_content(platform, key='external_fact', value='test_value')
        unix_content = <<EOM
#!/bin/sh
echo "#{key}=#{value}"
EOM

        win_content = <<EOM
@echo off
echo #{key}=#{value}
EOM

        if platform =~ /windows/
          win_content
        else
          unix_content
        end
      end

      # Return the content for a custom fact
      #
      def custom_fact_content(key='custom_fact', value='custom_value', *args)
        <<-EOM
  Facter.add('#{key}') do
    setcode {'#{value}'}
    #{args.empty? ? '' : args.join('\n')}
  end
        EOM
      end

      # Returns a boolean indicating whether or not the host
      # is a power linux machine
      def power_linux?(host)
        variant, _, arch, __ = host['platform'].to_array
        variant =~ /el|sles|ubuntu/ && arch =~ /ppc64/
      end
    end
  end
end
