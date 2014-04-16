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
gem_root = Bundler.definition.specs.detect { |s| s.name == 'rugged' }.full_gem_path
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

unless have_library 'git2-redis'
  abort "ERROR: Failed to build libgit2 redis backend"
end

create_makefile("rugged/rugged_redis")
