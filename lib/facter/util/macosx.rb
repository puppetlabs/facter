## macosx.rb
## Support methods for Apple OSX facts
##
## Copyright (C) 2007 Jeff McCune
## Author: Jeff McCune <jeff.mccune@northstarlabs.net>
##

module Facter::Util::Macosx
  require 'cfpropertylist'
  require 'facter/util/resolution'

  Plist_Xml_Doctype  = '<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'

  # JJM I'd really like to dynamically generate these methods
  # by looking at the _name key of the _items dict for each _dataType

  def self.profiler_xml(data_field)
    Facter::Core::Execution.exec("/usr/sbin/system_profiler -xml #{data_field} 2>/dev/null")
  end

  def self.intern_xml(xml)
    return nil unless xml
    bad_xml_doctype = /^.*<!DOCTYPE plist PUBLIC -\/\/Apple Computer.*$/
    if xml =~ bad_xml_doctype
      xml.gsub!( bad_xml_doctype, Plist_Xml_Doctype )
      Facter.debug("Had to fix plist with incorrect DOCTYPE declaration")
    end
    plist = CFPropertyList::List.new
    begin
      plist.load_str(xml)
    rescue CFFormatError => e
      raise RuntimeError, "A plist file could not be properly read by CFPropertyList: #{e.message}", e.backtrace
    end
    CFPropertyList.native_types(plist.value)
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
      ver["macosx_#{option}"] = Facter::Core::Execution.exec("/usr/bin/sw_vers -#{option}").strip
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
