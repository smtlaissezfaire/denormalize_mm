require 'date'

Gem::Specification.new do |s|
  s.name        = 'denormalize_mm'
  s.version     = '0.4.1'
  s.date        = Date.today.to_s
  s.summary     = "Denormalize fields easily in mongo mapper"
  s.description = "Helpers to denormalize fields easily on mongo mapper models"
  s.authors     = [
    "Scott Taylor",
    "Andrew Pariser"
  ]
  s.email       = 'scott@railsnewbie.com'
  s.files       = Dir.glob("lib/**/**.rb")
  s.homepage    =
    'http://github.com/smtlaissezfaire/denormalize_mm'
  s.license       = 'MIT'

  s.add_dependency 'mongo_mapper', '>= 0.15.0'
end
