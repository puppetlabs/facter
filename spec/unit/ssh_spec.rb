#! /usr/bin/env ruby

require 'spec_helper'
require 'facter/ssh'
require 'pathname'

describe "SSH fact" do

  dirs = [  '/etc/ssh',
    '/usr/local/etc/ssh',
    '/etc',
    '/usr/local/etc',
    '/etc/opt/ssh',
  ]

  before :each do
    # We need these facts loaded, but they belong to a file with a
    # different name, so load the file explicitly.
    Facter.collection.internal_loader.load(:ssh)
  end

  # fingerprints extracted from ssh-keygen -r '' -f /etc/ssh/ssh_host_dsa_key.pub
  { 'SSHRSAKey' => [ 'ssh_host_rsa_key.pub' , "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDrs+KtR8hjasELsyCiiBplUeIi77hEHzTSQt1ALG7N4IgtMg27ZAcq0tl2/O9ZarQuClc903pgionbM9Q98CtAIoqgJwdtsor7ETRmzwrcY/mvI7ne51UzQy4Eh9WrplfpNyg+EVO0FUC7mBcay6JY30QKasePp+g4MkwK5cuTzOCzd9up9KELonlH7tTm2L0YI4HhZugwVoTFulCAZvPICxSk1B/fEKyGSZVfY/UxZNqg9g2Wyvq5u40xQ5eO882UwhB3w4IbmRnPKcyotAcqOJxA7hToMKtEmFct+vjHE8T37w8axE/1X9mdvy8IZbkEBL1cupqqb8a8vU1QTg1z", "SSHFP 1 1 1e4f163a1747d0d1a08a29972c9b5d94ee5705d0\nSSHFP 1 2 4e834c91e423d6085ed6dfb880a59e2f1b04f17c1dc17da07708af67c5ab6045" ],
    'SSHDSAKey' => [ 'ssh_host_dsa_key.pub' , "ssh-dss AAAAB3NzaC1kc3MAAACBAKjmRez14aZT6OKhHrsw19s7u30AdghwHFQbtC+L781YjJ3UV0/WQoZ8NaDL4ovuvW23RuO49tsqSNcVHg+PtRiN2iTVAS2h55TFhaPKhTs+i0NH3p3Ze8LNSYuz8uK7a+nTxysz47GYTHiE1ke8KXe5wGKDO1TO/MUgpDbwx72LAAAAFQD9yMJCnZMiKzA7J1RNkwvgCyBKSQAAAIAtWBAsuRM0F2fdCe+F/JmgyryQmRIT5vP8E1ww3t3ywdLHklN7UMkaEKBW/TN/jj1JOGXtZ2v5XI+0VNoNKD/7dnCGzNViRT/jjfyVi6l5UMg4Q52Gv0RXJoBJpxNqFOU2niSsy8hioyE39W6LJYWJtQozGpH/KKgkCSvxBn5hlAAAAIB1yo/YD0kQICOO0KE+UMMaKtV7FwyedFJsxsWYwZfHXGwWskf0d2+lPhd9qwdbmSvySE8Qrlvu+W+X8AipwGkItSnj16ORF8kO3lfABa+7L4BLDtumt7ybjBPcHOy3n28dd07TmMtyWvLjOb0mcxPo+TwDLtHd3L/3C1Dh41jRPg==\n", "SSHFP 2 1 f63dfe8da99f50ffbcfa40a61161cee29d109f70\nSSHFP 2 2 5f57aa6be9baddd71b6049ed5d8639664a7ddf92ce293e3887f16ad0f2d459d9"  ],
    'SSHECDSAKey' => [ 'ssh_host_ecdsa_key.pub' , 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIuKHtgXQUIrXSVNKC7uY+ZOF7jjfqYNU7Cb/IncDOZ7jW44dxsfBzRJwS5sTHERjBinJskY87mmwY07NFF5GoE=', "SSHFP 3 1 091a088fd3500ad9e35ce201c5101646cbf6ff98\nSSHFP 3 2 1dd2aa8f29b539337316e2862b28c196c68ffe0af78fccf9e50625635677e50f"],
    'SSHED25519Key' => [ 'ssh_host_ed25519_key.pub' , 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAkxkUMKV0H7Z0KDgfMs+iKQFwJhKUDg8GImV/BwN48X', "SSHFP 4 1 216d49ff3581a42c7a2d4064f2356b375367d493\nSSHFP 4 2 95e3aa6f86bc2dcc46f1e9e5ea930c790afc0669fcf237c4d7b0c8e386ef2790"]
  }.each_pair do |fact, data|
    describe "#{fact}" do
      let(:filename) { data[0] }
      let(:contents) { data[1] }
      let(:fingerprint) { data[2] }
      let(:fingerprint_fact) { "SSHFP_#{fact[3..-4]}" }
      let(:private_key) { /AAAA\S+/.match(contents).to_s }

      # Before we start testing, we'll say that the file
      # doesn't exist in any of our search locations.
      # Then, when we test a specific directory, we'll
      # toggle just that one on.
      # This doesn't test the search order, but it does
      # make testing each of the individual cases *way*
      # easier.  --jeffweiss 24 May 2012
      before(:each) do
        dirs.each do |dir|
          full_path = File.join(dir, filename)
          FileTest.stubs(:file?).with(full_path).returns false
        end
      end

      # Now, let's go through each and individually flip then
      # on for that test.
      dirs.each do |dir|
        describe "when data is in #{dir}" do
          let(:full_path) { File.join(dir, filename) }
          before(:each) do
            full_path = File.join(dir, filename)
            FileTest.stubs(:file?).with(full_path).returns true
          end

          it "should find in #{dir}" do
            FileTest.expects(:file?).with(full_path)
            Facter.fact(fact).value
          end

          it "should match the contents" do
            File.expects(:read).with(full_path).at_least_once.returns contents
            Facter.fact(fact).value.should == private_key
          end

          it "should have matching fingerprint" do
            File.expects(:read).with(full_path).at_least_once.returns contents
            Facter.fact(fingerprint_fact).value.should == fingerprint
          end
        end
      end
    end
  end
end
