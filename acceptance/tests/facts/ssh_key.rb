test_name 'SSH publick key' do
  confine :except, :platform => 'windows'
  confine :except, :platform => /solaris/

  agents.each do |agent|
    ssh_host_rsa_key_file = '/etc/ssh/ssh_host_rsa_key.pub'
    ssh_tmp_host_rsa_key_file = '/tmp/ssh_host_rsa_key.pub'

    # The 'cp' might fail because the source file doesn't exist
    on(
      agent,
      "cp -fv #{ssh_host_rsa_key_file} #{ssh_tmp_host_rsa_key_file}",
      acceptable_exit_codes: [0, 1]
    )

    key = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDi8n9KzzF4tPIZsohBuyxFrLnkT5YbahpIjHvQZbQ9OwG3pOxTcQJjtS/gGMKJeRE2uaHaWb700rGlfGzhit7198FmjCeYdYLZvTH0q76mN9Ew1a8aesE46JMAmZijfehxzmlbyyQDamB0wSv3CbcpGccQ3cp/jBnnj54q9EJuEN+YU/uWVHK9IgNOAj9n7l7ZKKiDAFYlhg22sWIwX+8EyoAp+ewItLpO1BJe+NcnLzMoh71Qfb2Gm/yDPbKt/3N6CHp6JeHNbbPCL0hPkcbMdc/1+3ZuzM0yqt/Sq+6lz1tQBOeDp7UqZNT0t2I5bu0NNMphpBIAELpb4f6uuZ25'
    rsa_pub_host_key_without_comment = 'ssh-rsa ' + key
    rsa_pub_host_key_with_comment = rsa_pub_host_key_without_comment + ' root@ciprian.badescu-pf1s74sr\n'

    teardown do
      # Is it present?
      rc = on(
        agent,
        "[ -e #{ssh_tmp_host_rsa_key_file} ]",
        accept_all_exit_codes: true,
      )
      if rc.exit_code == 0
        # It's present, so restore the original
        on(
          agent,
          "mv -fv #{ssh_tmp_host_rsa_key_file} #{ssh_host_rsa_key_file}",
          accept_all_exit_codes: true,
        )
      else
        # It's missing, which means there wasn't one to backup; just
        # delete the one we laid down
        on(
          agent,
          "rm -fv #{ssh_host_rsa_key_file}",
          accept_all_exit_codes: true,
        )
      end
    end

    step 'SSH publick key with comment is printed' do
      on(agent, "echo '#{rsa_pub_host_key_with_comment}' > #{ssh_host_rsa_key_file}")
      on(agent, facter('ssh.rsa.key')) do |facter_output|
        assert_equal(key, facter_output.stdout.chomp, 'Expected debug to contain key only')
      end
    end

    step 'SSH publick key without comment is printed' do
      on(agent, "echo '#{rsa_pub_host_key_without_comment}' > #{ssh_host_rsa_key_file}")
      on(agent, facter('ssh.rsa.key')) do |facter_output|
        assert_equal(key, facter_output.stdout.chomp, 'Expected debug to contain key only')
      end
    end
  end
end
