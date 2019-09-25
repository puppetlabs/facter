# frozen_string_literal: true

describe '' do
  before do
    result = double(WIN32OLE)
    allow(WIN32OLE).to receive(:new).with('WbemScripting.SWbemLocator').and_return(result)
    allow(result).to receive(:ConnectServer).with('.', 'root\\cimv2').and_return(result)
    allow(result).to receive(:Security_).and_return(result)
    allow(result).to receive(:ImpersonationLevel=).and_return(result)
    allow(result).to receive(:execquery).with(query).and_return(query_result)
  end

  context '#return_first returns nil' do
    let(:query) { 'query' }
    let(:query_result) {}
    it '' do
      win = Win32Ole.new
      output = win.return_first(query)
      expect(output).to eq(nil)
    end
  end

  context '#return_first returns a value' do
    let(:query) { 'query' }
    let(:query_result) { ['something'] }
    it '' do
      win = Win32Ole.new
      output = win.return_first(query)
      expect(output).to eq('something')
    end
  end
end
