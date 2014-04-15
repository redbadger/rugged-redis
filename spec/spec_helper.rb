require 'bundler/setup'
Bundler.setup

require 'rugged-redis'
include Rugged::Redis

puts "Recompiling extension...\n"
`rake compile`

RSpec.configure do |config|
end
