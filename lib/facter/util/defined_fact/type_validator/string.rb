class Facter::Util::DefinedFact::TypeValidator::String
  def self.valid?(value)
    (! value.nil?) && value.is_a?(String) && (! value.strip.empty?)
  end
end