{
  :type          => 'foss',
  :forge_host    => 'forge-aio01-petest.puppetlabs.com',
  :load_path     => './lib/',
  :repo_proxy    => true,
  :add_el_extras => true,
  :pre_suite => [
    'setup/common/pre-suite/000-delete-puppet-when-none.rb',
    'setup/common/00_EnvSetup.rb',
    'setup/packages/pre-suite/010_Install.rb',
  ],
}
