terraform {
  before_hook "before_hook_1" {
    commands = ["apply"]
    execute  = ["rbenv", "exec", "bundle config set --local path 'app/vendor/bundle'"]
  }

  before_hook "before_hook_2" {
    commands = ["apply"]
    execute  = ["rbenv", "exec", "bundle install"]
  }
}
