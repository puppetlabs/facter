# This class provides a fact cache mechanism.
#
# The storage mechanism is file based using a YAML format for serialization.
class Facter::Util::Cache

  @@data = nil
  @@filename = "/tmp/facts_cache.yml"

  class << self
    # Cache filename
    attr_accessor :filename
  end

  # Return the cache file name
  def self.filename
    @@filename
  end

  # Set the cache file name
  def self.filename=(new_file)
    @@filename = new_file
  end

  # Return a hash of all cached data keyed by filename. A lazy load will occur
  # if the file has not been loaded earlier.
  def self.all
    if @@data.nil?
      load
    end
    @@data
  end

  # Stores cache based on key
  def self.set(key, value, ttl = nil)
    if @@data.nil?
      load
    end
    if ttl and (ttl > 0 or ttl == -1) then
      @@data[key] = {:data => value, :stored => Time.now.to_i, :ttl => ttl}
      write!
    end
  end

  # Returns the cached items for a particular file.
  def self.get(key, ttl = nil)
    if @@data.nil?
      load
    end

    # If TTL -1 - always return cache
    return @@data[key][:data] if ttl == -1
    return @@data[key][:data] if ttl == -1

    raise "TTL zero" unless ttl > 0
    raise "No entry" unless @@data[key]

    now = Time.now.to_i
    return @@data[key][:data] if (now - @@data[key][:stored]) <= ttl

    raise "Expired cache entry"
  rescue Exception => e
    Facter.debug("no cache for #{key}: " + e.message)
    raise(e)
  end

  # Load the cache from its file.
  def self.load
    if File.exist?(filename)
      @@data = YAML.load_file(filename)
      # If the file was empty, return {}
      @@data = {} if @@data == false
    else
      @@data = {}
    end

    return @@data
  end

  # Writes cache to the cache file.
  def self.write!
    if @@data.nil?
      load
    end
    File.open(filename, "w", 0600) {|f| f.write(YAML.dump(@@data)) }
  end
end
