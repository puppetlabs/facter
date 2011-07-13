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

require 'facter/util/cache'
require 'facter/util/parser'

class Facter::Util::DirectoryLoader
  require 'yaml'

  SKIP_EXTENSIONS = %w{bak ttl orig}

  attr_reader :directory, :cache

  def cache_file
    @cache.filename
  end

  def initialize(dir="/etc/facter/facts.d", cache_file="/tmp/facts_cache.yml")
    @directory = dir
    @cache = Facter::Util::Cache.new(cache_file)
  end

  def entries
    Dir.entries(directory).find_all{|f| parse?(f) }.sort.map {|f| File.join(directory, f) }
  rescue
    []
  end

  def load
    cache.load
    entries.each do |file|
      unless data = Facter::Util::Parser.new(file, cache).results
        raise "Could not interpret fact file #{file}"
      end

      data.each { |p,v| Facter.add(p, :value => v) }
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
