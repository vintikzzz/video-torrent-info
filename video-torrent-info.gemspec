lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'video_torrent_info/version'

Gem::Specification.new do |s|
  s.name          = "video-torrent-info"
  s.version       = VideoTorrentInfo::VERSION
  s.authors       = ["Pavel Tatarsky"]
  s.email         = ["fazzzenda@mail.ru"]
  s.summary       = "Gets video info for the torrent file"
  s.extensions    = ["ext/torrent_client/extconf.rb"]
  s.homepage      = "http://github.com/vintikzzz/video-torrent-info"
  s.license       = "MIT"

  s.required_ruby_version = '>= 1.9.3'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'ffmpeg-video-info'
  s.add_dependency 'bencode'
  s.add_dependency 'mini_portile2'

  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rice'

end
