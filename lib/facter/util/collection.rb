require 'facter'
require 'facter/util/fact'
require 'facter/util/loader'

# Manage which facts exist and how we access them.  Largely just a wrapper
# around a hash of facts.
class Facter::Util::Collection
  require 'facter/util/name'
  include Facter::Util::Name

  def initialize(internal_loader, external_loader)
    @facts = Hash.new
    @internal_loader = internal_loader
    @external_loader = external_loader
  end

  # Return a fact object by name.  If you use this, you still have to call
  # 'value' on it to retrieve the actual value.
  def [](name)
    name = canonicalize_name(name)
    value(name)
  end

  # Add a resolution mechanism for a named fact.  This does not distinguish
  # between adding a new fact and adding a new way to resolve a fact.
  def add(name, options = {}, &block)
    name = canonicalize_name(name)

    unless fact = @facts[name]
      fact = Facter::Util::Fact.new(name)

      @facts[name] = fact
    end

    # Set any fact-appropriate options.
    options.each do |opt, value|
      method = opt.to_s + "="
      if fact.respond_to?(method)
        fact.send(method, value)
        options.delete(opt)
      end
    end

    if block_given?
      resolve = fact.add(&block)
    else
      resolve = fact.add
    end

    # Set any resolve-appropriate options
    if resolve
      # If the resolve was actually added, set any resolve-appropriate options
      options.each do |opt, value|
        method = opt.to_s + "="
        if resolve.respond_to?(method)
          resolve.send(method, value)
          options.delete(opt)
        end
      end
    end

    unless options.empty?
      raise ArgumentError, "Invalid facter option(s) %s" % options.keys.collect { |k| k.to_s }.join(",")
    end

    return fact
  end

  include Enumerable

  # Iterate across all of the facts.
  def each
    load_all
    @facts.each do |name, fact|
      value = fact.value
      unless value.nil?
        yield name.to_s, value
      end
    end
  end

  # Return a fact by name.
  def fact(name)
    name = canonicalize_name(name)

    # Try to load the fact if necessary
    load(name) unless @facts[name]

    # Try HARDER
    internal_loader.load_all unless @facts[name]

    if @facts.empty?
      Facter.warnonce("No facts loaded from #{internal_loader.search_path.join(File::PATH_SEPARATOR)}")
    end

    @facts[name]
  end

  # Flush all cached values.
  def flush
    @facts.each { |name, fact| fact.flush }
    @external_facts_loaded = nil
  end

  # Return a list of all of the facts.
  def list
    load_all
    return @facts.keys
  end

  def load(name)
    name = canonicalize_name(name)
    internal_loader.load(name)
    load_external_facts
  end

  # Load all known facts.
  def load_all
    internal_loader.load_all
    load_external_facts
  end

  def internal_loader
    @internal_loader
  end

  def external_loader
    @external_loader
  end

  # Return a hash of all of our facts.
  def to_hash
    @facts.inject({}) do |h, ary|
      value = ary[1].value
      if ! value.nil?
        # For backwards compatibility, convert the fact name to a string.
        h[ary[0].to_s] = value
      end
      h
    end
  end

  def value(name)
    name = canonicalize_name(name)
    if fact = fact(name)
      fact.value
    end
  end

  private

  def load_external_facts
    if ! @external_facts_loaded
      @external_facts_loaded = true
      external_loader.load(self)
    end
  end
end
