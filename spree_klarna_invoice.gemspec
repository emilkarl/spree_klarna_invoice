# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'spree_klarna_invoice'
  s.version      = '1.2.0'
  s.summary      = 'Spree extenstion for Klarna Invoice Payment Method'
  s.description  = 'Makes it possible to invoice customers with Klarna\'s services. Read more on Klara at http://klarna.com'

  s.required_ruby_version = '>= 1.8.7'

  s.author       = 'Emil Karlsson'
  s.email        = 'emil@nocweb.se'
  s.homepage     = 'http://nocweb.se'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.3.0'

  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 2.7'
  s.add_development_dependency 'sqlite3'
end
