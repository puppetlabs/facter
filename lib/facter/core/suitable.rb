require 'facter'

# The Suitable mixin provides mechanisms for confining objects to run on
# certain platforms and determining the run precedence of these objects.
#
# Classes that include the Suitable mixin should define a `#confines` method
# that returns an Array of zero or more Facter::Util::Confine objects.
module Facter::Core::Suitable

  attr_writer :weight

  # Sets the weight of this resolution. If multiple suitable resolutions
  # are found, the one with the highest weight will be used.  If weight
  # is not given, the number of confines set on a resolution will be
  # used as its weight (so that the most specific resolution is used).
  #
  # @param weight [Integer] the weight of this resolution
  #
  # @return [void]
  #
  # @api public
  def has_weight(weight)
    @weight = weight
  end

  # Sets the conditions for this resolution to be used.  This method accepts
  # multiple forms of arguments to determine suitability.
  #
  # @return [void]
  #
  # @api public
  #
  # @overload confine(confines)
  #   Confine a fact to a specific fact value or values.  This form takes a
  #   hash of fact names and values. Every fact must match the values given for
  #   that fact, otherwise this resolution will not be considered suitable. The
  #   values given for a fact can be an array, in which case the value of the
  #   fact must be in the array for it to match.
  #   @param [Hash{String,Symbol=>String,Array<String>}] confines set of facts identified by the hash keys whose
  #     fact value must match the argument value.
  #   @example Confining to Linux
  #       Facter.add(:powerstates) do
  #         # This resolution only makes sense on linux systems
  #         confine :kernel => "Linux"
  #         setcode do
  #           File.read('/sys/power/states')
  #         end
  #       end
  #
  # @overload confine(confines, &block)
  #   Confine a fact to a block with the value of a specified fact yielded to
  #   the block.
  #   @param [String,Symbol] confines the fact name whose value should be
  #     yielded to the block
  #   @param [Proc] block determines the suitability of the fact.  If the block
  #     evaluates to `false` or `nil` then the confined fact will not be
  #     evaluated.
  #   @yield [value] the value of the fact identified by {confines}
  #   @example Confine the fact to a host with an ipaddress in a specific
  #     subnet
  #       confine :ipaddress do |addr|
  #         require 'ipaddr'
  #         IPAddr.new('192.168.0.0/16').include? addr
  #       end
  #
  # @overload confine(&block)
  #   Confine a fact to a block.  The fact will be evaluated only if the block
  #   evaluates to something other than `false` or `nil`.
  #   @param [Proc] block determines the suitability of the fact.  If the block
  #     evaluates to `false` or `nil` then the confined fact will not be
  #     evaluated.
  #   @example Confine the fact to systems with a specific file.
  #       confine { File.exist? '/bin/foo' }
  def confine(confines = nil, &block)
    case confines
    when Hash
      confines.each do |fact, values|
        @confines.push Facter::Util::Confine.new(fact, *values)
      end
    else
      if block
        if confines
          @confines.push Facter::Util::Confine.new(confines, &block)
        else
          @confines.push Facter::Util::Confine.new(&block)
        end
      else
      end
    end
  end

  # Returns the importance of this resolution. If the weight was not
  # given, the number of confines is used instead (so that a more
  # specific resolution wins over a less specific one).
  #
  # @return [Integer] the weight of this resolution
  #
  # @api private
  def weight
    if @weight
      @weight
    else
      @confines.length
    end
  end

  # Is this resolution mechanism suitable on the system in question?
  #
  # @api private
  def suitable?
    @confines.all? { |confine| confine.true? }
  end
end
