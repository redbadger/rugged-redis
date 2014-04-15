# Redis backend for rugged

Enables rugged to store git objects and references into Redis.

### Warning

Although used in production, this is still fairly experimental and missing
support for various things. Especially the packed ODB backend.

## Installation

Add this line to your application's Gemfile:

    gem 'rugged-redis'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rugged-redis

**Note** that to use this you need a version of `rugged` that supports backends, which
is currently none. The redbadger fork will support redis backend soon.

```ruby
gem 'rugged', :git => 'https://github.com/redbadger/rugged', :branch => 'backends'
```

## Usage

Important thing to note is you can only use the redis backend for bare repositories.

Create the backend:

```ruby

require 'rugged-redis'

redis_backend = Rugged::Redis::Backend.new(host: '127.0.0.1', port: 6379, password: 'muchsecretwow')
```

and pass it to `rugged`:

```ruby
repo = Rugged::Repository.bare('repo-name', backend: redis_backend)
```

or

```ruby
repo = Rugged::Repository.init_at('repo-name', :bare, backend: redis_backend)
```

Each instance of the backend consumes a single Redis connection.

## Internals

Rugged Redis is written in C and interfaces with libgit2 on the C level.
This is done for perfomance reasons. The ruby wrapper servers as a
delivery mechanism for both the ODB and RefDB backend C structs which hold the
native functions implementing the storage itself. The C backend implementations come from the
libgit2/libgit2-backends project.

Both the ODB and RefDB objects are stored as hashes in Redis. The keys have the
following general structure:

```
rugged-redis:[repository_path]:odb:[object_sha1]
rugged-redis:[repository_path]:refdb:[reference_path]
```

### ODB

The ODB hashes have three keys:

*  `type` holds the object type as an integer (see `git_otype` in libgit2)
*  `size` is the size of the object in bytes
*  `data` holds the actual bytes of the object

### RefDB

The RefDB hashes have two keys:
*  `type` reference type as a number (`GIT_REF_OID` or `GIT_REF_SYMBOLIC` in libgit2)
*  `target` reference target as a string - either an OID as a string, or a symbolic target

### Redis connection

Both backends share a single Redis connection across all their instances, which is important
when you use a service that limits the number of connections. Each ruby process still gets its own
connection.

### Missing features

The redis backend doesn't yet support reflog. Rugged Redis is also currently the only test suite of the
backend implementation, which isn't ideal.

Another big missing feature is packed format support for ODB, which means no support for network
transfers or importing existing repos using packed format.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rugged-redis/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
