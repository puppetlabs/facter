require 'facter/ec2/rest'

Facter.define_fact(:ec2_metadata) do
  define_resolution(:rest) do
    confine do
      Facter.value(:virtual).match /^xen/
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
      Facter.value(:virtual).match /^xen/
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
