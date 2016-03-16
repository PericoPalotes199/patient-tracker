namespace :app do
  desc "Add each user to an org"
  task add_user_to_org: :environment do
    users = User.all
    puts "Attempting to add #{users.count} users to organizations."

    total = 0
    error_messages = []
    ActiveRecord::Base.transaction do
      users.each do |user|
        user.organization = Organization.find_by name: user.residency, kind: 'residency'
        if user.save
          total += 1
          print '.'
        else
          error_messages << user.errors.full_messages
        end
      end
    end

    puts "\nFinished adding #{total} users to organizations!"
    puts "\nErorrs encountered by users not updated: #{error_messages.uniq}"
  end
end
