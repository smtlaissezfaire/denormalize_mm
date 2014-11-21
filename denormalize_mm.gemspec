require 'date'

Gem::Specification.new do |s|
  s.name        = 'denormalize_mm'
  s.version     = '0.2.3'
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
    'http://github.com/GoLearnUp/denormalize_mm'
  s.license       = 'MIT'
end
