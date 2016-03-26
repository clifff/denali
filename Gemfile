source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails', '~> 4.2'

# Auth
gem 'omniauth-google-oauth2'

# Uploads
gem 'aws-sdk', '~> 1.64.0'
gem 'paperclip', '~> 4.3'

# Front-end things
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'autoprefixer-rails'
gem 'turbolinks'
gem 'htmlcompressor'
gem 'imgix'

# Misc
gem 'jbuilder', '~> 2.3'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'acts_as_list'
gem 'redcarpet'
gem 'sanitize'
gem 'exifr'
gem 'acts-as-taggable-on', '~> 3.4'
gem 'httparty'
gem 'httmultiparty'
gem 'kaminari'
gem 'figaro'
gem 'oauth'
gem 'htmlentities'

# Caching
gem 'dalli'

# Background Jobs
gem 'resque'
gem 'resque-scheduler'

# Social Networks
gem 'tumblr_client'
gem 'flickraw'
gem 'twitter'

group :production do
  gem 'passenger'
  gem 'pg'
  gem 'rails_12factor'
  gem 'newrelic_rpm'
  gem 'lograge'
end

group :development do
  gem 'web-console', '~> 2.1'
end

group :development, :test do
  gem 'scss-lint'
  gem 'foreman'
  gem 'byebug'
  gem 'spring'
  gem 'sqlite3'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'mock_redis'
end
