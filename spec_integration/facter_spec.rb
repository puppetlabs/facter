# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../spec/spec_helper_legacy'

describe 'Facter' do
  include PuppetlabsSpec::Files

  let(:ext_facts_dir) { tmpdir('external_facts') }

  def write_to_file(file_name, to_write)
    file = File.join(ext_facts_dir, file_name)
    File.open(file, 'w') { |f| f.print to_write }
  end

  describe '.value' do
    context 'when structured facts are disabled' do
      context 'with custom fact' do
        let(:fact_name) { 'a.b.c' }

        before do
          Facter::Options[:autopromote_dotted_facts] = false

          Facter.add(fact_name) do
            setcode { 'custom' }
          end
        end

        it 'works with fact name' do
          expect(Facter.value('a.b.c')).to eql('custom')
        end

        it 'does not work with partial fact name' do
          expect(Facter.value('a.b')).to be(nil)
        end

        it 'does not work with first fact segment' do
          expect(Facter.value('a')).to be(nil)
        end
      end

      context 'with external fact' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'a.b.c' => 'external' }
          write_to_file('data.yaml', YAML.dump(data))
        end

        it 'works with full fact name' do
          expect(Facter.value('a.b.c')).to eql('external')
        end

        it 'does not work with partial fact name' do
          expect(Facter.value('a.b')).to be(nil)
        end

        it 'does not work with first fact segment' do
          expect(Facter.value('a')).to be(nil)
        end
      end
    end

    context 'when structured facts are enabled' do
      before do
        Facter::Options[:autopromote_dotted_facts] = true
      end

      after do
        Facter::Options[:autopromote_dotted_facts] = false
      end

      context 'with custom fact' do
        let(:fact_name) { 'a.b.c' }

        before do
          Facter.add(fact_name) do
            setcode { 'custom' }
          end
        end

        it 'works with fact name' do
          expect(Facter.value('a.b.c')).to eql('custom')
        end

        it 'works with partial fact name' do
          expect(Facter.value('a.b')).to eql({ 'c' => 'custom' })
        end

        it 'works with first fact segment' do
          expect(Facter.value('a')).to eql({ 'b' => { 'c' => 'custom' } })
        end
      end

      context 'with external fact' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'a.b.c' => 'external' }
          write_to_file('data.yaml', YAML.dump(data))
        end

        it 'works with full fact name' do
          expect(Facter.value('a.b.c')).to eql('external')
        end

        it 'works with partial fact name' do
          expect(Facter.value('a.b')).to eql({ 'c' => 'external' })
        end

        it 'works with first fact segment' do
          expect(Facter.value('a')).to eql({ 'b' => { 'c' => 'external' } })
        end
      end
    end
  end

  describe '.to_user_output' do
    context 'when structured facts are disabled' do
      context 'with custom fact' do
        let(:fact_name) { 'a.b.c' }

        before do
          Facter::Options[:autopromote_dotted_facts] = false

          Facter.add(fact_name) do
            setcode { 'custom' }
          end
        end

        it 'works with fact name' do
          expect(Facter.to_user_output({}, 'a.b.c')).to eql(['custom', 0])
        end

        it 'does not work with partial fact name' do
          expect(Facter.to_user_output({}, 'a.b')).to eql(['', 0])
        end

        it 'does not work with first fact segment' do
          expect(Facter.to_user_output({}, 'a')).to eql(['', 0])
        end
      end

      context 'with external fact' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'a.b.c' => 'external' }
          write_to_file('data.yaml', YAML.dump(data))
        end

        it 'works with full fact name' do
          expect(Facter.to_user_output({}, 'a.b.c')).to eql(['external', 0])
        end

        it 'does not work with partial fact name' do
          expect(Facter.to_user_output({}, 'a.b')).to eql(['', 0])
        end

        it 'does not work with first fact segment' do
          expect(Facter.to_user_output({}, 'a')).to eql(['', 0])
        end
      end
    end

    context 'when structured facts are enabled' do
      before do
        Facter::Options[:autopromote_dotted_facts] = true
      end

      after do
        Facter::Options[:autopromote_dotted_facts] = false
      end

      context 'with custom fact' do
        let(:fact_name) { 'a.b.c' }

        before do
          Facter.add(fact_name) do
            setcode { 'custom' }
          end
        end

        it 'works with fact name' do
          expect(Facter.to_user_output({}, 'a.b.c')).to eql(['custom', 0])
        end

        it 'works with partial fact name' do
          expect(Facter.to_user_output({}, 'a.b')).to eql(["{\n  c => \"custom\"\n}", 0])
        end

        it 'works with first fact segment' do
          expect(Facter.to_user_output({}, 'a')).to eql(["{\n  b => {\n    c => \"custom\"\n  }\n}", 0])
        end
      end

      context 'with external fact' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'a.b.c' => 'external' }
          write_to_file('data.yaml', YAML.dump(data))
        end

        it 'works with full fact name' do
          expect(Facter.to_user_output({}, 'a.b.c')).to eql(['external', 0])
        end

        it 'works with partial fact name' do
          expect(Facter.to_user_output({}, 'a.b')).to eql(["{\n  c => \"external\"\n}", 0])
        end

        it 'works with first fact segment' do
          expect(Facter.to_user_output({}, 'a')).to eql(["{\n  b => {\n    c => \"external\"\n  }\n}", 0])
        end
      end
    end
  end
end
