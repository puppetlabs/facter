# frozen_string_literal: true

describe 'SELinuxResolver' do
  after(:each) do
    SELinuxResolver.invalidate_cache
  end
  it 'returns false when selinux is not enabled' do
    allow(Open3).to receive(:capture2)
      .with('cat /proc/self/mounts')
      .and_return('sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,nosuid,relatime,size=3023708k,nr_inodes=755927,mode=755 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,noexec,relatime,size=610440k,mode=755 0 0
/dev/mapper/localhost--vg-root / ext4 rw,relatime,errors=remount-ro,data=ordered 0 0')
    result = SELinuxResolver.resolve(:enabled)

    expect(result).to be_falsey
  end

  it 'returns true when selinux is enabled' do
    allow(Open3).to receive(:capture2)
      .with('cat /proc/self/mounts')
      .and_return('sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,nosuid,relatime,size=3023708k,nr_inodes=755927,mode=755 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
selinuxfs /sys/fs/selinux selinuxfs rw,relatime 0 0
/dev/mapper/localhost--vg-root / ext4 rw,relatime,errors=remount-ro,data=ordered 0 0')
    result = SELinuxResolver.resolve(:enabled)

    expect(result).to be_truthy
  end
end
