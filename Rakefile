require "bundler/gem_tasks"
require "rake/extensiontask"
require "rspec/core/rake_task"

gemspec = Gem::Specification.load(File.expand_path("rugged-redis.gemspec", __dir__))

Rake::ExtensionTask.new "rugged_redis", gemspec do |ext|
  ext.lib_dir = "lib/rugged/redis"
  ext.ext_dir = "ext/rugged/redis"
end

RSpec::Core::RakeTask.new(:spec)

task :default => [:compile, :spec]
