require 'facter/gce/metadata'

Facter.define_fact(:gce) do
  define_resolution(:rest) do
    confine :virtual => 'gce'

    confine do
      Facter.json?
    end

    setcode do
      querier = Facter::GCE::Metadata.new
      querier.fetch
    end
  end
end
