module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;
import unordered_map;

fn int main(String[] args) {
	// very basic args handling. stdin is if called with "-", else looks for filepath
	if (args.len == 1) {
		io::eprintn("Please provide one arg: `-` for stdin, else filepath");
		return 1;
	}

	BufReader in;
	char[4096 *8] inbuf;
	if (args[1] == "-")  {
		in.init(io::stdin(), &inbuf);
	} else {
		File? f = io::file::open(args[1], "rb");
		if (catch err = f) {
			io::eprintfn("Error opening file %s: %s", args[1], err);
			return 1;
		}
		in.init(&f, &inbuf);
	}

	bufio::StdOut stdout;
	char[4096] outbuf;
	stdout.init(&outbuf);
	UnorderedMap{char[], bool} filter;
	filter.init(allocator::heap());

	// Note that if we use line_buf only instead of allocating for each line,
	// we're still effectively using the digest-hash strategy (as there's no
	// way to check for equality of the key). Also, when there's a collisions,
	// whether the key is-equal depends on whether the length of the previous view
	// into the buffer is the same as the current one. So it's kind of a crap shoot.
	//
	// But, there's still a way to do better than allocating all lines. We can only
	// allocate when setting a new key. This will have a big benefit if there's many
	// key collisions.
	//
	// I guess you can also immediately free, which should be pretty fast if it is just
	// a bump up and bump down.
	char[1024] line_buf;
	while (true) {
		char[]? line = bufio::readline(&in, &line_buf);
		if (catch err = line) {
			if (err == io::EOF) break;
			io::eprintfn("Error reading line: %s", err);
			return 1;
		}
		String key = ((String)line).copy(mem);
		if (filter.set(key, true)) {
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
