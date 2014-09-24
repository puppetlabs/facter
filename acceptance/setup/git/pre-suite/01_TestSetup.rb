begin
  require 'puppet/acceptance/git_utils'
  extend Puppet::Acceptance::GitUtils
end

test_name "Install packages and repositories on target machines..." do
  extend Beaker::DSL::InstallUtils

  SourcePath  = Beaker::DSL::InstallUtils::SourcePath
  GitURI      = Beaker::DSL::InstallUtils::GitURI
  GitHubSig   = Beaker::DSL::InstallUtils::GitHubSig

  tmp_repositories = []
  options[:install].each do |uri|
    if uri !~ GitURI
      # Build up project git urls based on git server and fork env variables or defaults
      project = uri.split('#')
      newURI = "#{build_giturl(project[0])}#{newURI}##{project[1]}"
      tmp_repositories << extract_repo_info_from(newURI)
    else
      raise(ArgumentError, "#{uri} is not recognized.") unless(uri =~ GitURI)
      tmp_repositories << extract_repo_info_from(uri)
    end
  end

  repositories = order_packages(tmp_repositories)

  versions = {}
  hosts.each_with_index do |host, index|
    on host, "echo #{GitHubSig} >> $HOME/.ssh/known_hosts"

    repositories.each do |repository|
      step "Install #{repository[:name]}"
      install_from_git host, SourcePath, repository

      if index == 1
        versions[repository[:name]] = find_git_repo_versions(host,
                                                             SourcePath,
                                                             repository)
      end
    end
  end
end
