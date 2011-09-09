require 'facter/util/parser'

# A Facter plugin that loads facts from /etc/facter/facts.d.
#
# Facts can be in the form of JSON, YAML or Text files
# and any executable that returns key=value pairs.
#
# In the case of scripts you can also create a file that
# contains a cache TTL.  For foo.sh store the ttl as just
# a number in foo.sh.ttl
#
# The cache is stored in /tmp/facts_cache.yaml as a mode
# 600 file and will have the end result of not calling your
# fact scripts more often than is needed.  The cache is only
# used for executable facts, not plain data.
class Facter::Util::DirectoryLoader
  require 'yaml'

  # A list of extensions to ignore in fact directory.
  SKIP_EXTENSIONS = %w{bak ttl orig}

  # Directory for fact loading
  attr_reader :directory

  # Initialize Facter::Util::DirectoryLoader.
  # 
  # Allows you to specify the directory to use and cache file for cacheable
  # content.
  def initialize(dir = nil)
    @directory = dir || Facter::Util::Config.ext_fact_dir
  end

  # Return all relevant directory based fact file names.
  def entries
    Dir.entries(directory).find_all{|f| parse?(f) }.sort.map {|f| File.join(directory, f) }
  rescue
    []
  end

  # Load facts from files in fact directory using the relevant parser classes to 
  # parse them.
  def load
    entries.each do |file|
      parser = Facter::Util::Parser.new(file)
      if parser == nil
        next
      end

      data = parser.values
      if data == false
        Facter.warn "Could not interpret fact file #{file}"
      elsif data == {} or data == nil
        Facter.warn "Fact file #{file} was parsed but returned an empty data set"
      else
        data.each { |p,v| Facter.add(p, :value => v) }
      end
    end
  end

  private

  def parse?(file)
    return false if file =~ /^\./
    ext = file.split(".")[-1]
    return false if SKIP_EXTENSIONS.include?(ext)
    true
  end
end
