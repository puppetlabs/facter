require 'facter'

module Facter::Util::Name
  module_function

  # Normalize passed value to a lowercase Symbol suitable for use as a fact
  # name.
  #
  # The usage of Strings or mixed case symbols as fact names is deprecated.
  # This method will generates warning(s) for those cases.
  #
  # @api public
  # @param name [Symbol|String]
  # @return [Symbol]
  def canonicalize_name(name)
    unless name.is_a?(Symbol) || name.is_a?(String)
      raise ArgumentError, "#{name} is not a Symbol or a String"
    end

    unless name.is_a?(Symbol)
      Facter.warn "Fact name #{name} should be a Symbol."
    end

    # Does #downcase cover all unicode cases?
    # note that 1.8.7 does not have Symbol#downcase
    unless name.to_s == name.to_s.downcase
      Facter.warn "Fact name #{name} should be all lowercase."
    end

    name.to_s.downcase.to_sym
  end
end
