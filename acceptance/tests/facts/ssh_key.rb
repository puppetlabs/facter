test_name 'SSH publick key' do
  confine :except, :platform => 'windows'

  agents.each do |agent|
    rsa_pub_host_key_path = '/etc/ssh/ssh_host_rsa_key.pub'
    original_rsa_pub_host_key = ''
    on(agent, "cat #{rsa_pub_host_key_path}") do |output|
      original_rsa_pub_host_key = output.stdout
    end

    key = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDi8n9KzzF4tPIZsohBuyxFrLnkT5YbahpIjHvQZbQ9OwG3pOxTcQJjtS/gGMKJeRE2uaHaWb700rGlfGzhit7198FmjCeYdYLZvTH0q76mN9Ew1a8aesE46JMAmZijfehxzmlbyyQDamB0wSv3CbcpGccQ3cp/jBnnj54q9EJuEN+YU/uWVHK9IgNOAj9n7l7ZKKiDAFYlhg22sWIwX+8EyoAp+ewItLpO1BJe+NcnLzMoh71Qfb2Gm/yDPbKt/3N6CHp6JeHNbbPCL0hPkcbMdc/1+3ZuzM0yqt/Sq+6lz1tQBOeDp7UqZNT0t2I5bu0NNMphpBIAELpb4f6uuZ25'
    rsa_pub_host_key_without_comment = 'ssh-rsa ' + key
    rsa_pub_host_key_with_comment = rsa_pub_host_key_without_comment + ' root@ciprian.badescu-pf1s74sr\n'

    teardown do
      on(agent, "echo '#{original_rsa_pub_host_key}' > #{rsa_pub_host_key_path}")
    end

    step 'SSH publick key with comment is printed' do
      on(agent, "echo '#{rsa_pub_host_key_with_comment}' > #{rsa_pub_host_key_path}")
      on(agent, facter('ssh.rsa.key')) do |facter_output|
        assert_equal(key, facter_output.stdout.chomp, 'Expected debug to contain key only')
      end
    end

    step 'SSH publick key without comment is printed' do
      on(agent, "echo '#{rsa_pub_host_key_without_comment}' > #{rsa_pub_host_key_path}")
      on(agent, facter('ssh.rsa.key')) do |facter_output|
        assert_equal(key, facter_output.stdout.chomp, 'Expected debug to contain key only')
      end
    end
  end
end
