# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a sample user
if Rails.env.development?
  User.find_or_create_by!(email: "test@example.com") do |user|
    user.name = "Test User"
    user.password = "password"
    user.password_confirmation = "password"
  end

  # Create some tags
  tags = %w[Rails Ruby API Sidekiq].each do |tag_name|
    Tag.find_or_create_by!(name: tag_name)
  end

  puts "✅ Seeded user and #{tags.count} tags"
end
