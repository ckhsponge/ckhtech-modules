rbenv exec bundle config set --local path app/vendor/bundle
rbenv exec bundle config set --local without development
rbenv exec bundle install
rbenv exec bundle clean
rbenv exec bundle config unset --local path
rbenv exec bundle config unset --local without
rbenv exec bundle install
