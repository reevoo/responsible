$:.unshift 'lib'

Gem::Specification.new do |s|
  s.platform   = Gem::Platform::RUBY
  s.name       = "responsible"
  s.version    = "0.1.0"
  s.date       = Time.now.strftime('%Y-%m-%d')
  s.homepage   = "https://github.com/reevoo/responsible"
  s.authors    = ["dw_henry", "lamp"]
  s.email      = "developers@reevoo.com"
  s.summary    = "Response builders"
  s.description= "JSON building library"

  s.files      = %w[ Gemfile README.md responsible.gemspec LICENSE ]
  s.files     += Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'minitest', '~> 0'
  s.add_development_dependency 'rspec', '~> 0'
end
