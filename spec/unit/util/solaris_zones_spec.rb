require 'spec_helper'
require 'facter/util/solaris_zones'

describe Facter::Util::SolarisZones do
  let :zone_list do
    zone_list = <<-EOF
0:global:running:/::native:shared
-:local:configured:/::native:shared
-:zoneA:stopped:/::native:shared
    EOF
  end

  let :zone_list2 do
    zone_list = <<-EOF
0:global:running:/::native:shared
-:local:configured:/::native:shared
-:zoneB:stopped:/::native:shared
-:zoneC:stopped:/::native:shared
    EOF
  end

  subject do
    described_class.new(:zoneadm_output => zone_list)
  end

  describe '.add_facts' do
    before :each do
      zones = described_class.new(:zoneadm_output => zone_list)
      zones.send(:parse!)
      zones.stubs(:refresh)
      described_class.stubs(:new).returns(zones)
    end

    it 'defines the zones fact' do
      described_class.add_facts
      Facter.fact(:zones).value.should == 3
    end

    it 'defines a fact for each attribute of a zone' do
      described_class.add_facts
      [:id, :name, :status, :path, :uuid, :brand, :iptype].each do |attr|
        Facter.fact("zone_local_#{attr}".intern).
          should be_a_kind_of Facter::Util::Fact
      end
    end
  end

  describe '#refresh' do
    it 'executes the zoneadm_cmd' do
      Facter::Core::Execution.expects(:execute).with(subject.zoneadm_cmd, {:on_fail => nil}).returns(zone_list)
      subject.refresh
    end
  end

  describe 'multiple facts sharing a single model' do
    context 'when zones is resolved for the first time' do
      it 'counts the number of zones' do
        given_initial_zone_facts
        Facter.fact(:zones).value.should == 3
      end
      it 'defines facts for zoneA' do
        given_initial_zone_facts
        Facter.fact(:zone_zoneA_id).value.should == '-'
      end
      it 'does not define facts for zoneB' do
        given_initial_zone_facts
        Facter.fact(:zone_zoneB_id).should be_nil
      end
      it 'uses a single read of the system information for all of the dynamically generated zone facts' do
        given_initial_zone_facts # <= single read happens here

        Facter::Core::Execution.expects(:execute).never
        Facter.fact(:zone_zoneA_id).value
        Facter.fact(:zone_local_id).value
      end
    end
    context 'when all facts have been flushed after zones was resolved once' do
      it 'updates the number of zones' do
        given_initial_zone_facts
        when_facts_have_been_resolved_then_flushed

        Facter.fact(:zones).value.should == 4
      end
      it 'stops resolving a value for a zone that no longer exists' do
        given_initial_zone_facts
        when_facts_have_been_resolved_then_flushed

        Facter.fact(:zone_zoneA_id).value.should be_nil
        Facter.fact(:zone_zoneA_status).value.should be_nil
        Facter.fact(:zone_zoneA_path).value.should be_nil
      end
      it 'defines facts for new zones' do
        given_initial_zone_facts
        when_facts_have_been_resolved_then_flushed

        Facter.fact(:zone_zoneB_id).should be_nil
        Facter.fact(:zones).value
        Facter.fact(:zone_zoneB_id).value.should be_a_kind_of String
      end
      it 'uses a single read of the system information for all of the dynamically generated zone facts' do
        given_initial_zone_facts
        when_facts_have_been_resolved_then_flushed

        Facter::Core::Execution.expects(:execute).once.returns(zone_list2)
        Facter.fact(:zones).value
        Facter.fact(:zone_zoneA_id).value
        Facter.fact(:zone_local_id).value
      end

    end
  end

  def given_initial_zone_facts
    Facter::Core::Execution.stubs(:execute).
      with(subject.zoneadm_cmd, {:on_fail => nil}).
      returns(zone_list)
    described_class.add_facts
  end

  def when_facts_have_been_resolved_then_flushed
    Facter.fact(:zones).value
    Facter.fact(:zone_zoneA_id).value
    Facter.fact(:zone_local_id).value
    Facter::Core::Execution.stubs(:execute).returns(zone_list2)
    Facter.flush
  end
end
