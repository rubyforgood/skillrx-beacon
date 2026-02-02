source "https://gem.coop"

gem "bootsnap", require: false
gem "image_processing", "~> 1.2"
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.2"
gem "turbo-rails"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "thruster", require: false

# gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
end
