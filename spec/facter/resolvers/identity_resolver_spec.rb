# frozen_string_literal: true

require 'ostruct'

describe Facter::Resolvers::PosxIdentity do
  before do
    allow(Etc).to receive(:getpwuid)
      .and_return(OpenStruct.new(name: 'test1.test2',
                                 passwd: '********',
                                 uid: 501,
                                 gid: 20,
                                 gecos: 'Test1 Test2',
                                 dir: '/Users/test1.test2',
                                 shell: '/bin/zsh',
                                 change: 0,
                                 uclass: '',
                                 expire: 0))

    allow(Etc).to receive(:getgrgid)
      .with(20)
      .and_return(OpenStruct.new(name: 'staff',
                                 passwd: '*',
                                 gid: 20,
                                 mem: ['root', 'test1.test2', '_serialnumberd', 'jenkins']))
  end

  shared_examples_for 'a resolved fact' do |fact_name, value|
    subject { Facter::Resolvers::PosxIdentity.resolve(fact_name) }

    it { is_expected.to eql(value) }
  end

  describe 'GID' do
    it_behaves_like 'a resolved fact', :gid, 20
  end

  describe 'GROUP' do
    it_behaves_like 'a resolved fact', :cache_group, 'staff'
  end

  describe 'PRIVILEGED' do
    it_behaves_like 'a resolved fact', :privileged, false
  end

  describe 'UID' do
    it_behaves_like 'a resolved fact', :uid, 501
  end

  describe 'USER' do
    it_behaves_like 'a resolved fact', :user, 'test1.test2'
  end
end
