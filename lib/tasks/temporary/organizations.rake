namespace :app do
  desc "Add organization for every residency"
  task add_organization: :environment do
    residencies = User.pluck(:residency).uniq.reject(&:blank?)
    puts "Initiate adding #{residencies.size} organizations."

    ActiveRecord::Base.transaction do
      residencies.each do |residency|
        Organization.create(name: residency, kind: 'residency')
        print '.'
      end
    end

    puts "\nFinished adding #{Organization.count} organizations!"
  end
end
