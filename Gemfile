source "https://rubygems.org"

group :test do
	gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
	gem "puppetlabs_spec_helper"
	gem "metadata-json-lint"
	gem "coveralls"
end

group :integration_test do
	gem "beaker-rspec"
	gem "vagrant-wrapper"	
end

group :development do
	gem "travis"
	gem "puppet-blacksmith"
end
