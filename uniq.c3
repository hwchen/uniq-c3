module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;
import set;

fn void! main(String[] args) {
    // very basic args handling. stdin is if called with "-", else looks for filepath
    InStream in;
    char[1024] inbuf;
    if (args[1] == "-")  {
        bufio::StdIn stdin;
        stdin.init(&inbuf);
        in = (InStream)&stdin;
    } else {
        File f = io::file::open(args[1], "r")!;
        ReadBuffer rdr;
        rdr.init(&f, &inbuf);
        in = (InStream)&rdr;
    }

    bufio::StdOut stdout;
    char[1024] outbuf;
    stdout.init(&outbuf);
    set::Set filter;
	// if we let user set init capacity, must check for power of 2
    filter.init_capacity(8, allocator::temp());
	char[1024] line_buf;
    while (true) {
		char[]! line = bufio::readline(in, &line_buf);
		if (catch err = line) {
			if (err == IoError.EOF) break;
			return err?;
		}
		long key = line.hash();
		if (filter.insert(key)) {
			stdout.writen(line)!;
		}
    }
    stdout.flush()!;
}
