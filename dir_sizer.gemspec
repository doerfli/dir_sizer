Gem::Specification.new do |s|
  s.name        = 'dir_sizer'
  s.version     = '0.1.0'
  s.date        = '2018-03-09'
  s.summary     = 'calculate size of a given directory'
  s.description = 'Directory sizing tool  '
  s.authors     = ['Marc Doerflinger']
  s.email       = 'mdoerflinger@gmail.com'
  s.files       = ['lib/dir_sizer.rb']
  s.executables << 'dir_sizer'
  s.homepage    =
    'http://rubygems.org/gems/dir_sizer'
  s.license     = 'MIT'

  s.add_runtime_dependency('sys-filesystem', '~>1.1.9')
  s.add_runtime_dependency('filesize', '~>0.1.1')
end
