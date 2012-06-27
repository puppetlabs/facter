# What we're after is a way to define a fact separate from the data returned by its resolution

# Desired usage:
# Facter.add(:factname) do
#   definition
#     :type => [:boolean|:numeric|:string|:array|:hash],
#     :description => "Here's all about my awesome fact",
#   end
# end
# 
# Facter.resolves(:factname) do
#   setcode do
#     ...
#   end
# end

module Facter::Util::Definition
  def definition(options = {})
    type = options[:type]
    raise ArgumentError, "Fact type #{type} is not valid. Must be one of [#{valid_fact_types.join(', ')}]" unless valid_fact_type? type
    description = options[:description]
    raise ArgumentError, "Fact must have a description" unless description && description.length > 0
    
  end
  
  def valid_fact_types
    [:string, :boolean]
  end
  
  def valid_fact_type?(type)
    valid_fact_type.include? type.to_sym
  end
end