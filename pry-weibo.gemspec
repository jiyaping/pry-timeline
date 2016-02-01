# encoding : utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include? lib

require 'pry-timeline/version'

Gem::Specification.new do |spec|
  spec.name           = 'pry-timeline'
  spec.version        = PryTimeline::VERSION
  spec.authors        = ['jiyaping']
  spec.email          = ['jiyaping0802@gmail.com']
  spec.summary        = 'viewing timeline via pry'
  spec.description    = 'a cli timeline client'
  spec.homepage       = 'https://github.com/jiyaping/pry-timeline'
  spec.license        = 'MIT'

  spec.require_paths  = ['lib']
  spec.files          = Dir['{bin,lib/**/*}'] + %w[Rakefile README.md]
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ["lib"]

  spec.add_runtime_dependency 'pry','~> 0'
  spec.add_runtime_dependency 'colorize','~> 0'
  spec.add_runtime_dependency 'faraday','~> 0'
end