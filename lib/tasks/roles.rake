# frozen_string_literal: true

namespace :roles do
  desc "Seed default global roles and permissions"
  task seed: :environment do
    puts "Seeding default global roles..."

    Role.seed_global_roles!

    puts "✅ Default roles created successfully:"
    puts "  - superadmin (full system access)"
    puts "  - admin (organization management)"
    puts "  - moderator (content moderation)"
    puts "  - user (basic permissions)"
    puts ""
    puts "Total roles: #{Role.count}"
    puts "Total permissions: #{Permission.count}"
  end

  desc "List all roles and their permissions"
  task list: :environment do
    Role.includes(:permissions).each do |role|
      puts "\n#{role.name.upcase} (#{role.scope})"
      puts "=" * 50
      puts "Description: #{role.description}"
      puts "Permissions:"

      role.permissions.group_by(&:resource).each do |resource, permissions|
        actions = permissions.map { |p| "#{p.action}:#{p.scope}" }.join(", ")
        puts "  #{resource}: #{actions}"
      end
    end
  end

  desc "Assign superadmin role to a user by email"
  task :assign_superadmin, [:email] => :environment do |t, args|
    email = args[:email] || ENV['USER_EMAIL']

    unless email
      puts "❌ Error: Please provide user email"
      puts "Usage: rake roles:assign_superadmin[user@example.com]"
      puts "   or: USER_EMAIL=user@example.com rake roles:assign_superadmin"
      exit 1
    end

    user = User.find_by(email: email)

    unless user
      puts "❌ Error: User with email '#{email}' not found"
      exit 1
    end

    if user.add_role('superadmin')
      puts "✅ Successfully assigned superadmin role to #{user.email}"
    else
      puts "❌ Failed to assign superadmin role"
    end
  end
end
