# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tabs/version'

Gem::Specification.new do |gem|

  gem.name          = "tabs"
  gem.version       = Tabs::VERSION
  gem.authors       = ["JC Grubbs"]
  gem.email         = ["jc.grubbs@devmynd.com"]
  gem.description   = %q{A redis-backed metrics tracker for keeping tabs on pretty much anything ;)}
  gem.summary       = %q{A redis-backed metrics tracker for keeping tabs on pretty much anything ;)}
  gem.homepage      = "https://github.com/thegrubbsian/tabs"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.post_install_message = <<EOS
Tabs v0.8.0 - BREAKING CHANGES:
The get_stats method now returns a more robust object instead of just
an array of hashes.  Existing data will continue to work (no changes were
made to the underlying Redis keys).  However, application code using
tabs may need to be changed.  Please review the README after installing
v0.8.0 or higher.
EOS

  gem.add_dependency "activesupport", ">= 3.2"
  gem.add_dependency "json", ">= 1.7"
  gem.add_dependency "redis", "~> 3.0.0"

  gem.add_development_dependency "fakeredis"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "timecop"

end
