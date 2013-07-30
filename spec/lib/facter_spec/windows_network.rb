require 'spec_helper'

module FacterSpec::WindowsNetwork

  def settingId0
    '{4AE6B55C-6DD6-427D-A5BB-13535D4BE926}'
  end

  def settingId1
    '{38762816-7957-42AC-8DAA-3B08D0C857C7}'
  end

  def nic_bindings
    ["\\Device\\#{settingId0}", "\\Device\\#{settingId1}" ]
  end

  def macAddress0
    '23:24:df:12:12:00'
  end

  def macAddress1
    '00:0C:29:0C:9E:9F'
  end

  def ipAddress0
    '12.123.12.12'
  end

  def ipAddress1
    '12.123.12.13'
  end

  def subnet0
    '255.255.255.0'
  end

  def subnet1
    '255.255.0.0'
  end

  def ipv6Address0
    '2011:0:4137:9e76:2087:77a:53ef:7527'
  end

  def ipv6Address1
    '2013:0:4137:9e76:2087:77a:53ef:7527'
  end

  def ipv6LinkLocal
    'fe80::2db2:5b42:4e30:b508'
  end

  def given_a_valid_windows_nic_with_ipv4_and_ipv6
    stub('network0', :IPAddress => [ipAddress0, ipv6Address0], :SettingID => settingId0, :IPConnectionMetric => 10,:MACAddress => macAddress0,:IPSubnet => [subnet0, '48','2'])
  end

  def given_two_valid_windows_nics_with_ipv4_and_ipv6
    {
      :nic0 => given_a_valid_windows_nic_with_ipv4_and_ipv6,
      :nic1 => stub('network1', :IPAddress => [ipAddress1, ipv6Address1], :SettingID => settingId1, :IPConnectionMetric => 10,:MACAddress => macAddress1,:IPSubnet => [subnet1, '48','2'])
    }
  end

end
