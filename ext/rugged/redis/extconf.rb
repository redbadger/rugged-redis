require 'mkmf'
require 'rubygems'
require 'rugged'

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
ROOT_DIR = File.expand_path(File.join(CWD, '..', '..', '..'))

REDIS_BACKEND_DIR = File.join(ROOT_DIR, 'vendor', 'libgit2-backends', 'redis')

rugged_spec = Gem::Specification.find {|s| s.name == 'rugged' }
rugged_root = rugged_spec.gem_dir
RUGGED_EXT_DIR = File.join(rugged_root, 'ext', 'rugged')
puts "Found rugged at #{RUGGED_EXT_DIR}"
LIBGIT2_DIR = File.join(rugged_root, 'vendor', 'libgit2')

# Build hiredis
HIREDIS_DIR = File.join(ROOT_DIR, 'vendor') # because hiredis headers are included as hiredis/hiredis.h
unless File.directory?(File.join(HIREDIS_DIR, 'hiredis'))
  STDERR.puts "vendor/hiredis missing, please checkout its submodule..."
  exit 1
end

system("cd #{HIREDIS_DIR}/hiredis && make static")

puts("Using hiredis from #{HIREDIS_DIR}/hiredis\n")
dir_config('hiredis', HIREDIS_DIR, File.join(HIREDIS_DIR, "hiredis"))
unless have_library('hiredis', 'redisConnect')
  abort "ERROR: Failed to build hiredis library"
end

# Build Redis backend

Dir.chdir(REDIS_BACKEND_DIR) do
  Dir.mkdir("build") if !Dir.exists?("build")

  Dir.chdir("build") do
    flags = [
      "-DBUILD_SHARED_LIBS=OFF",
      "-DBUILD_TESTS=OFF",
      "-DCMAKE_C_FLAGS=-fPIC",
      "-DPC_LIBGIT2_LIBRARY_DIRS=#{LIBGIT2_DIR}/build",
      "-DPC_LIBGIT2_INCLUDE_DIRS=#{LIBGIT2_DIR}/include",
      "-DPC_LIBHIREDIS_LIBRARY_DIRS=#{HIREDIS_DIR}/hiredis",
      "-DPC_LIBHIREDIS_INCLUDE_DIRS=#{HIREDIS_DIR}"
    ]
    sys("cmake .. #{flags.join(" ")}")
    sys(MAKE)
  end
end

puts "Using libgit2-redis from #{REDIS_BACKEND_DIR}/build\n"
$LIBPATH.unshift "#{REDIS_BACKEND_DIR}/build"

# Include rugged's header for the backend interface definition

puts "Using rugged headers from #{RUGGED_EXT_DIR}\n"
$CFLAGS << " -I#{RUGGED_EXT_DIR}"

# Link against rugged's libgit2

puts "Using libgit2 from #{LIBGIT2_DIR}/include and #{LIBGIT2_DIR}/build (rugged bundled)\n"
$CFLAGS << " -I#{LIBGIT2_DIR}/include"
$LIBPATH.unshift "#{LIBGIT2_DIR}/build"

unless have_library 'git2-redis'
  abort "ERROR: Failed to build libgit2 redis backend"
end

create_makefile("rugged/redis/rugged_redis")
