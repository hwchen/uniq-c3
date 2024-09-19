module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

import bufio;

def Set = map::HashMap(<long, char>);

// TODO: weird, buffering stdin doesn't seem to increase speed
// TODO: change StdIn to BufReader
// TODO: solve segfault when not compiled with optimizations
// TODO: implement faster Set
fn void! main(String[] args) {
    // very basic args handling. stdin is if called with "-", else looks for filepath
    InStream in;
    // not sure why this can't be held in bufio::StdIn,
    //but caused intermittent clearing of the buf
    char[4096 * 100] inbuf;
    if (args[1] == "-")  {
        bufio::StdIn stdin;
        stdin.init(&inbuf);
        in = (InStream)&stdin;
    } else {
        File f = io::file::open(args[1], "r")!;
        ReadBuffer rdr;
        rdr.init(&f, &inbuf);
        in = (InStream)&f;
    }

    bufio::StdOut stdout;
    stdout.init();
    Set filter;
    filter.temp_init();
    @pool() {
        while (true) {
            char[]! line = bufio::treadline(.stream=in);
            if (catch excuse = line) {
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
    io::printfn("hit");
    stdout.flush()!;
}

fn long hash(char[] input) @inline {
    return hash::fnv64a::encode(input);
}
