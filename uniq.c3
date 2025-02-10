module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;
import set;

fn int main(String[] args) {
    // very basic args handling. stdin is if called with "-", else looks for filepath
	if (args.len == 1) {
		io::eprintn("Please provide one arg: `-` for stdin, else filepath");
		return 1;
	}

    BufReader in;
    char[4096] inbuf;
    if (args[1] == "-")  {
        in.init(io::stdin(), &inbuf);
    } else {
        File! f = io::file::open(args[1], "rb");
		if (catch err = f) {
			io::eprintfn("Error opening file %s: %s", args[1], err);
			return 1;
		}
        in.init(&f, &inbuf);
    }

    bufio::StdOut stdout;
    char[4096] outbuf;
    stdout.init(&outbuf);
    set::Set filter;
	// if we let user set init capacity, must check for power of 2
    filter.init_capacity(8, allocator::heap());
	char[1024] line_buf;
    while (true) {
		char[]! line = bufio::readline(&in, &line_buf);
		if (catch err = line) {
			if (err == IoError.EOF) break;
			io::eprintfn("Error reading line: %s", err);
			return 1;
		}
		ulong key = fnv64a::encode(line);

		assert(key != 0); // TODO someday fix/fuzz this.
		if (filter.insert(key)) {
			if (catch err = stdout.writen(line)) {
				io::eprintfn("Error writing to stdout: %s", err);
			}
		}
    }
    if (catch err = stdout.flush()) {
		io::eprintfn("Error flushing stdout: %s", err);
		return 1;
	}
	return 0;
}
