require 'bencode'
require 'ffmpeg_video_info'
class VideoTorrentInfo
  autoload :TorrentClient, 'torrent_client'
  DEFAULTS = {
    port1: 8661,
    port2: 8662,
    temp_path: '/tmp',
    supported_extensions: %w{ .avi .mkv .mpg .mpeg .3gp .wmv .mov .flv .mts .mp4 },
    download_limit: 100000,
    timeout: 30
  }
  def initialize(params = {})
    @params = DEFAULTS.merge(params)
    @torrent_client = VideoTorrentInfo::TorrentClient.new
  end
  def load(torrent_path)
    dest = download_video(torrent_path)
    res = ::FFmpeg::Video.info(dest)
    File.unlink(dest)
    res
  end
  def download_video(torrent_path)
    string = File.open(torrent_path){ |file| file.read }
    torrent = string.bdecode
    files = get_video_files(torrent)
    @torrent_client.load(torrent_path, files.keys.first, @params[:download_limit], @params[:temp_path], @params[:port1], @params[:port2], @params[:timeout])
    @params[:temp_path] + '/' + files.values.first
  end
  def get_video_files(torrent)
    info = torrent['info']
    res = {}
    files = []
    if info['files'].nil?
      files = [info['name']]
    else
      files = info['files'].map { |e| ([info['name']] + e['path']).join('/') }
    end
    files.each do |f|
      if @params[:supported_extensions].include?(File.extname(f))
        res[files.index(f)] = f
      end
    end
    raise "No files supported" if res.empty?
    res
  end
end