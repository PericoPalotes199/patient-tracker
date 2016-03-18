namespace :app do
  desc "Add existing labels as items to each organization"
  task add_items_to_orgs: :environment do
    organizations = Organization.all
    puts "Attempting to each of #{organizations.count} organizations."

    total = 0
    error_messages = []

    ActiveRecord::Base.transaction do
      organizations.each do |organization|
        organization.items.create(label: 'Adult: Inpatient',         active: true, position: 1)
        organization.items.create(label: 'Adult: ED',                active: true, position: 2)
        organization.items.create(label: 'Adult: ICU',               active: true, position: 3)
        organization.items.create(label: 'Adult: Inpatient Surgery', active: true, position: 4)
        organization.items.create(label: 'Pediatric: Inpatient',     active: true, position: 5)
        organization.items.create(label: 'Pediatric: Newborn',       active: true, position: 6)
        organization.items.create(label: 'Pediatric: ED',            active: true, position: 7)
        organization.items.create(label: 'Continuity: Inpatient',    active: true, position: 8)
        organization.items.create(label: 'Continuity: External',     active: true, position: 9)
        if organization.name == 'Swedish Family Med'
          organization.items.create(label: 'Adult: Inpatient and Ed', active: false, position: nil)
        end
        print "\nAdded #{organization.items.count} items to #{organization.name}."
      end
    end

    puts "\nAdded #{Item.count} items in total!"
  end
end
