# This test is intended to demonstrate that mount resource can mount tmpfs file systems
# and the mount facter mountpoints should show the mount as tmpfs
test_name 'C98163: mountpoints fact should show mounts on tmpfs' do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils


  confine :except, :platform => 'windows'
  confine :except, :platform => /osx/ # See PUP-4823
  confine :except, :platform => /solaris/ # See PUP-5201
  confine :except, :platform => /aix/     # See PUP-6845
  confine :except, :platform => /^eos-/ # Mount provider not supported on Arista EOS switches
  confine :except, :platform => /^cisco_/ # See PUP-5826
  confine :except, :platform => /^huawei/ # See PUP-6126

  agents.each do |agent|
    mount_point = '/tmp/mountdir'
    manifest_dir = agent.tmpdir('tmpfs')
    manifest = File.join(manifest_dir, 'mount_manifest.pp')
    manifest_content = <<-FILE
      mount {"#{mount_point}":
        ensure  => mounted,
        options => 'noexec',
        fstype  => 'tmpfs',
        device  => 'tmpfs',
        atboot  => true,
      }
    FILE
    agent.mkdir_p(mount_point)
    create_remote_file(agent, manifest, manifest_content)

    teardown do
      on(agent, "umount #{mount_point}")
      agent.rm_rf(mount_point)
      agent.rm_rf(manifest_dir)
    end

    step "Apply the manifest to mount directory '#{mount_point}'" do
      on(agent, puppet("apply #{manifest}"), :acceptable_exit_codes => [0,2]) do |puppet_apply|
        assert_no_match(/Error/, puppet_apply.stdout, 'Unexpected error on stdout was detected!')
        assert_no_match(/ERROR/, puppet_apply.stderr, 'Unexpected error on stderr was detected!')
      end
    end

    step 'verify tmpfs mount point seen by facter' do
      on(agent, facter("mountpoints.#{mount_point}")) do |facter_output|
        assert_match(/filesystem\s+=>\s+\"tmpfs\"/, facter_output.stdout, 'filesystem is the wrong type')
        assert_match(/device\s+=>\s+\"tmpfs\"/, facter_output.stdout, 'device is not a tmpfs')
        assert_match(/noexec/, facter_output.stdout, 'expected to see noexec option')
      end
    end
  end
end
