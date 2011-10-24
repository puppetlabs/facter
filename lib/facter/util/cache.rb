# This class provides a fact cache mechanism.
#
# The storage mechanism is file based using Ruby Marshal format for serialization.
class Facter::Util::Cache

  @@data = nil

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
    cache_file = Facter::Util::Config.cache_file
    if File.exist?(cache_file) and File.readable?(cache_file)
      begin
        File.open(cache_file) do |file|
          @@data = Marshal.load(file)
        end
      rescue TypeError => e
        Facter.warn("cache file content is invalid so returning empty set: " + e.message)
        @@data = {}
      end
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
    cache_file = Facter::Util::Config.cache_file
    if (File.exists?(cache_file) and File.writable?(cache_file)) or
      (!File.exists?(cache_file) and File.writable?(File.dirname(cache_file))) then
      File.open(cache_file, "w", 0600) {|f| f.write(Marshal.dump(@@data)) }
    end
  end
end
