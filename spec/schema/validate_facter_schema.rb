require 'spec_helper'
require 'facter/util/config'

if !Facter::Util::Config.is_windows?
  require 'json'
  require 'json-schema'

  describe 'facter.json schema' do
    it 'should be valid' do
      # Read in both the json meta-schema and the facter schema
      JSON_META_SCHEMA = JSON.parse(File.read('schema/json-meta-schema.json'))
      FACTER_SCHEMA    = JSON.parse(File.read('schema/facter.json'))

      # Validate that the facter schema itself is valid json
      JSON::Validator.validate!(JSON_META_SCHEMA, FACTER_SCHEMA)
    end
  end
end
