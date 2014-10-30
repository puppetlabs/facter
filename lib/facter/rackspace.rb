# Fact: rsc_<RACKSPACE INSTANCE DATA>
#
# Purpose: Determine information about Rackspace cloud instances.
#
# Resolution:
#   If this is a Rackspace Cloud instance, populates `rsc_` facts: `is_rsc`, `rsc_region`,
#   and `rsc_instance_id`.
#
# Caveats:
#   Depends on Xenstore.
#

Facter.add(:is_rsc) do
  setcode do
    result = Facter::Util::Resolution.exec("/usr/bin/xenstore-read vm-data/provider_data/provider 2> /dev/null")
    if result == "Rackspace"
      "true"
    end
  end
end

Facter.add(:rsc_region) do
  confine :is_rsc => "true"
  setcode do
    Facter::Util::Resolution.exec("/usr/bin/xenstore-read vm-data/provider_data/region 2> /dev/null")
  end
end

Facter.add(:rsc_instance_id) do
  confine :is_rsc => "true"
  setcode do
    result = Facter::Util::Resolution.exec("/usr/bin/xenstore-read name")
    if result and (match = result.match(/instance-(.*)/))
      match[1]
    end
  end
end
