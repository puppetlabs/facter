# Fact: ec2_<EC2 INSTANCE DATA>
#
# Purpose:
#   Returns info retrieved in bulk from the EC2 API. The names of these facts
#   should be self explanatory, and they are otherwise undocumented. The full
#   list of these facts is: ec2_ami_id, ec2_ami_launch_index,
#   ec2_ami_manifest_path, ec2_block_device_mapping_ami,
#   ec2_block_device_mapping_ephemeral0, ec2_block_device_mapping_root,
#   ec2_hostname, ec2_instance_id, ec2_instance_type, ec2_kernel_id,
#   ec2_local_hostname, ec2_local_ipv4, ec2_placement_availability_zone,
#   ec2_profile, ec2_public_hostname, ec2_public_ipv4,
#   ec2_public_keys_0_openssh_key, ec2_reservation_id, and ec2_security_groups.
#
# Resolution:
#   Directly queries the EC2 metadata endpoint.
#

require 'facter/ec2/rest' unless defined?(Facter::EC2)

Facter.define_fact(:ec2_metadata) do
  define_resolution(:rest) do
    confine do
      Facter.value(:virtual).match /^(xen|kvm)/
    end

    @querier = Facter::EC2::Metadata.new
    confine do
      @querier.reachable?
    end

    setcode do
      @querier.fetch
    end
  end
end

Facter.define_fact(:ec2_userdata) do
  define_resolution(:rest) do
    confine do
      Facter.value(:virtual).match /^(xen|kvm)/
    end

    @querier = Facter::EC2::Userdata.new
    confine do
      @querier.reachable?
    end

    setcode do
      @querier.fetch
    end
  end
end

# The flattened version of the EC2 facts are deprecated and will be removed in
# a future release of Facter.
if (ec2_metadata = Facter.value(:ec2_metadata))
  ec2_facts = Facter::Util::Values.flatten_structure("ec2", ec2_metadata)
  ec2_facts.each_pair do |factname, factvalue|
    Facter.add(factname, :value => factvalue)
  end
end
