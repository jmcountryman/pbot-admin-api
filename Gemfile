source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use mongoid for pbot config storage
gem 'mongoid', '~> 7.0'
# Use Mongo as simple file storage
gem 'mongo', ' ~> 2.6'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

gem 'httparty', '~> 0.16.2' # HTTP requests
gem 'knock', '~> 2.1' # JWT
gem 'bcrypt', '~> 3.1' # knock dependency
gem 'pundit', '~> 2.0.1' # resource authorization

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :test do
  gem 'sqlite3', '~> 1.3.6'
end

group :development, :test do
  gem 'pry-rails'

  gem 'factory_bot_rails', '~> 4.11'
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
