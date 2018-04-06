# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:

#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ENCOUNTER_TYPES = [
                    'adult inpatient',
                    'adult ed',
                    'adult icu',
                    'adult inpatient surgery',
                    'pediatric inpatient',
                    'pediatric newborn',
                    'pediatric ed',
                    'continuity inpatient',
                    'continuity external'
                  ]

User.destroy_all

User.create!({
  first_name: 'Developer',
  last_name: 'Developer'
  role: 'developer',
  email: 'developer@example.com',
  password: 'password',
  tos_accepted: true,
  confirmed_at: Time.now
})
User.create!({
  first_name: 'Resident',
  last_name: 'Resident',
  role: 'resident',
  email: 'resident@example.com',
  password: 'password',
  tos_accepted: true,
  confirmed_at: Time.now
})
User.create!({
  first_name: 'Admin',
  last_name: 'Admin',
  role: 'admin',
  email: 'admin@example.com',
  password: 'password',
  tos_accepted: true,
  confirmed_at: Time.now
})
User.create!({
  first_name: 'Admin',
  last_name: 'Resident',
  role: 'admin_resident',
  email: 'admin_resident@example.com',
  password: 'password',
  tos_accepted: true,
  confirmed_at: Time.now
})

puts "Created #{User.count} users!"

Encounter.destroy_all

ENCOUNTER_TYPES.each do |type|
  User.all.each do |user|
    Encounter.create!(encounter_type: type, encountered_on: Time.zone.today, user: user)
    Encounter.create!(encounter_type: type, encountered_on: 7.days.ago, user: user)
  end
end

puts "Created #{Encounter.count} encounters!"
