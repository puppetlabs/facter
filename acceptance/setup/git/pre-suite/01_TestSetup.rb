test_name "Install packages and repositories on target machines..." do
  extend Beaker::DSL::InstallUtils

  SourcePath  = Beaker::DSL::InstallUtils::SourcePath
  GitURI      = Beaker::DSL::InstallUtils::GitURI
  GitHubSig   = Beaker::DSL::InstallUtils::GitHubSig

  tmp_repositories = []
  options[:install].each do |uri|
    raise(ArgumentError, "#{uri} is not recognized.") unless(uri =~ GitURI)
    tmp_repositories << extract_repo_info_from(uri)
  end

  repositories = order_packages(tmp_repositories)

  versions = {}
  hosts.each_with_index do |host, index|
    on host, "echo #{GitHubSig} >> $HOME/.ssh/known_hosts"

    repositories.each do |repository|
      step "Install #{repository[:name]}"
      path = if host['platform'] =~ /windows/
               on(host, 'cygpath -m /opt/puppet-git-repos').stdout.chomp
             else
               SourcePath
             end

      install_from_git_on host, path, repository

      if index == 1
        versions[repository[:name]] = find_git_repo_versions(host,
                                                             path,
                                                             repository)
      end
    end
  end
end
