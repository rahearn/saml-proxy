source "https://rubygems.org"

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Auth gems
gem "openid_connect", "~> 2.3"
gem "faraday-typhoeus", "~> 1.1"
gem "jwt", "~> 2.10"
gem "saml_idp", "~> 0.16"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end
gem "secure_headers", "~> 7.1"

group :development, :test do
  gem "rspec-rails", "~> 7.1"
  gem "dotenv-rails", "~> 3.1"
  gem "bundler-audit", "~> 0.9"
  gem "standard", "~> 1.43"
end
gem "rails_template_18f", group: :development

group :test do
  gem "climate_control", "~> 1.2"
  gem "vcr", "~> 6.3"
  gem "simplecov", "~> 0.22", require: false
  gem "ruby-saml", "~> 1.18"
end
