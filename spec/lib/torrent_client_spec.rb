require 'spec_helper'
require 'torrent_client'
describe VideoTorrentInfo::TorrentClient do
  let(:torrent) { 'spec/fixtures/test.torrent' }
  let(:target) { '/tmp/Соседи.На тропе войны.(Logan1995).avi' }
  let(:port1) { 8661 }
  let(:port2) { port1 + 1 }
  let(:path) { '/tmp' }
  let(:size) { 100000 }
  let(:timeout) { 6000 }
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
          expect(File.exist?(target)).to be_true
        end
      end
      context 'full file' do
        let(:torrent) { 'spec/fixtures/test2.torrent' }
        let(:target) { '/tmp/Tom_&_Jerry/TOM-1/07. Мышонок-стратег.avi' }
        before do
          subject.load(torrent, 0, -1, path, port1, port2, timeout)
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
end