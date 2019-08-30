# frozen_string_literal: true

require 'pry-byebug'
require_relative '../../../../lib/resolvers/windows/windows_utils/uptime'

describe 'Windows UptimeResolver' do
  context '#resolve' do
    it 'should resolve uptime' do
      binding.pry
      # uptime = class_double(Uptime)
      # allow(Uptime).to receive(:ffi_convention)
      # allow(Uptime).to receive(:ffi_lib)
      # allow(Uptime).to receive(:attach_function)
      # allow(Uptime).to receive(:GetTickCount64).and_return(8_927_357_268)
      expect(UptimeResolver.resolve(:system_uptime)).to eql('VMware, Inc.')
    end
  end
end
