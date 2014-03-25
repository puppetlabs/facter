require 'facter/util/resolution'

module Facter
module Util
  ##
  # Provide a set of utility methods to interact with Solaris zones.  This class
  # is expected to be instantiated once per set of resolutions in order to
  # cache the output of the zoneadm command, which can be quite expensive.
  #
  # @api private
  class SolarisZones
    attr_reader :zone_hash
    attr_reader :zoneadm_cmd
    attr_reader :zoneadm_output
    attr_reader :zoneadm_keys

    ##
    # add_facts defines all of the facts for solaris zones, for example `zones`,
    # `zone_global_id`, `zone_global_status`, etc...  This method defines the
    # static fact named `zones`.  The value of this fact is the numver of zones
    # reported by the zoneadm system command.  The `zones` fact also defines
    # all of the dynamic facts describing the following seven attribute values
    # for each zone.
    #
    # Zones may be added to the system while Facter is loaded.  In order to
    # define new dynamic facts that reflect this new information, the `virtual`
    # will define new facts as a side effect of refreshing it's own value.
    #
    # @api private
    def self.add_facts
      model = new
      model.refresh
      model.add_dynamic_facts
      Facter.add("zones") do
        setcode do
          model.refresh if model.flushed?
          model.add_dynamic_facts
          model.count
        end
        on_flush do
          model.flush!
        end
      end
    end

    ##
    # @param [Hash] opts the options to create the instance with
    # @option opts [String] :zoneadm_cmd ('/usr/sbin/zoneadm list -cp') the
    #   system command to inspect zones
    # @option opts [String] :zoneadm_output (nil) the cached output of the
    #   zoneadm_cmd
    def initialize(opts = {})
      @zoneadm_keys = [:id, :name, :status, :path, :uuid, :brand, :iptype]
      @zoneadm_cmd = opts[:zoneadm_cmd] || '/usr/sbin/zoneadm list -cp'
      if opts[:zoneadm_output]
        @zoneadm_output = opts[:zoneadm_output]
      end
    end

    ##
    # add_dynamic_facts defines all of the dynamic facts derived from parsing
    # the output of the zoneadm command.  The zone facts are dynamic, so this
    # method has the behavior of figuring out what dynamic zone facts need to
    # be defined and how they should be resolved.
    #
    # @param model [SolarisZones] the model used to store data from the system
    #
    # @api private
    def add_dynamic_facts
      model = self
      zone_hash.each_pair do |zone, attr_hsh|
        attr_hsh.keys.each do |attr|
          Facter.add("zone_#{zone}_#{attr}") do
            setcode do
              model.refresh if model.flushed?
              # Don't resolve if the zone has since been deleted
              if zone_hsh = model.zone_hash[zone]
                zone_hsh[attr] # the value
              end
            end
            on_flush do
              model.flush!
            end
          end
        end
      end
    end

    ##
    # refresh executes the zoneadm_cmd and stores the output data.
    #
    # @api private
    #
    # @return [Hash] the parsed output of the zoneadm command
    def refresh
      @zoneadm_output = Facter::Core::Execution.execute(zoneadm_cmd, {:on_fail => nil})
      parse!
    end

    ##
    # parse! parses the string stored in {@zoneadm_output} and stores the
    # resulting Hash data structure in {@zone_hash}
    #
    # @api private
    def parse!
      if @zoneadm_output
        rows = @zoneadm_output.split("\n").collect { |line| line.split(':') }
      else
        Facter.debug "Cannot parse zone facts, #{zoneadm_cmd} returned no output"
        rows = []
      end

      @zone_hash = rows.inject({}) do |memo, fields|
        zone = fields[1].intern
        # Transform the row into a hash with keys named by the column names
        memo[zone] = Hash[*@zoneadm_keys.zip(fields).flatten]
        memo
      end
    end
    private :parse!

    ##
    # count returns the number of running zones, including the global zone.
    # This method is intended to be used from the setcode block of the `zones`
    # fact.
    #
    # @api private
    #
    # @return [Fixnum, nil] the number of running zones or nil if the number
    #   could not be determined.
    def count
      if @zone_hash
        @zone_hash.size
      end
    end

    ##
    # flush! purges the saved data from the zoneadm_cmd output
    #
    # @api private
    def flush!
      @zoneadm_output = nil
      @zone_hash = nil
    end

    ##
    # flushed? returns true if the instance has no parsed data accessible via
    # the {zone_hash} method.
    #
    # @api private
    #
    # @return [Boolean] true if there is no parsed data, false otherwise
    def flushed?
      !@zone_hash
    end
  end
end
end
