# mamufacturer.rb
# Support methods for manufacturer specific facts

module Facter::Manufacturer

  def self.get_dmi_table()
    case Facter.value(:kernel)
    when 'Linux', 'GNU/kFreeBSD'
      return nil unless FileTest.exists?("/usr/sbin/dmidecode")

      output=%x{/usr/sbin/dmidecode 2>/dev/null}
    when 'FreeBSD'
      return nil unless FileTest.exists?("/usr/local/sbin/dmidecode")

      output=%x{/usr/local/sbin/dmidecode 2>/dev/null}
    when 'NetBSD'
      return nil unless FileTest.exists?("/usr/pkg/sbin/dmidecode")

      output=%x{/usr/pkg/sbin/dmidecode 2>/dev/null}
    when 'SunOS'
      return nil unless FileTest.exists?("/usr/sbin/smbios")

      output=%x{/usr/sbin/smbios 2>/dev/null}
    else
      output=nil
    end
    return output
  end

  def self.dmi_find_system_info(name)
    splitstr=  Facter.value(:kernel) ==  'SunOS' ? "ID  SIZE TYPE" : /^Handle/
    output = self.get_dmi_table()
    return if output.nil?
    name.each_pair do |key,v|
      v.each do |v2|
        v2.each_pair do |value,facterkey|
          output.split(splitstr).each do |line|
            if line =~ /#{key}/ and line =~ /\n\s+#{value} (.+)\n/
              result = $1.strip
              Facter.add(facterkey) do
                confine :kernel => [ :linux, :freebsd, :netbsd, :sunos, :"gnu/kfreebsd" ]
                setcode do
                  result
                end
              end
            end
          end
        end
      end
    end
  end

  def self.sysctl_find_system_info(name)
    name.each do |sysctlkey,facterkey|
      Facter.add(facterkey) do
        confine :kernel => [:openbsd, :darwin]
        setcode do
          Facter::Util::Resolution.exec("sysctl -n #{sysctlkey} 2>/dev/null")
        end
      end
    end
  end

  def self.prtdiag_sparc_find_system_info()
    # Parses prtdiag for a SPARC architecture string, won't work with Solaris x86
    output = Facter::Util::Resolution.exec('/usr/sbin/prtdiag')

    # System Configuration:  Sun Microsystems  sun4u Sun SPARC Enterprise M3000 Server
    sysconfig = output.split("\n")[0]
    if sysconfig =~ /^System Configuration:\s+(.+?)\s+(sun\d+\S+)\s+(.+)/ then
      Facter.add('manufacturer') do
        setcode do
          $1
        end
      end
      Facter.add('productname') do
        setcode do
          $3
        end
      end
    end

    Facter.add('serialnumber') do
      setcode do
        Facter::Util::Resolution.exec("/usr/sbin/sneep")
      end
    end
  end

  def self.win32_find_system_info(name)
    require 'facter/util/wmi'
    value = ""
    wmi = Facter::Util::WMI.connect()
    name.each do |facterkey, win32key|
      query = wmi.ExecQuery("select * from Win32_#{win32key.last}")
      Facter.add(facterkey) do
        confine :kernel => :windows
        setcode do
          query.each { |x| value = x.__send__( (win32key.first).to_sym) }
          value
        end
      end
    end
  end
end
