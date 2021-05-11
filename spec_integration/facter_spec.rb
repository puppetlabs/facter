# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Facter' do
  include PuppetlabsSpec::Files

  let(:ext_facts_dir) { tmpdir('external_facts') }
  let(:custom_facts_dir) { tmpdir('custom_facts') }

  def write_to_file(file_name, to_write, dir = ext_facts_dir)
    file = File.join(dir, file_name)
    File.open(file, 'w') { |f| f.print to_write }
  end

  def tmp_filename(tmp_filename)
    "#{(0...8).map { rand(65..90).chr }.join}_#{tmp_filename}"
  end

  describe '.value' do
    context 'with core facts' do
      context 'when facts are structured' do
        it 'does not return wrong values when the query is wrong' do
          expect(Facter.value('os.name.something')).to be(nil)
        end
      end

      context 'when facts have hash values' do
        it 'does not return wrong values when the query is wrong' do
          expect(Facter.value('mountpoints./.available.something')).to be(nil)
        end
      end

      context 'with array as value' do
        it 'can access value by index' do
          expect(Facter.value('processors.models.0')).not_to be_nil
        end

        it 'cannot access non existent index' do
          expect(Facter.value('processors.models.1000')).to be_nil
        end

        it 'does not use non numeric string as index' do
          expect(Facter.value('processors.models.abc')).to be_nil
        end

        it 'does not use non negative index' do
          expect(Facter.value('processors.models.-1')).to be_nil
        end

        it 'respects the filter tokens' do
          expect(Facter.value('processors')['models'][0]).to eql(Facter.value('processors.models.0'))
        end
      end
    end

    context 'with custom facts' do
      context 'with array as value' do
        before do
          Facter.add('arr_fact') do
            setcode { %w[x y z] }
          end
        end

        it 'can access value by index' do
          expect(Facter.value('arr_fact.0')).to eql('x')
        end

        it 'cannot access non existent index' do
          expect(Facter.value('arr_fact.3')).to be_nil
        end

        it 'does not use non numeric string as index' do
          expect(Facter.value('arr_fact.abc')).to be_nil
        end

        it 'does not use non negative index' do
          expect(Facter.value('arr_fact.-1')).to be_nil
        end
      end
    end

    context 'with external facts' do
      context 'with array as value' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'arr_ext_fact' => %w[ex1 ex2] }
          write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
        end

        it 'can access value by index' do
          expect(Facter.value('arr_ext_fact.0')).to eql('ex1')
        end

        it 'cannot access non existent index' do
          expect(Facter.value('arr_ext_fact.3')).to be_nil
        end

        it 'does not use non numeric string as index' do
          expect(Facter.value('arr_ext_fact.abc')).to be_nil
        end

        it 'does not use non negative index' do
          expect(Facter.value('arr_ext_fact.-1')).to be_nil
        end
      end
    end

    context 'when structured facts are disabled' do
      before do
        Facter::Options[:force_dot_resolution] = false
      end

      context 'with custom fact' do
        context 'with nested Facter.value calls' do
          before do
            Facter.search(custom_facts_dir)
            data = <<-RUBY
              Facter.add(:a) do
                setcode { 'a' }
              end

              Facter.value(:kernel)

              Facter.add(:b) do
                setcode { 'b' }
              end
            RUBY
            write_to_file(tmp_filename('custom_fact.rb'), data, custom_facts_dir)
          end

          it 'does not override original user query' do
            expect(Facter.value('b')).to eql('b')
          end
        end

        context 'when has the same name as a structured core fact' do
          before do
            Facter.add('os.name', weight: 999) do
              setcode { 'custom_fact' }
            end
          end

          it 'overrides part of the core fact' do
            expect(Facter.value('os.name')).to eql('custom_fact')
          end

          it 'does not override in the root fact' do
            expect(Facter.value('os')['name']).not_to eql('custom_fact')
          end

          it 'does not override the whole root fact' do
            expect(Facter.value('os')['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.add('os', weight: 999) do
              setcode { 'custom_fact_root' }
            end
          end

          it 'overrides the core fact' do
            expect(Facter.value('os')).to eql('custom_fact_root')
          end
        end

        context 'when standalone fact' do
          before do
            Facter.add('a.b.c') do
              setcode { 'custom' }
            end
          end

          it 'works with fact name' do
            expect(Facter.value('a.b.c')).to eql('custom')
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.value('a.b.c.d')).to be(nil)
          end

          it 'does not work with partial fact name' do
            expect(Facter.value('a.b')).to be(nil)
          end

          it 'does not work with first fact segment' do
            expect(Facter.value('a')).to be(nil)
          end
        end
      end

      context 'with external fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os.name' => 'external_fact' }
            write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
          end

          it 'overrides part of the core fact' do
            expect(Facter.value('os.name')).to eql('external_fact')
          end

          it 'does not override in the root fact' do
            expect(Facter.value('os')['name']).not_to eql('external_fact')
          end

          it 'does not override the whole root fact' do
            expect(Facter.value('os')['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os' => 'external_fact_root' }
            write_to_file(tmp_filename('os_root_fact.yaml'), YAML.dump(data))
          end

          it 'overrides the core fact' do
            expect(Facter.value('os')).to eql('external_fact_root')
          end
        end

        context 'with standalone fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'a.b.c' => 'external' }
            write_to_file(tmp_filename('data.yaml'), YAML.dump(data))
          end

          it 'works with full fact name' do
            expect(Facter.value('a.b.c')).to eql('external')
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.value('a.b.c.d')).to be(nil)
          end

          it 'does not work with partial fact name' do
            expect(Facter.value('a.b')).to be(nil)
          end

          it 'does not work with first fact segment' do
            expect(Facter.value('a')).to be(nil)
          end
        end
      end
    end

    context 'when structured facts are enabled' do
      before do
        Facter::Options[:force_dot_resolution] = true
      end

      after do
        Facter::Options[:force_dot_resolution] = false
      end

      context 'with custom fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.add('os.name', weight: 999) do
              setcode { 'custom_fact' }
            end
          end

          it 'overrides part of the core fact' do
            expect(Facter.value('os.name')).to eql('custom_fact')
          end

          it 'overrides in the root fact' do
            expect(Facter.value('os')['name']).to eql('custom_fact')
          end

          it 'does not override the whole root fact' do
            expect(Facter.value('os')['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.add('os', weight: 999) do
              setcode { 'custom_fact_root' }
            end
          end

          it 'overrides the core fact' do
            expect(Facter.value('os')).to eql('custom_fact_root')
          end
        end

        context 'when standalone fact' do
          let(:fact_name) { 'a.b.c' }

          before do
            Facter.add(fact_name) do
              setcode { 'custom' }
            end
          end

          it 'works with fact name' do
            expect(Facter.value('a.b.c')).to eql('custom')
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.value('a.b.c.d')).to be(nil)
          end

          it 'works with partial fact name' do
            expect(Facter.value('a.b')).to eql({ 'c' => 'custom' })
          end

          it 'works with first fact segment' do
            expect(Facter.value('a')).to eql({ 'b' => { 'c' => 'custom' } })
          end
        end
      end

      context 'with external fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os.name' => 'external_fact' }
            write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
          end

          it 'overrides part of the core fact' do
            expect(Facter.value('os.name')).to eql('external_fact')
          end

          it 'overrides in the root fact' do
            expect(Facter.value('os')['name']).to eql('external_fact')
          end

          it 'does not override the whole root fact' do
            expect(Facter.value('os')['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os' => 'external_fact_root' }
            write_to_file(tmp_filename('os_root_fact.yaml'), YAML.dump(data))
          end

          it 'overrides the core fact' do
            expect(Facter.value('os')).to eql('external_fact_root')
          end
        end

        context 'when standalone fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'a.b.c' => 'external' }
            write_to_file(tmp_filename('data.yaml'), YAML.dump(data))
          end

          it 'works with full fact name' do
            expect(Facter.value('a.b.c')).to eql('external')
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.value('a.b.c.d')).to be(nil)
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
  end

  describe '.to_user_output' do
    context 'with custom facts' do
      context 'with array as value' do
        before do
          Facter.add('arr_fact') do
            setcode { %w[x y z] }
          end
        end

        it 'can access value by index' do
          expect(Facter.to_user_output({}, 'arr_fact.0')).to eql(['x', 0])
        end

        it 'cannot access non existent index' do
          expect(Facter.to_user_output({}, 'arr_fact.3')).to eql(['', 0])
        end

        it 'does not use non numeric string as index' do
          expect(Facter.to_user_output({}, 'arr_fact.abc')).to eql(['', 0])
        end

        it 'does not use non negative index' do
          expect(Facter.to_user_output({}, 'arr_fact.-1')).to eql(['', 0])
        end
      end
    end

    context 'with external facts' do
      context 'with array as value' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'arr_ext_fact' => %w[ex1 ex2] }
          write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
        end

        it 'can access value by index' do
          expect(Facter.to_user_output({}, 'arr_ext_fact.0')).to eql(['ex1', 0])
        end

        it 'cannot access non existent index' do
          expect(Facter.to_user_output({}, 'arr_ext_fact.3')).to eql(['', 0])
        end

        it 'does not use non numeric string as index' do
          expect(Facter.to_user_output({}, 'arr_ext_fact.abc')).to eql(['', 0])
        end

        it 'does not use non negative index' do
          expect(Facter.to_user_output({}, 'arr_ext_fact.-1')).to eql(['', 0])
        end
      end
    end

    context 'when structured facts are disabled' do
      before do
        Facter::Options[:force_dot_resolution] = false
      end

      context 'with custom fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.add('os.name', weight: 999) do
              setcode { 'custom_fact' }
            end
          end

          it 'overrides part of the core fact' do
            expect(Facter.to_user_output({}, 'os.name')).to eql(['custom_fact', 0])
          end

          it 'does not override in the root fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['name']).not_to eql('custom_fact')
          end

          it 'does not override the whole fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.add('os', weight: 999) do
              setcode { 'custom_fact_root' }
            end
          end

          it 'overrides the core fact' do
            expect(Facter.to_user_output({}, 'os')).to eql(['custom_fact_root', 0])
          end
        end

        context 'when standalone fact' do
          let(:fact_name) { 'a.b.c' }

          before do
            Facter.add(fact_name) do
              setcode { 'custom' }
            end
          end

          it 'works with fact name' do
            expect(Facter.to_user_output({}, 'a.b.c')).to eql(['custom', 0])
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.to_user_output({}, 'a.b.c.d')).to eql(['', 0])
          end

          it 'does not work with partial fact name' do
            expect(Facter.to_user_output({}, 'a.b')).to eql(['', 0])
          end

          it 'does not work with first fact segment' do
            expect(Facter.to_user_output({}, 'a')).to eql(['', 0])
          end
        end
      end

      context 'with external fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os.name' => 'external_fact' }
            write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
          end

          it 'overrides part of the core fact' do
            expect(Facter.to_user_output({}, 'os.name')).to eql(['external_fact', 0])
          end

          it 'does not override in the root fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['name']).not_to eql('external_fact')
          end

          it 'does not override the whole fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os' => 'external_fact_root' }
            write_to_file(tmp_filename('os_root_fact.yaml'), YAML.dump(data))
          end

          it 'overrides the core fact' do
            expect(Facter.to_user_output({}, 'os')).to eql(['external_fact_root', 0])
          end
        end

        context 'when standalone fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'a.b.c' => 'external' }
            write_to_file(tmp_filename('data.yaml'), YAML.dump(data))
          end

          it 'works with full fact name' do
            expect(Facter.to_user_output({}, 'a.b.c')).to eql(['external', 0])
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.to_user_output({}, 'a.b.c.d')).to eql(['', 0])
          end

          it 'does not work with partial fact name' do
            expect(Facter.to_user_output({}, 'a.b')).to eql(['', 0])
          end

          it 'does not work with first fact segment' do
            expect(Facter.to_user_output({}, 'a')).to eql(['', 0])
          end
        end
      end
    end

    context 'when structured facts are enabled' do
      before do
        Facter::Options[:force_dot_resolution] = true
      end

      after do
        Facter::Options[:force_dot_resolution] = false
      end

      context 'with custom fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.add('os.name', weight: 999) do
              setcode { 'custom_fact' }
            end
          end

          it 'overrides part of the core fact' do
            expect(Facter.to_user_output({}, 'os.name')).to eql(['custom_fact', 0])
          end

          it 'overrides in the root fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['name']).to eql('custom_fact')
          end

          it 'does not override the whole fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.add('os', weight: 999) do
              setcode { 'custom_fact_root' }
            end
          end

          it 'overrides the core fact' do
            expect(Facter.to_user_output({}, 'os')).to eql(['custom_fact_root', 0])
          end
        end

        context 'when standalone fact' do
          let(:fact_name) { 'a.b.c' }

          before do
            Facter.add(fact_name) do
              setcode { 'custom' }
            end
          end

          it 'works with fact name' do
            expect(Facter.to_user_output({}, 'a.b.c')).to eql(['custom', 0])
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.to_user_output({}, 'a.b.c.d')).to eql(['', 0])
          end

          it 'works with partial fact name' do
            expect(Facter.to_user_output({}, 'a.b')).to eql(["{\n  c => \"custom\"\n}", 0])
          end

          it 'works with first fact segment' do
            expect(Facter.to_user_output({}, 'a')).to eql(["{\n  b => {\n    c => \"custom\"\n  }\n}", 0])
          end
        end
      end

      context 'with external fact' do
        context 'when has the same name as a structured core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os.name' => 'external_fact' }
            write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
          end

          it 'overrides part of the core fact' do
            expect(Facter.to_user_output({}, 'os.name')).to eql(['external_fact', 0])
          end

          it 'overrides in the root fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['name']).to eql('external_fact')
          end

          it 'does not override the whole fact' do
            result = JSON.parse(Facter.to_user_output({ json: true }, 'os')[0])

            expect(result['os']['family']).not_to be(nil)
          end
        end

        context 'when has the same name as a root core fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'os' => 'external_fact_root' }
            write_to_file(tmp_filename('os_root_fact.yaml'), YAML.dump(data))
          end

          it 'overrides the core fact' do
            expect(Facter.to_user_output({}, 'os')).to eql(['external_fact_root', 0])
          end
        end

        context 'when standalone fact' do
          before do
            Facter.search_external([ext_facts_dir])
            data = { 'a.b.c' => 'external' }
            write_to_file(tmp_filename('data.yaml'), YAML.dump(data))
          end

          it 'works with full fact name' do
            expect(Facter.to_user_output({}, 'a.b.c')).to eql(['external', 0])
          end

          it 'does not work with extra token in fact name' do
            expect(Facter.to_user_output({}, 'a.b.c.d')).to eql(['', 0])
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

  describe '.fact' do
    context 'with core facts' do
      context 'when facts are structured' do
        it 'does not return ResolvedFact when the query is wrong' do
          expect(Facter.fact('os.name.something')).to be_nil
        end
      end

      context 'when facts have hash values' do
        it 'does not return ResolvedFact when the query is wrong' do
          expect(Facter.fact('mountpoints./.available.something')).to be_nil
        end
      end

      context 'with array as value' do
        it 'returns a ResolvedFact with value' do
          expect(Facter.fact('processors.models.0')).to be_instance_of(Facter::ResolvedFact)
        end

        it 'cannot access non existent index' do
          expect(Facter.fact('processors.models.1000')).to be_nil
        end

        it 'does not use non numeric string as index' do
          expect(Facter.fact('processors.models.abc')).to be_nil
        end

        it 'does not use non negative index' do
          expect(Facter.fact('processors.models.-1')).to be_nil
        end
      end
    end

    context 'with custom facts' do
      context 'when fact has value' do
        before do
          Facter.add('my_fact') do
            setcode { 'my_value' }
          end
        end

        it 'returns a ResolvedFact with value' do
          expect(Facter.fact('my_fact')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: 'my_value')
        end
      end

      context 'when fact value is nil' do
        before do
          Facter.add('custom1', weight: 999) do
            setcode { nil }
          end
        end

        it 'returns a ResolvedFact with value: nil' do
          expect(Facter.fact('custom1')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: nil)
        end
      end

      context 'with array as value' do
        before do
          Facter.add('arr_fact') do
            setcode { %w[x y z] }
          end
        end

        it 'returns a ResolvedFact with value for an existent index' do
          expect(Facter.fact('arr_fact.0')).to be_instance_of(Facter::ResolvedFact).and have_attributes(value: 'x')
        end

        it 'cannot access non existent index' do
          expect(Facter.fact('arr_fact.3')).to be_nil
        end

        it 'does not use non numeric string as index' do
          expect(Facter.fact('arr_fact.abc')).to be_nil
        end

        it 'does not use non negative index' do
          expect(Facter.fact('arr_fact.-1')).to be_nil
        end
      end
    end

    context 'with external facts' do
      context 'with array as value' do
        before do
          Facter.search_external([ext_facts_dir])
          data = { 'arr_ext_fact' => %w[ex1 ex2] }
          write_to_file(tmp_filename('os_fact.yaml'), YAML.dump(data))
        end

        it 'can access value by index' do
          expect(Facter.fact('arr_ext_fact.0'))
            .to be_instance_of(Facter::ResolvedFact)
            .and have_attributes(value: 'ex1')
        end

        it 'cannot access non existent index' do
          expect(Facter.fact('arr_ext_fact.3')).to be_nil
        end

        it 'does not use non numeric string as index' do
          expect(Facter.fact('arr_ext_fact.abc')).to be_nil
        end

        it 'does not use non negative index' do
          expect(Facter.fact('arr_ext_fact.-1')).to be_nil
        end
      end
    end

    context 'when searching for a fact that does not exists' do
      it 'returns nil' do
        expect(Facter.fact('non_existent')).to be_nil
      end
    end
  end
end
