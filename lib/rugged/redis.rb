require "rugged/redis/version"

module Rugged
  # FIXME remove this when rugged has it's own backend class
  class Backend
  end

  module Redis
  end
end

require "rugged/redis/rugged_redis"
