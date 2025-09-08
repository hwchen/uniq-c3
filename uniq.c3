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

	BackedArenaAllocator* key_arena = allocator::new_backed_allocator(4096 * 8, mem)!!;

	char[1024] line_buf;
	while (true) {
		char[]? line = bufio::readline(&in, &line_buf);
		if (catch err = line) {
			if (err == io::EOF) break;
			io::eprintfn("Error reading line: %s", err);
			return 1;
		}
		usz mark = key_arena.mark();
		String key = ((String)line).copy(key_arena);
		if (filter.set(key, true)) {
			key_arena.reset(mark);
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
