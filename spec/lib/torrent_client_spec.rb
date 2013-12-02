require 'spec_helper'
require 'torrent_client'
describe VideoTorrentInfo::TorrentClient do
  let(:target) { 'RIPD.3D.2013.BDRip1080p.halfOU(Killbrain)_[scarabey.org].mkv' }
  subject { VideoTorrentInfo::TorrentClient.new }
  context 'when #load' do
    context 'with wrong file' do
      specify do
        expect { subject.load('abra', 0, 1000000, 'cadabra', 8661, 8662) }.to raise_error('failed to load torrent info: No such file or directory')
      end
    end
    context 'with good file' do
      before do
        File.unlink(target)
        subject.load('spec/fixtures/test.torrent', 0, 1000000, './', 8661, 8662)
      end
      specify do
        expect(File.exist?(target)).to be_true
      end
    end
  end
end