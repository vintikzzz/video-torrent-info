require 'rubygems'
require 'bundler'
require 'rake/extensiontask'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "video-torrent-info #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :compile => [:'compile:torrent_client']
task :spec => [:compile]
task :default => :spec

require 'rake/extensiontask'
Rake::ExtensionTask.new('torrent_client')
