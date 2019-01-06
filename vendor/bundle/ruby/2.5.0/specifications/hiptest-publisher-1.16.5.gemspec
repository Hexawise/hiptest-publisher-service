# -*- encoding: utf-8 -*-
# stub: hiptest-publisher 1.16.5 ruby lib

Gem::Specification.new do |s|
  s.name = "hiptest-publisher".freeze
  s.version = "1.16.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Hiptest R&D".freeze]
  s.date = "2018-10-19"
  s.description = "Provides a command-line tool that generates Java, Python or Ruby code to run the tests.".freeze
  s.email = "contact@hiptest.com".freeze
  s.executables = ["hiptest-publisher".freeze]
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze, "bin/hiptest-publisher".freeze]
  s.homepage = "https://hiptest.com".freeze
  s.licenses = ["GPL-2.0".freeze]
  s.rubygems_version = "2.7.8".freeze
  s.summary = "Export your tests from Hiptest into executable tests.".freeze

  s.installed_by_version = "2.7.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<colorize>.freeze, [">= 0.7.5", "~> 0.7"])
      s.add_runtime_dependency(%q<parseconfig>.freeze, [">= 1.0.4", "~> 1.0"])
      s.add_runtime_dependency(%q<i18n>.freeze, [">= 0.7.0", "~> 0.7"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.8.0", "~> 1.8.0"])
      s.add_runtime_dependency(%q<multipart-post>.freeze, [">= 2.0.0", "~> 2.0"])
      s.add_runtime_dependency(%q<ruby-handlebars>.freeze, ["~> 0.0.2"])
      s.add_runtime_dependency(%q<ruby_version>.freeze, ["~> 1"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0"])
      s.add_development_dependency(%q<pry-byebug>.freeze, ["~> 3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<rspec-mocks>.freeze, ["~> 3.3"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.6", "~> 0.4"])
    else
      s.add_dependency(%q<colorize>.freeze, [">= 0.7.5", "~> 0.7"])
      s.add_dependency(%q<parseconfig>.freeze, [">= 1.0.4", "~> 1.0"])
      s.add_dependency(%q<i18n>.freeze, [">= 0.7.0", "~> 0.7"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 1.8.0", "~> 1.8.0"])
      s.add_dependency(%q<multipart-post>.freeze, [">= 2.0.0", "~> 2.0"])
      s.add_dependency(%q<ruby-handlebars>.freeze, ["~> 0.0.2"])
      s.add_dependency(%q<ruby_version>.freeze, ["~> 1"])
      s.add_dependency(%q<pry>.freeze, ["~> 0"])
      s.add_dependency(%q<pry-byebug>.freeze, ["~> 3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
      s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.3"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.6", "~> 0.4"])
    end
  else
    s.add_dependency(%q<colorize>.freeze, [">= 0.7.5", "~> 0.7"])
    s.add_dependency(%q<parseconfig>.freeze, [">= 1.0.4", "~> 1.0"])
    s.add_dependency(%q<i18n>.freeze, [">= 0.7.0", "~> 0.7"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 1.8.0", "~> 1.8.0"])
    s.add_dependency(%q<multipart-post>.freeze, [">= 2.0.0", "~> 2.0"])
    s.add_dependency(%q<ruby-handlebars>.freeze, ["~> 0.0.2"])
    s.add_dependency(%q<ruby_version>.freeze, ["~> 1"])
    s.add_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_dependency(%q<pry-byebug>.freeze, ["~> 3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
    s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.3"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 0.4.6", "~> 0.4"])
  end
end
