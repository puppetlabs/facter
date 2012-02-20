Facter.add("arp_table") do
  confine :kernel => :darwin

  setcode do
    output = Facter::Util::Resolution.exec('arp -an')

    # Prepare top level entries
    arp_table = []

    output.each_line do |line|
      values = line.split(" ")

      # Clean up some of the values first

      # Protocol is always last, but the number of items is variable so our
      # lookup is relative
      protocol    = values[-1].gsub(/[\[\]]/, '')
      hostname    = values[0].gsub(/^\?$/, '')
      ip_address  = values[1].gsub(/[()]/, '')
      mac_address = values[3].downcase

      # Populate a hash of properties from each line
      arp_entry = {
        'mac_address' => mac_address,
        'interface'   => values[5],
        'protocol'    => protocol,
        'hostname'    => hostname,
        'ip_address'  => ip_address,
      }

      arp_table << arp_entry
    end

    arp_table
  end
end
