# A Facter plugin that loads facts from /etc/facter/facts.d.
#
# Facts can be in the form of JSON, YAML or Text files
# and any executable that returns key=value pairs.

require 'facter/util/parser'

class Facter::Util::DirectoryLoader
  require 'yaml'

  SKIP_EXTENSIONS = %w{bak orig}

  attr_reader :directory

  def initialize(dir="/etc/facter/facts.d")
    @directory = dir
  end

  def entries
    Dir.entries(directory).find_all{|f| parse?(f) }.sort.map {|f| File.join(directory, f) }
  rescue
    []
  end

  def load
    entries.each do |file|
      unless data = Facter::Util::Parser.new(file).results
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
