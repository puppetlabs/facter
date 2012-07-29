desc "Sign the package with the Puppet Labs release key"
task :sign_packages do

  version = Facter::FACTERVERSION

  # Sign package

  sh "gpg --homedir $HOME/pl_release_key --detach-sign --output pkg/facter-#{version}.tar.gz.sign --armor pkg/facter-#{version}.tar.gz"

  # Sign gem

  sh "gpg --homedir $HOME/pl_release_key --detach-sign --output pkg/facter-#{version}.gem.sign --armor pkg/facter-#{version}.gem"

end
