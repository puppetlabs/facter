require 'puppet/acceptance/common_utils'
require 'beaker/dsl/install_utils'
extend Beaker::DSL::InstallUtils

test_name "Install Packages"

step "Install puppet-agent..." do
  opts = {
    :puppet_collection    => 'PC1',
    :puppet_agent_sha     => ENV['SHA'],
    :puppet_agent_version => ENV['SUITE_VERSION'] || ENV['SHA']
  }

   # Move the openssl libs package to a newer version on redhat platforms
   use_system_openssl = ENV['USE_SYSTEM_OPENSSL']

   if use_system_openssl && agent[:platform].match(/(?:el-7|redhat-7)/)
     rhel7_openssl_version = ENV['RHEL7_OPENSSL_VERSION']
     if rhel7_openssl_version.to_s.empty?
       # Fallback to some default is none is provided
       rhel7_openssl_version = "openssl-1.0.1e-51.el7_2.4.x86_64"
     end
     on(agent, "yum -y install " +  rhel7_openssl_version)
   else
     step "Skipping upgrade of openssl package... (" + agent[:platform] + ")"
   end

  install_puppet_agent_dev_repo_on(hosts, opts)
end

# make sure install is sane, beaker has already added puppet and ruby
# to PATH in ~/.ssh/environment
agents.each do |agent|
  on agent, puppet('--version')
  ruby = Puppet::Acceptance::CommandUtils.ruby_command(agent)
  on agent, "#{ruby} --version"
end


step "Enable FIPS on agent hosts..." do

 # There might be a better way to do some things below but till then...
 # The TODO's need to be followed up

 # agents.each do |agent|
 #   next if agent == master # Only on agents.

    # Do this only on rhel7, rhel6, f24, f25
    use_system_openssl = ENV['USE_SYSTEM_OPENSSL']
    if use_system_openssl
      # Other platforms to come...
      next if !agent[:platform].match(/(?:el-7|redhat-7)/)

      # Step 1: Disable prelinking
      # TODO:: Handle cases where the /etc/sysconfig/prelink might exist
      on(agent, 'echo "PRELINKING=no" > /etc/sysconfig/prelink')
      # TODO: prelink is commented till we figure how to attempt executing
      # it so any failures do not cause this thing to exit
      # on(agent, "prelink -u -a")
 
      # Step 2: Install dracut-fips, dracut-fips-aesni
      on(agent, "yum -y install dracut-fips")
      on(agent, "yum -y install dracut-fips-aesni")

      # TODO:: Backup existing kernel image in case anything goes south..
      # Step 3: Run dracut to update system for fips. 
      on(agent, "dracut -v -f")


      # TODO:: Steps 4 and 5 need to be adjusted for rhel6, f24, f25
      # as the method of enabling FIPS are different on those platforms. 
      # Below works on rhel7
      
      # Step 4: Find out the device details (BLOCK ID) of boot partition
      # append enable fips and boot block id to kernel command line in grub file
      
      on(agent, 'boot_blkid=$(blkid `df /boot | grep "/dev" | awk \'BEGIN{ FS=" "}; {print $1}\'` | awk \'BEGIN{ FS=" "}; {print $2}\' | sed \'s/"//g\');\
                 fips_bootblk="fips=1 boot="$boot_blkid;\
                 grub_linux_cmdline=`grep -e "^GRUB_CMDLINE_LINUX" /etc/default/grub | sed "s/\"$/ $fips_bootblk\"/"`;\
                 grep -v GRUB_CMDLINE_LINUX /etc/default/grub > /etc/default/grub.bak;\
                 /bin/cp -rf /etc/default/grub.bak /etc/default/grub;\
                 sed -i "/GRUB_DISABLE_RECOVERY/i $grub_linux_cmdline" /etc/default/grub')


      # Step 5: Run grub2 mkconfig to make the changes take effect.
      on(agent, 'grub2-mkconfig -o /boot/grub2/grub.cfg')

      # Reboot is needed for the system to start in FIPS mode
      agent.reboot
      timeout = 30
      begin
        Timeout.timeout(timeout) do
          until agent.up?
            sleep 1
          end
        end
      rescue Timeout::Error => e
        raise "Agent did not come back up within #{timeout} seconds."
      end
      
      # TODO:
      # Ensure that agent is actually in fips mode by examining the contents of
      # /proc/sys/crypto/fips_enabled and that it is 1

      # Switch to using sha256 to work in fips mode.
      on agent, puppet('config set digest_algorithm sha256')
      
    end
  # end
end
