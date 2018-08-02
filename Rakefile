RAKE_ROOT = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << File.join(RAKE_ROOT, 'tasks')
require 'rake'
Dir['tasks/**/*.rake'].each { |t| load t }

require 'packaging'
Pkg::Util::RakeUtils.load_packaging_tasks
