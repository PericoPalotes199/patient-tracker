namespace :app do
  desc "Add each user to an org"
  task add_user_to_org: :environment do
    users = User.all
    puts "Initiate adding #{User.count} users to organizations."

    ActiveRecord::Base.transaction do
      users.each do |user|
        user.organization = Organization.find_by name: user.residency, kind: 'residency'
        user.save
        print '.'
      end
    end

    puts "\nFinished adding #{User.count} users to organizations!"
  end
end
