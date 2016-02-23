require 'rubygems'
require 'mkmf-rice'
require 'fileutils'
gem 'mini_portile2'
require 'mini_portile2'
module Net
  class HTTP
    alias old_initialize initialize
    def initialize(*args)
      old_initialize(*args)
      @read_timeout = 3 * 60
    end
  end
end
$CXXFLAGS = '' if $CXXFLAGS.nil?
$CPPFLAGS << ' -Wno-unused-result -Wno-deprecated-declarations -Wno-sign-compare -Wno-unused-variable'
message "Using mini_portile version #{MiniPortile::VERSION}\n"

class MyRecipe < MiniPortile
  def download_file_http(url, full_path, count = 3)
    filename = File.basename(full_path)
    message "Downloading %s from %s\n" % [filename, url]
    with_tempfile(filename, full_path) do |temp_file|
      OpenURI.open_uri(url, 'rb') do |io|
        temp_file << io.read
      end
    end
  end
end

class BoostRecipe < MyRecipe
  def configure
    return if configured?

    md5_file = File.join(tmp_path, 'configure.md5')
    digest   = Digest::MD5.hexdigest(computed_options.to_s)
    File.open(md5_file, "w") { |f| f.write digest }
    args = %W[
      --with-toolset=clang
      --without-libraries=python
      stage
      #{configure_prefix}
    ]
    execute('configure', %w(./bootstrap.sh) + args)
  end

  def make_cmd
    './b2'
  end
end

class OpenSSLRecipe < MyRecipe
  def configure
    return if configured?

    md5_file = File.join(tmp_path, 'configure.md5')
    digest   = Digest::MD5.hexdigest(computed_options.to_s)
    File.open(md5_file, "w") { |f| f.write digest }
    if RUBY_PLATFORM =~ /darwin/
      args = %W[
        darwin64-x86_64-cc
        enable-ec_nistp_64_gcc_128
        #{configure_prefix}
        shared
      ]
      execute('configure', %w(./Configure) + args)
    elsif RUBY_PLATFORM =~ /linux/
      args = %W[
        #{configure_prefix}
        shared
      ]
      execute('configure', %w(./config) + args)
    end
  end
end

class LibtorrentRecipe < MyRecipe
  def configure
    return if configured?

    md5_file = File.join(tmp_path, 'configure.md5')
    digest   = Digest::MD5.hexdigest(computed_options.to_s)
    File.open(md5_file, "w") { |f| f.write digest }
    execute('configure', %w(./bootstrap.sh) + computed_options)
  end
end

boost_recipe = BoostRecipe.new('boost', '1.60.0')
file = "http://downloads.sourceforge.net/project/boost/boost/#{boost_recipe.version}/boost_#{boost_recipe.version.gsub('.', '_')}.tar.gz"
boost_recipe.files = [file]

openssl_recipe = OpenSSLRecipe.new('openssl', '1.0.2f')
file = "https://www.openssl.org/source/openssl-#{openssl_recipe.version}.tar.gz"
openssl_recipe.files = [file]

libtorrent_recipe = LibtorrentRecipe.new('libtorrent', '1.0.8')
file = "https://codeload.github.com/arvidn/libtorrent/tar.gz/libtorrent-#{libtorrent_recipe.version.gsub('.', '_')}"
libtorrent_recipe.files = [file]
libtorrent_recipe.configure_options = %W[
  --enable-dht
  --with-openssl=#{openssl_recipe.path}
  --with-boost-libdir=#{boost_recipe.path}/lib
]

recipes = [boost_recipe, openssl_recipe, libtorrent_recipe]

recipes.each { |r| r.download }

recipes.each do |r|
  checkpoint = ".#{r.name}-#{r.version}.installed"
  unless File.exist?(checkpoint)
    r.cook
    FileUtils.touch(checkpoint)
  end
  r.activate
end

$LDFLAGS  << " -Wl,-rpath,#{recipes.map { |r| r.path + '/lib'}.join(':')}"

recipes.each do |r|
  $LDFLAGS << " -L#{r.path}/lib"
  $CPPFLAGS << " -I#{r.path}/include"
end

if RUBY_PLATFORM =~ /darwin/
  $LDFLAGS << " -g -O2 -ftemplate-depth=120 -fvisibility-inlines-hidden -Wl,-bind_at_load -ltorrent-rasterbar -lboost_system -lssl -lcrypto -lz"
  $CPPFLAGS << " -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -DHAVE_PTHREAD=1 -DHAVE_BOOST=1 -DHAVE_BOOST_SYSTEM=1 -DHAVE_GETHOSTBYNAME=1 -DNDEBUG=1 -DTORRENT_USE_OPENSSL=1 -DWITH_SHIPPED_GEOIP_H=1 -DBOOST_ASIO_HASH_MAP_BUCKETS=1021 -DBOOST_EXCEPTION_DISABLE=1 -DBOOST_ASIO_ENABLE_CANCELIO=1 -DBOOST_ASIO_DYN_LINK=1 -DTORRENT_BUILDING_SHARED=1 -I.  -ftemplate-depth-50 -Os -I/usr/local/include   -g -O2 -ftemplate-depth=120 -fvisibility-inlines-hidden"
elsif RUBY_PLATFORM =~ /linux/
  $LDFLAGS << " -g -O2 -fvisibility-inlines-hidden -ltorrent-rasterbar -lboost_system -lssl -lcrypto -lpthread"
  $CPPFLAGS << " -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DHAVE_PTHREAD=1 -DHAVE_BOOST=1 -DHAVE_BOOST_SYSTEM=1 -DHAVE_GETHOSTBYNAME=1 -DHAVE_GETHOSTBYNAME_R=1 -DGETHOSTBYNAME_R_RETURNS_INT=1 -DHAVE_CLOCK_GETTIME=1 -DNDEBUG=1 -DTORRENT_USE_OPENSSL=1 -DHAVE_LINUX_TYPES_H=1 -DHAVE_LINUX_FIEMAP_H=1 -DWITH_SHIPPED_GEOIP_H=1 -DBOOST_ASIO_HASH_MAP_BUCKETS=1021 -DBOOST_EXCEPTION_DISABLE=1 -DBOOST_ASIO_ENABLE_CANCELIO=1 -DBOOST_ASIO_DYN_LINK=1 -DTORRENT_BUILDING_SHARED=1 -I.  -ftemplate-depth-50 -Os -I/usr/include   -g -O2 -fvisibility-inlines-hidden"
end
create_makefile('torrent_client')
