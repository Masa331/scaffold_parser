lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'scaffold_parser'
  spec.version       = '0.8.0'
  spec.authors       = ['Premysl Donat']
  spec.email         = ['pdonat@seznam.cz']

  spec.summary       = 'Tool for fast parser scaffolding'
  spec.description   = spec.description
  spec.homepage      = 'https://github.com/Masa331/scaffold_parser'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) || f.end_with?('.xsd')
  end
  spec.bindir        = 'bin'
  spec.executables   = ['scaffold_parser']
  spec.require_paths = ['lib']

  spec.add_dependency 'xsd_model'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'saharspec'
end
