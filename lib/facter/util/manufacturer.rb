# mamufacturer.rb
# Support methods for manufacturer specific facts

require 'facter/util/posix'

module Facter::Manufacturer
  def self.get_dmi_table()
    case Facter.value(:kernel)
    when 'Linux', 'GNU/kFreeBSD'
      cmd = '/usr/sbin/dmidecode'
    when 'FreeBSD'
      cmd = '/usr/local/sbin/dmidecode'
    when 'NetBSD', 'DragonFly'
      cmd = '/usr/pkg/sbin/dmidecode'
    when 'SunOS'
      cmd = '/usr/sbin/smbios'
    end

    if cmd and (output = Facter::Core::Execution.exec("#{cmd} 2>/dev/null"))

      if output.respond_to?(:force_encoding)
        output.force_encoding(Encoding::ASCII_8BIT)
      end

      return output
    end
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
                confine :kernel => [ :linux, :freebsd, :netbsd, :sunos, :"gnu/kfreebsd", :dragonfly ]
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
        setcode { Facter::Util::POSIX.sysctl(sysctlkey) }
      end
    end
  end

  def self.prtdiag_sparc_find_system_info()
    # Parses prtdiag for a SPARC architecture string, won't work with Solaris x86
    output = Facter::Core::Execution.exec('/usr/sbin/prtdiag 2>/dev/null | /usr/bin/head -n 10')

    # System Configuration:  Sun Microsystems  sun4u Sun SPARC Enterprise M3000 Server
    if output and output =~ /^System Configuration:\s+(.+?)\s+(sun\d+\S+)\s+(.+)/
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
      setcode "/usr/sbin/sneep"
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
