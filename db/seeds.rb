# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:

#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all

# This user is for debugging.
User.create!({
  residency: 'Developer Residency',
  first_name: 'Developer',
  last_name: 'Developer',
  role: 'developer',
  email: 'developer@example.com',
  password: 'password',
  tos_accepted: true,
  active_until: Time.now + 1.year,
  confirmed_at: Time.now
})

# Consider a residency with an admin
admin = User.create!({
  residency: 'Seed Admin Residency',
  first_name: 'Admin',
  last_name: 'Admin',
  role: 'admin',
  email: 'admin@example.com',
  password: 'password',
  tos_accepted: true,
  active_until: Time.now + 1.year,
  confirmed_at: Time.now
})

# Consider a residency with an admin_resident
admin_resident = User.create!({
  first_name: 'Admin',
  last_name: 'Resident',
  role: 'admin_resident',
  email: 'admin_resident@example.com',
  password: 'password',
  tos_accepted: true,
  active_until: Time.now + 1.year,
  confirmed_at: Time.now
})

resident_user_params = {
  first_name: 'Resident',
  last_name: 'Resident',
  role: 'resident',
  password: 'password',
  tos_accepted: true,
  confirmed_at: Time.now
}

# These are generic residents invited by the admin
30.times do
  current_resident_count = User.where(role: 'resident').count
  email = "resident-#{current_resident_count}@example.com"
  last_name = "Resident-#{current_resident_count}"
  User.invite!(resident_user_params.merge(email: email), admin) do |u|
    u.skip_invitation = true
  end
end

# These are generic residents invited by the admin_resident
30.times do
  current_resident_count = User.where(role: 'resident').count
  email = "resident-#{current_resident_count}@example.com"
  last_name = "resident-#{current_resident_count}@example.com"
  User.invite!(resident_user_params.merge(email: email), admin_resident) do |u|
    u.skip_invitation = true
  end
end

puts "Created #{User.count} users!"

Encounter.destroy_all

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

User.all.each do |user|
  ENCOUNTER_TYPES.each do |encounter_type|
    10.times {
      user.encounters.create! encounter_type: encounter_type, encountered_on: Time.zone.today
      user.encounters.create! encounter_type: encounter_type, encountered_on: 7.days.ago
    }
  end
end

puts "Created #{Encounter.count} encounters!"
