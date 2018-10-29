namespace :residencies do

  desc 'Associate all users to a residency record by residency attribute'
  task create: :environment do
    residency_names = User.all.pluck(:residency_name).uniq.reject(&:blank?)
    puts "Adding #{residency_names.count} residencies if they do not exist ..."
    residency_names.each do |residency_name|
      puts "Find or create #{residency_name} ..."
      Residency.find_or_create_by name: residency_name
      puts "... found or created."
    end
    puts "Done!"
  end

  task add_users: :environment do
    puts "Updating #{User.count} users and #{Residency.count} residencies ..."
    Residency.all.each do |residency|
      puts "Updating #{residency.name} ..."
      users = User.where(residency_name: residency.name)
      residency.users << users
      puts "... #{users.count} added to #{residency.name}."
    end
    puts "Done!"
  end

end
