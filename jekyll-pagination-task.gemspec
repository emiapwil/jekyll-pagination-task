# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-pagination-task'
  spec.version       = '1.0.3'
  spec.license       = 'MIT'
  spec.date          = '2014-12-10'

  spec.summary       = 'An advanced paginator for Jekyll'
  spec.description   = <<-DESC
    Jekyll Pagination Task allows you to create paginated pages by
    defining filters on attributes of all Jekyll pages.'
  DESC

  spec.author        = ['Kai Gao']
  spec.email         = 'emiapwil@gmail.com'
  spec.homepage      = 'http://github.com/emiapwil/jekyll-pagination-task'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'jekyll-paginate', '~> 1.1.0'
end
