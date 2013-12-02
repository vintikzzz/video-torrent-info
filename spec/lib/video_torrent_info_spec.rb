require 'spec_helper'
require 'video_torrent_info'
describe VideoTorrentInfo do
  subject { VideoTorrentInfo.new }
  context 'when #load' do
    context 'with good file' do
      specify do
        p subject.load('spec/fixtures/test.torrent')
      end
    end
  end
end