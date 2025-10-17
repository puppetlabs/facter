# frozen_string_literal: true

require 'tmpdir'

describe Facter do
  context 'when recursively calling facter in an external/custom fact' do
    ext_dir = Dir.mktmpdir
    ext_fact_path = File.join(ext_dir, 'extfact')

    if LegacyFacter::Util::Config.windows?
      ext_fact_path << '.ps1'
      ext_fact_path.tr!('/', '\\')
      script = <<~SCRIPTEND
        bundle exec facter --external-dir #{ext_dir} os
      SCRIPTEND
    else
      script = <<~POSIXSCRIPT
        #!/usr/bin/env ruby
        require 'json'
        `bundle exec facter --external-dir #{ext_dir} os`.strip
      POSIXSCRIPT
    end
    File.write(ext_fact_path, script)

    FileUtils.chmod('+x', ext_fact_path)
    it 'detects facter invocations recursively and stops external facts from recursing' do
      # in-process entrypoints write to our in-memory logger, not stdout/err
      facter_entrypoints = [
        [proc { `bundle exec facter --external-dir #{ext_dir} os` }, false],
        [proc { Facter.resolve("--external-dir #{ext_dir}") }, true],
        [proc { Facter.resolve("os.family --external-dir #{ext_dir}") }, true],
        [
          proc do
            Facter::OptionStore.external_dir = [ext_dir]
            Facter.to_hash
          end, true
        ]
      ]
      time = Benchmark.measure do
        # This iterates over the supported entry points that would attempt to resolve
        # external facts; if any one of them descends into recursion, it will exceed
        # the DEFAULT_EXECUTION_TIMEOUT; otherwise, each of these calls should be only
        # be a few seconds.
        logger = Facter::Log.class_variable_get(:@@logger)
        facter_entrypoints.each do |entrypoint, inprocess|
          if inprocess
            expect(logger).to receive(:warn).with(/Recursion detected/)
            entrypoint.call
          else
            expect { entrypoint.call }.to output(/Recursion detected/).to_stderr_from_any_process
          end
          Facter.reset
          Facter.clear
          Facter::OptionStore.reset
          LegacyFacter.clear
        end
      end
      expect(time.real).to be < Facter::Core::Execution::Base::DEFAULT_EXECUTION_TIMEOUT
    end
  end

  context 'when calling the ruby API resolve' do
    it 'returns a hash that includes legacy values' do
      result = Facter.resolve('--show-legacy')

      expect(result['uptime_hours']).not_to be_nil
    end

    it "returns a hash that doesn't include legacy values" do
      result = Facter.resolve('')

      expect(result['uptime_hours']).to be_nil
    end

    context 'when calling for specfic legacy fact' do
      it 'returns a hash that includes legacy values' do
        result = Facter.resolve('uptime_hours')

        expect(result['uptime_hours']).not_to be_nil
      end
    end
  end
end
