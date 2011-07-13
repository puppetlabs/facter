class Facter::Util::Cache
  attr_reader :filename

  def data
    if @data.nil?
      self.load()
    end
    @data
  end

  def initialize(filename)
    @filename = filename
  end

  def []=(file, stuff)
    data[file] = {:data => stuff, :stored => Time.now.to_i}
    write!
  end

  def [](file)
    ttl = ttl(file)

    return nil unless data[file]

    now = Time.now.to_i

    return data[file][:data] if ttl < 1
    return data[file][:data] if (now - data[file][:stored]) <= ttl
    return nil
  end

  def ttl(file)
    meta = file + ".ttl"

    return 0 unless File.exist?(meta)
    return File.read(meta).chomp.to_i
  end

  def load
    if File.exist?(filename)
      @data = YAML.load_file(filename)
    else
      @data = {}
    end

    return @data
  end

  def write!
    File.open(filename, "w", 0600) {|f| f.write(YAML.dump(data)) }
  end
end
