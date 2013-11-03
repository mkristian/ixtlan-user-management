# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-user-management'
  s.version = '0.3.0'

  s.summary = 'helper for managing users with login/password'
  s.description= 'helper for managing users with login/password via local db or remote rest-services'
  s.homepage = 'https://github.com/mkristian/ixtlan-user-management'

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']

  s.license = "MIT"

  s.files += Dir['lib/**/*.rb']
  s.files += Dir['spec/**/*.rb']
  s.files += Dir['MIT-LICENSE']
  s.files += Dir['*.md']
  s.files += Dir['Gemfile']

  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_runtime_dependency 'multi_json', '~> 1.6'
  s.add_runtime_dependency 'virtus', '~> 0.5'
  s.add_development_dependency 'rake', '~> 10.1'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'dm-sqlite-adapter', '1.2.0'
  s.add_development_dependency 'dm-migrations', '1.2.0'
  s.add_development_dependency 'dm-timestamps', '1.2.0'
  s.add_development_dependency 'dm-validations', '1.2.0'
  s.add_development_dependency 'ixtlan-audit'
  s.add_development_dependency 'ixtlan-error-handler'
  s.add_development_dependency 'ixtlan-remote'
  s.add_development_dependency 'ixtlan-gettext'
  s.add_development_dependency 'ixtlan-configuration'
  s.add_development_dependency 'ixtlan-babel'
  s.add_development_dependency 'json', '~>1.7'
  s.add_development_dependency 'cuba-api', '>= 0.5.1', '< 0.6.0'
end
