require 'spec_helper'
require 'video_torrent_info'
describe VideoTorrentInfo do
  subject { VideoTorrentInfo.new }
  context 'when #load' do
    context 'with good file' do
      specify do
        expect(subject.load('spec/fixtures/test3.torrent')['format_name']).to eql('avi')
      end
    end
  end
end