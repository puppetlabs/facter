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

  # Sets the conditions for this resolution to be used. This takes a
  # hash of fact names and values. Every fact must match the values
  # given for that fact, otherwise this resolution will not be
  # considered suitable. The values given for a fact can be an array, in
  # which case the value of the fact must be in the array for it to
  # match.
  #
  # @param confines [Hash{String => Object}] a hash of facts and the
  #   values they should have in order for this resolution to be
  #   used
  #
  # @example Confining to Linux
  #     Facter.add(:powerstates) do
  #       # This resolution only makes sense on linux systems
  #       confine :kernel => "Linux"
  #       setcode do
  #         Facter::Util::Resolution.exec('cat /sys/power/states')
  #       end
  #     end
  #
  # @return [void]
  #
  # @api public
  def confine(confines)
    confines.each do |fact, values|
      @confines.push Facter::Util::Confine.new(fact, *values)
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
    unless defined? @suitable
      @suitable = ! @confines.detect { |confine| ! confine.true? }
    end

    return @suitable
  end
end
