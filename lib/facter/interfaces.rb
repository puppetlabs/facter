# encoding: UTF-8

# Fact: interfaces
#
# Purpose:
# Try to get facts about the machine's network interfaces

require 'facter/util/ip'

Facter::Util::IP.add_interface_facts
