require 'bundler/setup'
Bundler.setup

puts "Recompiling extension...\n"
`rake compile`

require 'rugged-redis'
include Rugged::Redis

RSpec.configure do |config|
end
