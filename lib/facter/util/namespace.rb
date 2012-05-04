module Facter; module Util; end; end

module Facter::Util::Namespace
  def self.to_namespace(structured_facts)
    facts = {}
    structured_facts.each do |name,structured_data|
      facts.merge! traverse(name, structured_data)
    end
    facts
  end
  
  def self.traverse(prefix, data)
    case data
    when String, Numeric, TrueClass, FalseClass
      { prefix => data }
    when NilClass
      { prefix => :undef }
    when Hash
      result = {}
      data.map {|k,v| traverse(sub_namespace(prefix, k), v)}.flatten.each {|x| result.merge! x}
      result
    when Array
      result = {}
      data.each_with_index { |val,idx| result.merge! traverse(index_namespace(prefix, idx), val)}
      result
    end
  end
  
  def self.sub_namespace(prefix, current)
    prefix.nil? ? current : "#{prefix}::#{current}"
  end
  
  def self.index_namespace(prefix, current)
    prefix.nil? ? "[#{current}]" : "#{prefix}[#{current}]"
  end
end