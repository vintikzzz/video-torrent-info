require 'spec_helper'
require 'torrent_client'
describe VideoTorrentInfo::TorrentClient do
  let(:target) { '/tmp/RIPD.3D.2013.BDRip1080p.halfOU(Killbrain)_[scarabey.org].mkv' }
  subject { VideoTorrentInfo::TorrentClient.new }
  context 'when #load' do
    context 'with wrong file' do
      specify do
        expect { subject.load('abra', 0, 1000000, 'cadabra', 8661, 8662) }.to raise_error('failed to load torrent info: No such file or directory')
      end
    end
    context 'with good file' do
      before do
        subject.load('spec/fixtures/test.torrent', 0, 1000000, '/tmp', 8661, 8662)
      end
      after do 
        File.unlink(target)
      end
      specify do
        expect(File.exist?(target)).to be_true
      end
    end
  end
end