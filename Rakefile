require "bundler/gem_tasks"
require "rake/extensiontask"

gemspec = Gem::Specification::load(File.expand_path('../rugged-redis.gemspec', __FILE__))

Rake::ExtensionTask.new "rugged_redis", gemspec do |ext|
  ext.lib_dir = "lib/rugged/redis"
  ext.ext_dir = "ext/rugged/redis"
end
