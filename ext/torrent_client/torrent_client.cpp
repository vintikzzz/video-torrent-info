#include <stdlib.h>
#include <csignal>
#include <sstream>
#include <iostream>
#include <exception>
#include <stdio.h>
#include <unistd.h>
#include "libtorrent/entry.hpp"
#include "libtorrent/bencode.hpp"
#include "libtorrent/session.hpp"
#include "rice/Class.hpp"
#include "rice/Exception.hpp"

using namespace Rice;

struct MyException : public std::exception
{
   std::string s;
   MyException(std::string ss) : s(ss) {}
   ~MyException() throw () {}
   const char* what() const throw() { return s.c_str(); }
};
void term(int signum)
{
    exit(1);
}

void load(String torrent_path, int idx, int size, String save_path, int port1, int port2, int timeout)
{
  using namespace libtorrent;
  using namespace std;

  session s;
  libtorrent::error_code ec;
  std::ostringstream err;
  signal(SIGINT,  term);
  signal(SIGTERM, term);
  s.listen_on(std::make_pair(port1, port2), ec);
  if (ec)
  {
    err << "failed to open listen socket: " << ec.message().c_str();
    throw MyException(err.str());
  }
  add_torrent_params p;
  p.save_path = save_path.c_str();
  p.ti = new torrent_info(torrent_path.c_str(), ec);
  if (ec)
  {
    err << "failed to load torrent info: " << ec.message().c_str();
    throw MyException(err.str());
  }
  torrent_handle h = s.add_torrent(p, ec);
  if (ec)
  {
    err << "failed to add torrent: " << ec.message().c_str();
    throw MyException(err.str());
  }
  if (size > 0) {
    h.set_sequential_download(true);
  }
  int index = 0;
  for (torrent_info::file_iterator i = p.ti->begin_files(); i != p.ti->end_files(); ++i, ++index)
  {
    if (index == idx) {
      if (size > i->size) size = i->size;
    } else {
      h.file_priority(index, 0);
    }
  }

  size_type temp = 0;
  int t = 0;
  bool finish = false;

  while (true)
  {
    torrent_status st = h.status();
    if (st.is_finished == true) {
      finish = true;
    }
    if (st.total_done > temp)
    {
      // std::cout << st.total_done;
      temp = st.total_done;
    }
    if (size > 0 && temp >= size)
    {
      finish = true;
    }
    if (t >= timeout * 1000)
    {
      finish = true;
    }
    if (finish) {
      s.abort();
      return;
    }
    t++;
    usleep(1000);
  }
}
void handle_my_exception(std::exception const & ex)
{
  throw Exception(rb_eRuntimeError, ex.what());
}
extern "C"
void Init_torrent_client()
{
  Class rb_cVideoTorrentInfo = define_class("VideoTorrentInfo");
  Class rb_cTorrentClient =
    define_class_under(rb_cVideoTorrentInfo, "TorrentClient")
    .add_handler<MyException>(handle_my_exception)
    .define_method("load", &load);
}