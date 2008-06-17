require 'facter'
require 'facter/util/fact'
require 'facter/util/loader'

# Manage which facts exist and how we access them.  Largely just a wrapper
# around a hash of facts.
class Facter::Util::Collection
    # Return a fact object by name.  If you use this, you still have to call
    # 'value' on it to retrieve the actual value.
    def [](name)
        value(name)
    end

    # Add a resolution mechanism for a named fact.  This does not distinguish
    # between adding a new fact and adding a new way to resolve a fact.
    def add(name, options = {}, &block)
        name = canonize(name)

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

        if block
            resolve = fact.add(&block)
            # Set any resolve-appropriate options
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
        @facts.each do |name, fact|
            value = fact.value
            unless value.nil?
                yield name.to_s, value
            end
        end
    end

    # Return a fact by name.
    def fact(name)
        name = canonize(name)

        loader.load(name) unless @facts[name]

        return @facts[name]
    end

    # Flush all cached values.
    def flush
        @facts.each { |name, fact| fact.flush }
    end

    def initialize
        @facts = Hash.new
    end

    # Return a list of all of the facts.
    def list
        return @facts.keys
    end

    # Load all known facts.
    def load_all
        loader.load_all
    end

    # The thing that loads facts if we don't have them.
    def loader
        unless defined?(@loader)
            @loader = Facter::Util::Loader.new
        end
        @loader
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
        if fact = fact(name)
            fact.value
        end
    end

    private

    # Provide a consistent means of getting the exact same fact name
    # every time.
    def canonize(name)
        name.to_s.downcase.to_sym
    end
end
