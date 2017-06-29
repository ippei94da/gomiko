# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: gomiko 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "gomiko"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["ippei94da"]
  s.date = "2017-06-29"
  s.description = "\n    This Gem provides functionality similar to the Trash box in Windows OS.\n    The name 'gomiko' was originated from Japanese \"gomibako\".\n    If you think that it is \"a shrine maiden(miko-san) who plays go\", is it cute?\n    Gomiko provides the gomiko command;\n    it moves the file to ~/.trash with a change of rm.\n    And the command also can display the history of deletion and can execute undo.\n    Gomiko provides the Gomiko library.\n    It is designed so that the trash box can be handled from the Ruby program as well.\n   "
  s.email = "ippei94da@gmail.com"
  s.executables = ["gomiko"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "CHANGES",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/gomiko",
    "lib/gomiko.rb",
    "test/.gitignore",
    "test/helper.rb",
    "test/test_gomiko.rb"
  ]
  s.homepage = "http://github.com/ippei94da/gomiko"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Trashbox with command line interface"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 4.2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.3"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.2"])
      s.add_development_dependency(%q<filerenamer>, ["~> 0.0"])
      s.add_development_dependency(%q<tefil>, ["~> 0.1"])
      s.add_development_dependency(%q<builtinextension>, ["~> 0.1"])
    else
      s.add_dependency(%q<rdoc>, ["~> 4.2"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 2.3"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<test-unit>, ["~> 3.2"])
      s.add_dependency(%q<filerenamer>, ["~> 0.0"])
      s.add_dependency(%q<tefil>, ["~> 0.1"])
      s.add_dependency(%q<builtinextension>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 4.2"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 2.3"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<test-unit>, ["~> 3.2"])
    s.add_dependency(%q<filerenamer>, ["~> 0.0"])
    s.add_dependency(%q<tefil>, ["~> 0.1"])
    s.add_dependency(%q<builtinextension>, ["~> 0.1"])
  end
end
