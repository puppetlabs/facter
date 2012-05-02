require 'facter/util/defined_fact/type_validator'
class Facter::Util::DefinedFact
  attr_reader :name, :type, :description
  def initialize(name, type, description, other_options = {})
    raise ArgumentError, "defined fact name must be valid" unless valid_fact_name? name
    raise ArgumentError, "defined fact type must be valid" unless valid_fact_type? type
    raise ArgumentError, "defined fact description must be valid" unless valid_fact_description? description
    @name = name
    @type = type
    @description = description
    other_options.each do |key, value|
      send("#{key}=".to_sym, value)
    end
  end
    
  def structured?
    case type
    when :string, :boolean, :numeric
      false
    else
      true
    end
  end
  
  def resolved?
    @resolved
  end
  
  def reset
    @value = nil
    @resolved = false
  end
  
  def value
    return :undef unless resolved?
    @value
  end
  
  def value=(val)
    raise ArgumentError, "Invalid setting for DefinedFact[#{name}]" unless Facter::Util::DefinedFact::TypeValidator.valid?(type, val)
    @resolved = true
    @value = val
  end
      
  def valid_fact_name?(name)
    default_string_valid? name
  end
  private :valid_fact_name?
  
  def valid_fact_type?(type)
    [:string, :numeric, :boolean, :hash, :array].include? type
  end
  private :valid_fact_type?
  
  def valid_fact_description?(desc)
    default_string_valid? desc
  end
  private :valid_fact_description?
  
  def default_string_valid?(str)
    str && str.strip.length > 0
  end
  private :default_string_valid?
  
end