require 'spec_helper'
require 'torrent_client'
describe VideoTorrentInfo::TorrentClient do
  let(:torrent) { 'spec/fixtures/test3.torrent' }
  let(:target) { '/tmp/44.2015.WEB-DLRip.1.46GB.avi' }
  let(:port1) { 8661 }
  let(:port2) { port1 + 1 }
  let(:path) { '/tmp' }
  let(:size) { 100000 }
  let(:timeout) { 60 }
  subject { VideoTorrentInfo::TorrentClient.new }
  context 'when #load' do
    context 'with wrong file' do
      specify do
        expect { subject.load('abra', 0, size, 'cadabra', port1, port2, 60) }.to raise_error('failed to load torrent info: No such file or directory')
      end
    end
    context 'with good file' do
      context 'part file' do
        before do
          subject.load(torrent, 0, size, path, port1, port2, timeout)
        end
        after do
          File.unlink(target) rescue nil
        end
        specify do
          expect(File.exist?(target)).to be_truthy
        end
      end
    end
  end
end