module Facter::IPAddress
    
    def self.get_interfaces
    
     int = nil
    
     output =  Facter::IPAddress.get_all_interface_output()

     # We get lots of warnings on platforms that don't get an output
     # made.
     if output
         int = output.scan(/^\w+[.:]?\d+/)
     else
         []
     end
    
    end

    def self.get_all_interface_output
        case Facter.value(:kernel)
            when 'Linux', 'OpenBSD', 'NetBSD', 'FreeBSD'
                output = %x{/sbin/ifconfig -a}
            when 'SunOS'
                output = %x{/usr/sbin/ifconfig -a}
        end
        output
    end

    def self.get_single_interface_output(interface)
        output = ""
        case Facter.value(:kernel)
            when 'Linux', 'OpenBSD', 'NetBSD', 'FreeBSD'
                    output = %x{/sbin/ifconfig #{interface}}
            when 'SunOS'
            output = %x{/usr/sbin/ifconfig #{interface}}
        end
        output
    end


    def self.get_interface_value(interface, label)
    
    tmp1 = []

    case Facter.value(:kernel)
      when 'Linux'
       addr = /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
       mac  = /(?:ether|HWaddr)\s+(\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
       mask = /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
     when 'OpenBSD', 'NetBSD', 'FreeBSD'
       addr = /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
       mac  = /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
       mask = /netmask\s+(\w{10})/
    when 'SunOS'
       addr = /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
       mac  = /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/
       mask = /netmask\s+(\w{8})/
    end

    case label
      when 'ipaddress'
       regex = addr
      when 'macaddress'
       regex = mac
      when 'netmask'
       regex = mask
    end 

    output_int = get_single_interface_output(interface)
     
      if interface != "lo" && interface != "lo0"
        output_int.each { |s|
           if s =~ regex
               value = $1
               if label == 'netmask' && Facter.value(:kernel) == "SunOS"
                   value = value.scan(/../).collect do |byte| byte.to_i(16) end.join('.') 
               end
               tmp1.push(value)
           end
       }
      end

      if tmp1 
        value = tmp1.shift
      end

   end
end
