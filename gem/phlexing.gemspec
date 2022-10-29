# frozen_string_literal: true

require_relative "lib/phlexing/version"

Gem::Specification.new do |spec|
  spec.name = "phlexing"
  spec.version = Phlexing::VERSION
  spec.authors = ["Marco Roth"]
  spec.email = ["marco.roth@hey.com"]

  spec.summary = "Simple ERB to Phlex converter"
  spec.description = "Simple ERB to Phlex converter"
  spec.homepage = "https://github.com/marcoroth/phlexing"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcoroth/phlexing"
  spec.metadata["changelog_uri"] = "https://github.com/marcoroth/phlexing"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "erb_parser"
  spec.add_dependency "html_press"
  spec.add_dependency "nokogiri"
  spec.add_dependency "rufo"
end