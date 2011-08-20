# This class provides a fact cache mechanism.
#
# The storage mechanism is file based using a YAML format for serialization.
class Facter::Util::Cache
  # Filename location of cache file.
  attr_reader :filename

  # Return a hash of all cached data keyed by filename. A lazy load will occur
  # if the file has not been loaded earlier.
  def data
    if @data.nil?
      self.load()
    end
    @data
  end

  # Initialize Facter::Util::Cache.
  def initialize(filename)
    @filename = filename
  end

  # Stores cache keyed by the source file.
  def []=(file, stuff)
    data[file] = {:data => stuff, :stored => Time.now.to_i}
    write!
  end

  # Returns the cached items for a particular file.
  def [](file)
    ttl = ttl(file)

    return nil unless data[file]

    now = Time.now.to_i

    return data[file][:data] if ttl < 1
    return data[file][:data] if (now - data[file][:stored]) <= ttl
    return nil
  end

  # Returns the cache ttl for a particular file.
  def ttl(file)
    meta = file + ".ttl"

    return 0 unless File.exist?(meta)
    return File.read(meta).chomp.to_i
  end

  # Load the cache from its file.
  def load
    if File.exist?(filename)
      @data = YAML.load_file(filename)
    else
      @data = {}
    end

    return @data
  end

  # Writes cache to the cache file.
  def write!
    File.open(filename, "w", 0600) {|f| f.write(YAML.dump(data)) }
  end
end
