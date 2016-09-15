# This test is intended to demonstrate that mount resource can mount tmpfs directory
# and the mount facter mountpoints should show the mount on tmpfs

test_name "FACT-1502 - C98163 mountpoints fact should show mounts on tmpfs" do
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  confine :except, :platform => 'windows'

  agents.each do |agent|
    dir = '/tmp/tempdir'
    on(agent, "mkdir -p #{dir}")
    manifest  = 'mount_manifest.pp'

    teardown do
      on(agent, "umount #{dir}")
      on(agent, "rm -rf #{dir} #{manifest}")
    end

    create_remote_file(agent, manifest, <<-FILE)
      mount {"#{dir}":
        ensure  => mounted,
        options => 'noexec',
        fstype  => 'tmpfs',
        device  => 'tmpfs',
        atboot  => true,
      }
    FILE

    step "Apply the manifest to mount directory '#{dir}'" do
      on(agent, puppet("apply #{manifest}"), :acceptable_exit_codes => [0,2]) do
        assert_no_match(/Error/, stdout, "Unexpected error was detected!")
      end
      on(agent, facter("mountpoints.#{dir}")) do
        assert_match(/filesystem\s+=>\s+\"tmpfs\"/, stdout, "Unexpected error was detected!")
        assert_match(/device\s+=>\s+\"tmpfs\"/, stdout, "Unexpected error was detected!")
        assert_match(/noexec/, stdout, "Unexpected error was detected!")
      end
    end
  end
end
