module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;

def Set = map::HashMap(<long, char>);

fn void! main() {
    bufio::StdOut stdout;
    stdout.init();
    Set filter;
    filter.temp_init();
    @pool() {
        while (true) {
            char[]! line = io::treadline();
            if (catch line) { // causes segfault unless optimized?
                break;
            }
            long key = hash(line);
            if (filter.has_key(key)) {
                continue;
            } else {
                filter.set(key, 0);
                stdout.writen(line)!;
            }
        }
    };
    stdout.flush()!;
}

fn long hash(char[] input) @inline {
    return hash::fnv64a::encode(input);
}
