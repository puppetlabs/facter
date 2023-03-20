# frozen_string_literal: true

require_relative '../facter/framework/cli/cli_launcher'

cli = Facter::Cli.new([])

puts cli.man
