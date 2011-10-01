## macosx.rb
## Support methods for Apple OSX facts
##
## Copyright (C) 2007 Jeff McCune
## Author: Jeff McCune <jeff.mccune@northstarlabs.net>
##

module Facter::Util::Macosx
  require 'thread'
  require 'facter/util/plist'
  require 'facter/util/resolution'

  # JJM I'd really like to dynamically generate these methods
  # by looking at the _name key of the _items dict for each _dataType

  def self.profiler_xml(data_field)
    Facter::Util::Resolution.exec("/usr/sbin/system_profiler -xml #{data_field}")
  end

  def self.intern_xml(xml)
    return nil unless xml
    Plist::parse_xml(xml)
  end

  # Return an xml result, modified as we need it.
  def self.profiler_data(data_field)
    begin
      return nil unless parsed_xml = intern_xml(profiler_xml(data_field))
      return nil unless data = parsed_xml[0]['_items'][0]
      data.delete '_name'
      data
    rescue
      return nil
    end
  end

  def self.hardware_overview
    profiler_data("SPHardwareDataType")
  end

  def self.os_overview
    profiler_data("SPSoftwareDataType")
  end

  def self.sw_vers
    ver = Hash.new
    [ "productName", "productVersion", "buildVersion" ].each do |option|
      ver["macosx_#{option}"] = Facter::Util::Resolution.exec("/usr/bin/sw_vers -#{option}").strip
    end
    productversion = ver["macosx_productVersion"]
    if not productversion.nil?
      versions = productversion.scan(/(\d+)\.(\d+)\.*(\d*)/)[0]
      ver["macosx_productversion_major"] = "#{versions[0]}.#{versions[1]}"
      if versions[2].empty?  # 10.x should be treated as 10.x.0
        versions[2] = "0"
      end
      ver["macosx_productversion_minor"] = versions[2]
    end
    ver
  end
end
