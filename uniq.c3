module uniq;

import std::collections::map;
import std::io;
import std::hash;

def Set = map::HashMap(<long, char>);

fn void! main() {
    Set filter;
    filter.temp_init();
    // TODO: input can be file or stdin
    while (true) {
        char[]! line = io::treadline();
        if (catch line) {
            if (line.len == 0) {
                return;
            }
        }
        //long key = hash(line);
        //if (filter.has_key(key)) {
        //    continue;
        //} else {
        //    filter.set(key, 0);
        //    io::printfn("%s", line);
        //}
        io::printfn("%s", line);
    }
}

fn long hash(char[] input) {
    return hash::fnv64a::encode(input);
}
