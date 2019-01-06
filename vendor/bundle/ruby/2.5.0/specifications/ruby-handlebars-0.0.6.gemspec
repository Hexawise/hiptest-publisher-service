# -*- encoding: utf-8 -*-
# stub: ruby-handlebars 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby-handlebars".freeze
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Vincent Pretre".freeze, "Hiptest R&D".freeze]
  s.date = "2018-02-12"
  s.email = "v.pretre@hiptest.net".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.md".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://github.com/vincent-psarga/ruby-handlebars".freeze
  s.rubygems_version = "2.7.8".freeze
  s.summary = "Pure Ruby library for Handlebars templates".freeze

  s.installed_by_version = "2.7.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<parslet>.freeze, [">= 1.6.2", "~> 1.6"])
      s.add_runtime_dependency(%q<colorize>.freeze, [">= 0.7.5", "~> 0.7"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0.10.1", "~> 0.10"])
      s.add_development_dependency(%q<pry-stack_explorer>.freeze, [">= 0.4.9.1", "~> 0.4"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 3.1.0", "~> 3.1"])
      s.add_development_dependency(%q<rspec-mocks>.freeze, [">= 3.1.3", "~> 3.1"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.6", "~> 0.4"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 2.0.1", "~> 2.0"])
    else
      s.add_dependency(%q<parslet>.freeze, [">= 1.6.2", "~> 1.6"])
      s.add_dependency(%q<colorize>.freeze, [">= 0.7.5", "~> 0.7"])
      s.add_dependency(%q<pry>.freeze, [">= 0.10.1", "~> 0.10"])
      s.add_dependency(%q<pry-stack_explorer>.freeze, [">= 0.4.9.1", "~> 0.4"])
      s.add_dependency(%q<rspec>.freeze, [">= 3.1.0", "~> 3.1"])
      s.add_dependency(%q<rspec-mocks>.freeze, [">= 3.1.3", "~> 3.1"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.6", "~> 0.4"])
      s.add_dependency(%q<jeweler>.freeze, [">= 2.0.1", "~> 2.0"])
    end
  else
    s.add_dependency(%q<parslet>.freeze, [">= 1.6.2", "~> 1.6"])
    s.add_dependency(%q<colorize>.freeze, [">= 0.7.5", "~> 0.7"])
    s.add_dependency(%q<pry>.freeze, [">= 0.10.1", "~> 0.10"])
    s.add_dependency(%q<pry-stack_explorer>.freeze, [">= 0.4.9.1", "~> 0.4"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.1.0", "~> 3.1"])
    s.add_dependency(%q<rspec-mocks>.freeze, [">= 3.1.3", "~> 3.1"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.6", "~> 0.4"])
    s.add_dependency(%q<jeweler>.freeze, [">= 2.0.1", "~> 2.0"])
  end
end
