
Gem::Specification.new do |s|
  s.name        = 'doxie'
  s.version     = '0.0.4'
  s.summary     = "Doxie API Wrapper for getting scans off your Doxie scanner"
  s.description = "Doxie API Wrapper for getting scans off your Doxie scanner"
  s.authors     = ["Cristiano Betta"]
  s.email       = 'cbetta@gmail.com'
  s.files       = ["lib/doxie.rb"]
  s.homepage    = 'https://github.com/cbetta/doxie'
  s.license     = 'MIT'

  s.add_development_dependency('rake')
  s.add_development_dependency('webmock')
  s.add_development_dependency('minitest')
  s.add_development_dependency('minitest-reporters')
end
