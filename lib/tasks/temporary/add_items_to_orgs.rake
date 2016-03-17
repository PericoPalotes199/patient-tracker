namespace :app do
  desc "Add existing labels as items to each organization"
  task add_items_to_orgs: :environment do
    organizations = Organization.all
    puts "Attempting to each of #{organizations.count} organizations."

    total = 0
    error_messages = []

    ActiveRecord::Base.transaction do
      organizations.each do |organization|
        organization.items.create(label: 'Adult Inpatient', active: true)
        organization.items.create(label: 'Adult ED', active: true)
        organization.items.create(label: 'Adult ICU', active: true)
        organization.items.create(label: 'Adult Inpatient Surgery', active: true)
        organization.items.create(label: 'Pediatric Inpatient', active: true)
        organization.items.create(label: 'Pediatric Newborn', active: true)
        organization.items.create(label: 'Pediatric ED', active: true)
        organization.items.create(label: 'Continuity Inpatient', active: true)
        organization.items.create(label: 'Continuity External', active: true)
        if organization.name == 'Swedish Family Med'
          organization.items.create(label: 'Adult Inpatient and Ed', active: false)
        end
        print "\nAdded #{organization.items.count} items to #{organization.name}."
      end
    end

    puts "Added #{Item.count} in total items!"
  end
end
