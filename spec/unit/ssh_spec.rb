#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/ssh'

describe "SSH fact" do


  {
    # fingerprints extracted from ssh-keygen -r '' -f /etc/ssh/ssh_host_dsa_key.pub
    'SSHRSAKey' => [ '/usr/local/etc/ssh_host_rsa_key.pub' , "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDrs+KtR8hjasELsyCiiBplUeIi77hEHzTSQt1ALG7N4IgtMg27ZAcq0tl2/O9ZarQuClc903pgionbM9Q98CtAIoqgJwdtsor7ETRmzwrcY/mvI7ne51UzQy4Eh9WrplfpNyg+EVO0FUC7mBcay6JY30QKasePp+g4MkwK5cuTzOCzd9up9KELonlH7tTm2L0YI4HhZugwVoTFulCAZvPICxSk1B/fEKyGSZVfY/UxZNqg9g2Wyvq5u40xQ5eO882UwhB3w4IbmRnPKcyotAcqOJxA7hToMKtEmFct+vjHE8T37w8axE/1X9mdvy8IZbkEBL1cupqqb8a8vU1QTg1z", 'SSHFP 1 1 1e4f163a1747d0d1a08a29972c9b5d94ee5705d0'  ],
    'SSHDSAKey' => [ '/etc/ssh/ssh_host_dsa_key.pub' , "ssh-dss AAAAB3NzaC1kc3MAAACBAKjmRez14aZT6OKhHrsw19s7u30AdghwHFQbtC+L781YjJ3UV0/WQoZ8NaDL4ovuvW23RuO49tsqSNcVHg+PtRiN2iTVAS2h55TFhaPKhTs+i0NH3p3Ze8LNSYuz8uK7a+nTxysz47GYTHiE1ke8KXe5wGKDO1TO/MUgpDbwx72LAAAAFQD9yMJCnZMiKzA7J1RNkwvgCyBKSQAAAIAtWBAsuRM0F2fdCe+F/JmgyryQmRIT5vP8E1ww3t3ywdLHklN7UMkaEKBW/TN/jj1JOGXtZ2v5XI+0VNoNKD/7dnCGzNViRT/jjfyVi6l5UMg4Q52Gv0RXJoBJpxNqFOU2niSsy8hioyE39W6LJYWJtQozGpH/KKgkCSvxBn5hlAAAAIB1yo/YD0kQICOO0KE+UMMaKtV7FwyedFJsxsWYwZfHXGwWskf0d2+lPhd9qwdbmSvySE8Qrlvu+W+X8AipwGkItSnj16ORF8kO3lfABa+7L4BLDtumt7ybjBPcHOy3n28dd07TmMtyWvLjOb0mcxPo+TwDLtHd3L/3C1Dh41jRPg==\n", 'SSHFP 2 1 f63dfe8da99f50ffbcfa40a61161cee29d109f70'  ],
    'SSHECDSAKey' => [ '/etc/ssh_host_ecdsa_key.pub' , 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIuKHtgXQUIrXSVNKC7uY+ZOF7jjfqYNU7Cb/IncDOZ7jW44dxsfBzRJwS5sTHERjBinJskY87mmwY07NFF5GoE=', nil]
  }.each_pair do |fact, pubkey|
    Facter.clear
    filename, contents, fingerprint = pubkey
    pk = /AAAA\S+/.match(contents).to_s
    it "'#{fact}' should be '#{pk}' based on '#{filename}' contents '#{contents}'" do
      FileTest.stubs(:file?).returns false
      FileTest.expects(:file?).with(filename).returns true
      File.expects(:open).with(filename).at_least_once
      File.expects(:read).with(filename).returns contents

      Facter.fact(fact).value.should == pk
    end
    Facter.clear
    fp_fact = 'SSHFP_' + fact[3..-4]
    it "'#{fp_fact}' should have fingerprint '#{fingerprint}' based on '#{filename}' contents '#{contents}'" do
      Facter.fact(fact).stubs(:value).returns(pk)

      f = Facter.fact(fp_fact).value
      if fact == 'SSHECDSAKey'
      # no IANA registered RR type ids for ECDSA`
        f == nil
      else
        f.should == fingerprint
      end
    end
  end


end
