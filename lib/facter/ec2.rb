require 'facter/util/ec2'

Facter.define_fact(:ec2_metadata) do
  define_resolution(:rest) do
    confine do
      Facter.value(:virtual).match /^xen/
    end

    confine do
      Facter::Util::EC2.uri_reachable?("http://169.254.169.254/latest/meta-data/")
    end

    setcode do
      metadata_uri = "http://169.254.169.254/latest/meta-data/"
      Facter::Util::EC2.recursive_fetch(metadata_uri)
    end
  end
end

Facter.define_fact(:ec2_userdata) do
  define_resolution(:rest) do
    confine do
      Facter.value(:virtual).match /^xen/
    end

    confine do
      Facter::Util::EC2.uri_reachable?("http://169.254.169.254/latest/user-data/")
    end

    setcode do
      userdata_uri = "http://169.254.169.254/latest/user-data/"
      output = Facter::Util::EC2.fetch(userdata_uri)
      output.join("\n")
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
