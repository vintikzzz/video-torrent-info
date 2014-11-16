require 'rubygems'
require 'bundler'
require 'rake/extensiontask'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "video-torrent-info"
  gem.homepage = "http://github.com/vintikzzz/video-torrent-info"
  gem.license = "MIT"
  gem.summary = %Q{Gets video info for the torrent file}
  gem.description = %Q{It simply loads small part of torrent that contains metadata and processes it with ffmpeg}
  gem.email = "fazzzenda@mail.ru"
  gem.authors = ["Pavel Tatarsky"]
  gem.extensions = %w[ext/torrent_client/extconf.rb]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "video-torrent-info #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/extensiontask'
Rake::ExtensionTask.new('torrent_client')
