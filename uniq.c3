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
	char[4096 * 8] inbuf;
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
	char[4096 * 8] outbuf;
	stdout.init(&outbuf);
	Set filter;
	filter.init(mem);

	DynamicArenaAllocator key_arena;
	key_arena.init(mem, 4096 * 8);

	char[1024] line_buf;
	while (true) {
		char[]? line = bufio::readline(&in, &line_buf);
		if (catch err = line) {
			if (err == io::EOF) break;
			io::eprintfn("Error reading line: %s", err);
			return 1;
		}
		ulong hash = ((String)line).hash();
		if (!filter.contains_prehashed(hash, (String)line)) {
			String key = ((String)line).copy(&key_arena);
			filter.insert_prehashed(hash, key);
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
