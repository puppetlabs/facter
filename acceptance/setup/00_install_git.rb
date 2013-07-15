test_name "Install Git"

hosts.each do |host|
  case host['platform']
  when /el-|fc-/
    step 'Installing Git'
    on host, 'yum -y install git'
  when /debian-|ubuntu-/
    step 'Installing Git'
    on host, 'apt-get -y install git-core'
  else
  end
end
