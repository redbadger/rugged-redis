require 'bundler/cli'
require 'mkmf'

$CFLAGS << " #{ENV["CFLAGS"]}"
$CFLAGS << " -g"
$CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
$CFLAGS << " -Wall -Wno-comment"

def sys(cmd)
  puts " -- #{cmd}"
  unless ret = xsystem(cmd)
    raise "ERROR: '#{cmd}' failed"
  end
  ret
end

if !find_executable('cmake')
  abort "ERROR: CMake is required to build Rugged."
end

if !(MAKE = find_executable('gmake') || find_executable('make'))
  abort "ERROR: GNU make is required to build Rugged."
end

CWD = File.expand_path(File.dirname(__FILE__))
ROOT_DIR = File.join(CWD, '..', '..', '..')

REDIS_BACKEND_DIR = File.join(ROOT_DIR, 'vendor', 'libgit2-backends', 'redis')

# TODO support pure gem install
Bundler::CLI.new.invoke(:install)
gem_root = Bundler.definition.specs.detect { |s| s.name == 'rugged' }.full_gem_path

RUGGED_EXT_DIR = File.join(gem_root, 'ext', 'rugged')
LIBGIT2_DIR = File.join(gem_root, 'vendor', 'libgit2')

# Build Redis backend

Dir.chdir(REDIS_BACKEND_DIR) do
  Dir.mkdir("build") if !Dir.exists?("build")

  Dir.chdir("build") do
    sys("cmake .. -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTS=OFF -DCMAKE_C_FLAGS=-fPIC -DPC_LIBGIT2_LIBRARY_DIRS=#{LIBGIT2_DIR}/build/ -DPC_LIBGIT2_INCLUDE_DIRS=#{LIBGIT2_DIR}/include/")
    sys(MAKE)
  end
end

$LIBPATH.unshift "#{REDIS_BACKEND_DIR}/build"

# Include rugged's header for the backend interface definition

$CFLAGS << " -I#{RUGGED_EXT_DIR}"

# Link against rugged's libgit2

$CFLAGS << " -I#{LIBGIT2_DIR}/include"
$LIBPATH.unshift "#{LIBGIT2_DIR}/build"

unless have_library 'git2-redis'
  abort "ERROR: Failed to build libgit2 redis backend"
end

unless have_library 'hiredis'
  abort "ERROR: Missing hiredis library"
end

create_makefile("rugged/redis/rugged_redis")
