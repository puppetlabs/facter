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
    end
  end
end
