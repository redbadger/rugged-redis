require 'bundler/setup'
Bundler.setup

puts "Recompiling extension...\n"
system("rake compile") or exit!

require 'rugged'

require 'rugged-redis'
include Rugged::Redis

RSpec.configure do |config|
end
