# Fact: ldom
#
# Purpose:
#   Returns a list of dynamic facts that describe the attributes of
#   a Solaris logical domain. The facts returned will include: domainrole,
#   domainname, domainuuid, domaincontrol, and domainchassis.
#
# Resolution:
#   Uses the output of `virtinfo -ap`.
#

if Facter.value(:kernel) == 'SunOS' &&
   Facter.value(:hardwareisa) == 'sparc' &&
   Facter::Core::Execution.which('virtinfo')

  virtinfo = Facter::Core::Execution.exec('virtinfo -ap')

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
        Facter.add("ldom_#{key.downcase}") do
          setcode { value.first.split('=')[1] }
        end
      else
        value.each do |y|
          k = y.split('=')[0]
          v = y.split('=')[1]
          Facter.add("ldom_#{key.downcase}_#{k.downcase}") do
            setcode { v }
          end
        end
      end
    end
  end
end
