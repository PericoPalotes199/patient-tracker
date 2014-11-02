# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:

#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ENCOUNTER_TYPES = [
                    'adult inpatient and ed',
                    'adult icu',
                    'pediatric inpatient',
                    'pediatric newborn',
                    'pediatric ed',
                    'continuity inpatient',
                    'continuity external'
                  ]


User.destroy_all

developer = User.create!({ first_name: 'Developer', last_name: 'Developer', role: 'Developer',  email: ENV['SEED_USER_EMAIL'], password: ENV['SEED_USER_PASSWORD'] })

puts "Created #{User.count} users!"

Encounter.destroy_all

ENCOUNTER_TYPES.each do |type|
  Encounter.create!(encounter_type: type, encountered_on: Time.zone.today, user: developer)
  Encounter.create!(encounter_type: type, encountered_on: 7.days.ago, user: developer)
end

puts "Created #{Encounter.count} encounters!"
