# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','curly','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'curlyq'
  s.version = Curly::VERSION
  s.author = 'Brett Terpstra'
  s.email = 'me@brettterpstra.com'
  s.homepage = 'https://brettterpstra.com'
  s.platform = Gem::Platform::RUBY
  s.licenses = 'MIT'
  s.summary = 'A CLI helper for curl and web scraping'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.rdoc','curlyq.rdoc']
  s.rdoc_options << '--title' << 'curlyq' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'curlyq'
  s.add_development_dependency('rake','~> 13.0', '>= 13.0.1')
  s.add_development_dependency('rdoc', '~> 6.3.1')
  s.add_development_dependency('test-unit', '~> 3.4.4')
  s.add_development_dependency('yard', '~> 0.9', '>= 0.9.26')
  s.add_development_dependency('tty-spinner', '~> 0.9', '>= 0.9.3')
  s.add_development_dependency('tty-progressbar', '~> 0.18', '>= 0.18.2')
  s.add_development_dependency('pastel', '~> 0.8.0')
  s.add_development_dependency('parallel_tests', '~> 3.7', '>= 3.7.3')
  s.add_runtime_dependency('gli','~> 2.21.0')
  s.add_runtime_dependency('tty-which','~> 0.5.0')
  s.add_runtime_dependency('nokogiri','~> 1.16.0')
  s.add_runtime_dependency('selenium-webdriver', '~> 4.16.0')
end
