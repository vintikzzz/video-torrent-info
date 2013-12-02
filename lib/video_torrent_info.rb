require 'bencode'
class VideoTorrentInfo
  autoload :TorrentClient, 'torrent_client'
  autoload :FFmpegVideoInfo, 'ffmpeg_video_info'
  DEFAULTS = {
    port1: 8661,
    port2: 8662,
    temp_path: '/tmp',
    supported_extensions: %w{ .avi .mkv .mpg .mpeg .3gp .wmv .mov .flv .mts },
    download_limit: 1000000
  }
  def initialize(params = {})
    @params = DEFAULTS.merge(params)
    @torrent_client = VideoTorrentInfo::TorrentClient.new
  end
  def load(torrent_path)
    string = File.open(torrent_path){ |file| file.read }
    torrent = string.bdecode
    files = get_video_files(torrent)
    @torrent_client.load(torrent_path, files.keys.first, @params[:download_limit], @params[:temp_path], @params[:port1], @params[:port2])
    dest = @params[:temp_path] + '/' + files.values.first
    res = FFmpegVideoInfo.get(dest) 
    File.unlink(dest)
    res
  end
  def get_video_files(torrent)
    info = torrent['info']
    res = {}
    files = []
    if info['files'].nil?
      files = [info['name']]
    else
      files = info['files'].map { |e| (info['name'] + path).join('/') }
    end
    files.each do |f|
      if @params[:supported_extensions].include?(File.extname(f))
        res[files.index(f)] = f
      end
    end
    res
  end
end