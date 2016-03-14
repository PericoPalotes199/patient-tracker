# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:

#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#   $ rake db:fixtures:load

include EncountersHelper

User.destroy_all
Organization.destroy_all
Encounter.destroy_all

# Set up the organizations.
acme_inc = Organization.create!({ name: 'Acme Inc', kind: 'Company' })
some_residency = Organization.create!({ name: 'Some Residency', kind: 'Residency' })
another_residency = Organization.create!({ name: 'Another Residency', kind: 'Residency' })

# Give the organizations items.
acme_inc.items.create([
  { label: 'Airplanes' },
  { label: 'Water: Pistols' },
  { label: 'Rubber Black Holes' },
  { label: "Yosemite Sam's: Guns" },
  { label: "Pranksters': Tools" },
  { label: "Gamma-Ray: Blasters" }
])

some_residency.items.create([
  { label: 'Adult: Inpatient' },
  { label: 'Adult: ICU' },
  { label: 'Obstetrics: Vaginal Deliveries' },
  { label: 'OlderAdults: Outpatient' },
  { label: 'Pediatric: Outpatient' },
  { label: 'Pediatric: Inpatient' },
  { label: 'Pediatric: Newborn' },
  { label: 'Pediatric: ED' },
  { label: 'Women’s Health: Outpatient' }
])

another_residency.items.create([
  { label: "Adult: Inpatient" },          # "adult inpatient"
  { label: "Adult: ED" },                 # "adult ed"
  { label: "Adult: ICU" },                # "adult icu"
  { label: "Adult: Inpatient Surgery" },  # "adult inpatient surgery"
  { label: "Pediatric: Inpatient" },      # "pediatric inpatient"
  { label: "Pediatric: Newborn" },        # "pediatric newborn"
  { label: "Pediatric: ED" },             # "pediatric ed"
  { label: "Continuity: Inpatient" },     # "continuity inpatient"
  { label: "Continuity: External" }       # "continuity external"
])

developer = User.create!({
  first_name: 'Developer',
  last_name: 'Developer',
  role: 'developer',
  organization: acme_inc,
  email: 'developer@example.com',
  password: 'password',
  tos_accepted: true,
  active_until: Time.now + 1.year,
  confirmed_at: Time.now
})

resident = User.create!({
  first_name: 'Resident',
  last_name: 'Resident',
  role: 'resident',
  organization: Organization.last,
  email: 'resident@example.com',
  password: 'password',
  tos_accepted: true,
  active_until: Time.now + 1.year,
  confirmed_at: Time.now
})

admin = User.create!({
  first_name: 'Admin',
  last_name: 'Admin',
  role: 'admin',
  organization: Organization.last,
  email: 'admin@example.com',
  password: 'password',
  tos_accepted: true,
  active_until: Time.now + 1.year,
  confirmed_at: Time.now
})


User.all.each do |user|
  user.encounter_types.each do |encounter_type|
    user.encounters.create!(encounter_type: encounter_type, encountered_on: Time.zone.today)
    user.encounters.create!(encounter_type: encounter_type, encountered_on: 7.days.ago)
  end
end


### Stats logging
Organization.all.each do |organization|
  puts "**** Created #{organization.users.count} users for #{organization.name}!"
  puts "**** Created #{organization.items.count} items for #{organization.name}!"
end

User.all.each do |user|
  puts "**** Created #{user.encounters.count} encounters for #{user.name}!"
end
