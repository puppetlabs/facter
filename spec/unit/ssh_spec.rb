#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/ssh'
require 'pathname'

describe "SSH fact" do

  before do
   # We need these facts loaded, but they belong to a file with a
   # different name, so load the file explicitly.
   Facter.collection.loader.load(:ssh)
  end

    # fingerprints extracted from ssh-keygen -r '' -f /etc/ssh/ssh_host_dsa_key.pub
  { 'SSHRSAKey' => [ '/usr/local/etc/ssh_host_rsa_key.pub' , "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDrs+KtR8hjasELsyCiiBplUeIi77hEHzTSQt1ALG7N4IgtMg27ZAcq0tl2/O9ZarQuClc903pgionbM9Q98CtAIoqgJwdtsor7ETRmzwrcY/mvI7ne51UzQy4Eh9WrplfpNyg+EVO0FUC7mBcay6JY30QKasePp+g4MkwK5cuTzOCzd9up9KELonlH7tTm2L0YI4HhZugwVoTFulCAZvPICxSk1B/fEKyGSZVfY/UxZNqg9g2Wyvq5u40xQ5eO882UwhB3w4IbmRnPKcyotAcqOJxA7hToMKtEmFct+vjHE8T37w8axE/1X9mdvy8IZbkEBL1cupqqb8a8vU1QTg1z", "SSHFP 1 1 1e4f163a1747d0d1a08a29972c9b5d94ee5705d0\nSSHFP 1 2 4e834c91e423d6085ed6dfb880a59e2f1b04f17c1dc17da07708af67c5ab6045" ],
    'SSHDSAKey' => [ '/etc/ssh/ssh_host_dsa_key.pub' , "ssh-dss AAAAB3NzaC1kc3MAAACBAKjmRez14aZT6OKhHrsw19s7u30AdghwHFQbtC+L781YjJ3UV0/WQoZ8NaDL4ovuvW23RuO49tsqSNcVHg+PtRiN2iTVAS2h55TFhaPKhTs+i0NH3p3Ze8LNSYuz8uK7a+nTxysz47GYTHiE1ke8KXe5wGKDO1TO/MUgpDbwx72LAAAAFQD9yMJCnZMiKzA7J1RNkwvgCyBKSQAAAIAtWBAsuRM0F2fdCe+F/JmgyryQmRIT5vP8E1ww3t3ywdLHklN7UMkaEKBW/TN/jj1JOGXtZ2v5XI+0VNoNKD/7dnCGzNViRT/jjfyVi6l5UMg4Q52Gv0RXJoBJpxNqFOU2niSsy8hioyE39W6LJYWJtQozGpH/KKgkCSvxBn5hlAAAAIB1yo/YD0kQICOO0KE+UMMaKtV7FwyedFJsxsWYwZfHXGwWskf0d2+lPhd9qwdbmSvySE8Qrlvu+W+X8AipwGkItSnj16ORF8kO3lfABa+7L4BLDtumt7ybjBPcHOy3n28dd07TmMtyWvLjOb0mcxPo+TwDLtHd3L/3C1Dh41jRPg==\n", "SSHFP 2 1 f63dfe8da99f50ffbcfa40a61161cee29d109f70\nSSHFP 2 2 5f57aa6be9baddd71b6049ed5d8639664a7ddf92ce293e3887f16ad0f2d459d9"  ],
    'SSHECDSAKey' => [ '/etc/ssh_host_ecdsa_key.pub' , 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIuKHtgXQUIrXSVNKC7uY+ZOF7jjfqYNU7Cb/IncDOZ7jW44dxsfBzRJwS5sTHERjBinJskY87mmwY07NFF5GoE=', "SSHFP 3 1 091a088fd3500ad9e35ce201c5101646cbf6ff98\nSSHFP 3 2 1dd2aa8f29b539337316e2862b28c196c68ffe0af78fccf9e50625635677e50f"]
  }.each_pair do |fact, data|
    filename, contents, fingerprint = data
    pk = /AAAA\S+/.match(contents).to_s
    it "'#{fact}' should be '#{pk}' based on '#{filename}' contents '#{contents}'" do
      File.expects(:read).with(filename).at_least_once.returns contents
      path, file = Pathname.new(filename).split
      ["/etc/ssh","/usr/local/etc/ssh","/etc","/usr/local/etc"].each do |dir|
        if dir != path.to_s
          blockfile =  (Pathname.new(dir) + file).to_s
          FileTest.expects(:file?).with( blockfile ).at_least(0).returns false
        end
      end
      FileTest.expects(:file?).with( filename ).at_least_once.returns true

      Facter.fact(fact).value.should == pk
    end
    fp_fact = 'SSHFP_' + fact[3..-4]
    it "'#{fp_fact}' should have fingerprint '#{fingerprint}' based on '#{filename}' contents '#{contents}'" do
      File.expects(:read).with(filename).at_least_once.returns contents
      path, file = Pathname.new(filename).split
      ["/etc/ssh","/usr/local/etc/ssh","/etc","/usr/local/etc"].each do |dir|
        if dir != path.to_s
          blockfile =  (Pathname.new(dir) + file).to_s
          FileTest.expects(:file?).with( blockfile ).at_least(0).returns false
        end
      end
      FileTest.expects(:file?).with( filename ).at_least_once.returns true

      Facter.fact(fp_fact).value.should == fingerprint
    end
  end

end
