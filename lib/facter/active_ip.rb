Facter.add("active_ip") do
  confine :kernel => :darwin

  setcode do
    table = []

    netstat = Facter::Util::Resolution.exec("netstat -anW")

    netstat.each_line do |line|
      next if line =~ /^Active Internet connections/
      next if line =~ /^Proto Recv-Q/
      break if line =~ /^Active LOCAL/

      part = line.split

      next if part[3] == "*.*" and part[4] == "*.*"

      proto = part[0]
      part[3] =~ /(.+)\.(.+)/
      local_address = $1
      local_port = $2
      part[4] =~ /(.+)\.(.+)/
      foreign_address = $1
      foreign_port = $2
      state = part[5]

      hash = {
        "proto" => proto,
        "local_address" => local_address,
        "local_port" => local_port,
        "foreign_address" => foreign_address,
        "foreign_port" => foreign_port,
      }
      hash["state"] if state

      table << hash

      #break if line =~ /UDP/
    end

    table
  end
end
