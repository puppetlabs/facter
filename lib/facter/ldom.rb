if Facter.value(:kernel) == 'SunOS'
  virtinfo = Facter::Util::Resolution.exec('virtinfo -ap')

  # Convert virtinfo parseable output format to array of arrays.
  # DOMAINROLE|impl=LDoms|control=true|io=true|service=true|root=true
  # DOMAINNAME|name=primary
  # DOMAINUUID|uuid=8e0d6ec5-cd55-e57f-ae9f-b4cc050999a4
  # DOMAINCONTROL|name=san-t2k-6
  # DOMAINCHASSIS|serialno=0704RB0280
  #
  # For keys containing multiple value such as domain role:
  # ldom_{key}_{subkey} = value
  # Otherwise the fact will simply be:
  # ldom_{key} = value
  unless virtinfo.nil?
    virt_array = virtinfo.split("\n").select{|l| l =~ /^DOMAIN/ }.
      collect{|l| l.split('|')}
    virt_array.each do |x|
      key = x[0]
      value = x[1..x.size]

      if value.size == 1
        Facter.add("ldom_#{key.downcase}".to_sym) do
          setcode { value.first.split('=')[1] }
        end
      else
        value.each do |y|
          k = y.split('=')[0]
          v = y.split('=')[1]
          Facter.add("ldom_#{key.downcase}_#{k.downcase}".to_sym) do
            setcode { v }
          end
        end
      end
    end

    # When ldom domainrole control = false, the system is a guest, so we mark it
    # as a virtual system:
    Facter.add(:virtual) do
      confine :ldom_domainrole_control => 'false'
      has_weight 10
      setcode do
        Facter.value(:ldom_domainrole_impl)
      end
    end
  end
end
