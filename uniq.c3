module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;
import set;

// TODO: weird, buffering stdin doesn't seem to increase speed
// TODO: change StdIn to BufReader
// TODO: odin reader_read_slice on buffered reader doesn't allocate. This probably accounts for last perf diff
// TODO: try compiling xxhash to static library
// [x] implement faster Set
// [x] solve segfault when not compiled with optimizations (filed bug https://github.com/c3lang/c3c/issues/1462)
fn void! main(String[] args) {
    // very basic args handling. stdin is if called with "-", else looks for filepath
    InStream in;
    char[4096 * 8] inbuf;
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
    char[4096 * 8] outbuf;
    stdout.init(&outbuf);
    set::Set filter;
    filter.init_capacity(16);
    while (true) {
        @pool() {
            char[]! line = bufio::treadline(stream:in);
            if (catch excuse = line) {
                break;
            }
            long key = hash(line);
            if (filter.contains(key)) {
                continue;
            } else {
                filter.insert(key);
                stdout.writen(line)!;
            }
        };
    }
    stdout.flush()!;
}

extern fn ulong xxhash(void* input, usz length, ulong seed) @extern("XXH64") @inline;
fn long hash(char[] input) @inline {
    return xxhash(&input[0], input.len, 0);
}
