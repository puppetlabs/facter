require 'spec_helper'

module FacterSpec::Cpuinfo
  def cpuinfo_fixtures(filename)
    fixtures('cpuinfo', filename)
  end

  def cpuinfo_fixture_read(filename)
    File.read(cpuinfo_fixtures(filename))
  end

  def cpuinfo_fixture_readlines(filename)
    cpuinfo_fixture_read(filename).split(/\n/)
  end
end
