
Gem::Specification.new do |s|
  s.name        = 'doxie'
  s.version     = '0.0.10'
  s.summary     = "Doxie API Wrapper for getting scans off your Doxie scanner"
  s.description = "Doxie API Wrapper for getting scans off your Doxie scanner"
  s.authors     = ["Cristiano Betta"]
  s.email       = 'cbetta@gmail.com'
  s.files       = Dir.glob('{lib,spec}/**/*') + %w(LICENSE README.md doxie.gemspec)
  s.homepage    = 'https://github.com/cbetta/doxie'
  s.license     = 'MIT'
  s.require_path = 'lib'

  s.add_development_dependency('rake')
  s.add_development_dependency('webmock')
  s.add_development_dependency('minitest')
  s.add_development_dependency('fakefs')
end
