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
In version 0.8.0 and higher the get_stats method returns a more robust
object instead of just an array of hashes.  These stats objects are
enumerable and most existing code utilizing tabs should continue to
function.  However, please review the docs for more information if you
encounter issues when upgrading.  Please review the README if installing
v0.8.0 or higher.

Tabs v0.8.2 - BREAKING CHANGES:
In version 0.8.2 and higher the storage keys for value metrics have been
changed.  Originally the various pieces (avg, sum, count, etc) were
stored in a JSON serialized string in a single key.  The intent was that
this would comprise a poor-mans transaction of sorts.  The downside
however was a major hit on performance when doing a lot of writes or
reading stats for a large date range.  In v0.8.2 these component values
are stored in a real Redis hash and updated atomically when a value is
recorded.  In future versions this will be changed to use a MULTI
statement to simulate a transaction.  Value data that was recorded prior
to v0.8.2 will not be accessible in this or future versions so please
continue to use v0.8.1 or lower if that is an issue.
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
