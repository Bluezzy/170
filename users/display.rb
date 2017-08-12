require 'yaml'

USERS = YAML.load_file("data/users.yaml")

puts USERS

USERS.each do |user, _|
  p user
end
