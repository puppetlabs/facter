# frozen_string_literal: true

require 'mkmf'

extension_name = 'cpuid'
dir_config(extension_name)
create_makefile(extension_name)
