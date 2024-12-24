module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;
import set;

// TODO: The slow operation is probably reallocation. At "magic number" 4096_00 on the benchmark, on chenbot, c3 is actually a bit faster than both odin and zig. This must mean reallocation of the set is extremely slow, check what zig does.

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
    filter.init_capacity(1024);
	char[1024] line_buf;
    while (true) {
		char[]! line = bufio::readline(in, &line_buf);
		if (catch err = line) {
			if (err == IoError.EOF) break;
			return err?;
		}
		long key = line.hash();
		if (filter.contains(key)) {
			continue;
		} else {
			filter.insert(key);
			stdout.writen(line)!;
		}
    }
    stdout.flush()!;
}
