# Required gems
require 'rubygems'
require 'bundler/setup'
require 'hiera'

# Gems: Rake tasks
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These gems aren't always present
begin
	#On Travis with --without development
	require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end


# Directories that don't need to be checked (Lint/Syntax)
exclude_paths = [
	"spec/**/*",
  "examples/**/*",
]


# Settings for syntax checker
PuppetSyntax.exclude_paths = exclude_paths


# Overwrite default lint task
Rake::Task[:lint].clear
# Puppet Lint config
PuppetLint::RakeTask.new :lint do |config|
  #config.relative = true           # BUG in 1.1.0 - does not work ?  
  config.with_context = true  
  config.fail_on_warnings = true
  
  config.fix = false
  
  config.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
  
  config.disable_checks = [ "80chars", "class_inherits_from_params_class" ] # class_parameter_defaults
    
  config.ignore_paths = exclude_paths
end


# Extra Tasks
desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
	t.pattern = 'spec/acceptance'
end

desc "Run syntax, lint, and spec tests."
task :test => [
	:syntax,
  :metadata,
  :lint,
	:spec,
]