# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','curly','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'curlyq'
  s.version = Curly::VERSION
  s.author = 'Brett Terpstra'
  s.email = 'me@brettterpstra.com'
  s.homepage = 'https://brettterpstra.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A CLI helper for curl and web scraping'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.rdoc','curlyq.rdoc']
  s.rdoc_options << '--title' << 'curlyq' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'curlyq'
  s.add_development_dependency('rake','~> 0.9.2')
  s.add_development_dependency('rdoc', '~> 4.3')
  s.add_development_dependency('minitest', '~> 5.14')
  s.add_runtime_dependency('gli','~> 2.21.0')
  s.add_runtime_dependency('tty-which','~> 0.5.0')
  s.add_runtime_dependency('nokogiri','~> 1.16.0')
  s.add_runtime_dependency('selenium-webdriver', '~> 4.16.0')
end
