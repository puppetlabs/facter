#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Util::DirectoryLoader do
  include PuppetlabsSpec::Files

  subject(:dir_loader) { LegacyFacter::Util::DirectoryLoader.new(tmpdir('directory_loader')) }

  let(:collection) { LegacyFacter::Util::Collection.new(double('internal loader'), dir_loader) }
  let(:collection_double) { instance_spy(LegacyFacter::Util::Collection) }

  it 'makes the directory available' do
    expect(dir_loader.directories).to be_instance_of(Array)
  end

  it "does nothing bad when dir doesn't exist" do
    fakepath = '/foobar/path'
    my_loader = LegacyFacter::Util::DirectoryLoader.new(fakepath)
    allow(FileTest).to receive(:exists?).with(my_loader.directories[0]).and_return(false)
    expect { my_loader.load(collection) }.not_to raise_error
  end

  describe 'when loading facts from disk' do
    it 'is able to load files from disk and set facts' do
      data = { 'f1' => 'one', 'f2' => 'two' }
      write_to_file('data.yaml', YAML.dump(data))

      dir_loader.load(collection)

      expect(collection.value('f1')).to eq 'one'
    end

    it 'adds fact with external type to collection' do
      data = { 'f1' => 'one' }
      write_to_file('data.yaml', YAML.dump(data))

      dir_loader.load(collection_double)
      file = File.join(dir_loader.directories[0], 'data.yaml')

      expect(collection_double).to have_received(:add).with('f1', value: 'one', fact_type: :external, file: file)
    end

    it "ignores files that begin with '.'" do
      not_to_be_used_collection = double('collection should not be used')
      expect(not_to_be_used_collection).not_to receive(:add)

      data = { 'f1' => 'one', 'f2' => 'two' }
      write_to_file('.data.yaml', YAML.dump(data))

      dir_loader.load(not_to_be_used_collection)
    end

    %w[bak orig].each do |ext|
      it "ignores files with an extension of '#{ext}'" do
        expect(LegacyFacter).to receive(:warn).with(/#{ext}/)
        write_to_file('data' + ".#{ext}", 'foo=bar')

        dir_loader.load(collection)
      end
    end

    it 'warns when trying to parse unknown file types' do
      write_to_file('file.unknownfiletype', 'stuff=bar')
      expect(LegacyFacter).to receive(:warn).with(/file.unknownfiletype/)

      dir_loader.load(collection)
    end

    it 'external facts should almost always precedence over all other facts' do
      collection.add('f1', value: 'lower_weight_fact') do
        has_weight(LegacyFacter::Util::DirectoryLoader::EXTERNAL_FACT_WEIGHT - 1)
      end

      data = { 'f1' => 'external_fact' }
      write_to_file('data.yaml', YAML.dump(data))

      dir_loader.load(collection)

      expect(collection.value('f1')).to eq 'external_fact'
    end

    describe 'given a custom weight' do
      subject(:dir_loader) { LegacyFacter::Util::DirectoryLoader.new(tmpdir('directory_loader'), 10) }

      it 'sets that weight for loaded external facts' do
        collection.add('f1', value: 'higher_weight_fact') { has_weight(11) }
        data = { 'f1' => 'external_fact' }
        write_to_file('data.yaml', YAML.dump(data))

        dir_loader.load(collection)

        expect(collection.value('f1')).to eq 'higher_weight_fact'
      end
    end
  end

  def write_to_file(file_name, to_write)
    file = File.join(dir_loader.directories[0], file_name)
    File.open(file, 'w') { |f| f.print to_write }
  end
end
