# Fact: zones                                                                                                
#
# Purpose: 
#   Return the list of zones on the system and add one zones_ fact
#   for each zone with its state e.g. running, incomplete or installed.
#
# Resolution: 
#   Uses 'usr/sbin/zoneadm list -cp' to get the list of zones in separate parsable                   
#   lines with delimeter being ':' which is used to split the line string and get 
#   the zone details.
#
# Caveats: 
#   Only for Solaris operating system 10 and greater

Facter.add("zones") do
  confine :kernel => 'SunOS'
  confine :kernelrelease =>  %w{5.10 5.11} 

  num_zones = 0

  # get the details of zones (1 per line)
  zones_list = Facter::Util::Resolution.exec('/usr/sbin/zoneadm list -cp 2>/dev/null')
  zones_list.each do |thisline|
    num_zones += 1
    # add a zone_[name] fact with its status for each zone in list 
    Facter.add("zone_#{thisline.split(':')[1]}_status") do
      setcode do
        thisline.split(":")[2]
      end
    end
  end

  # set the zones facter value
  setcode do
   num_zones
  end
end



