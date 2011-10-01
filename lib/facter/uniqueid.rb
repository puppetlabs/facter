Facter.add(:uniqueid) do
  setcode 'hostid'
  confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS Scientific SLC SuSE SLES Debian Ubuntu Gentoo AIX OEL OracleLinux OVS GNU/kFreeBSD}
end
