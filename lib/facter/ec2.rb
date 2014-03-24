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
