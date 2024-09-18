module uniq;

import std::collections::map;
import std::core::mem;
import std::io;
import std::hash;

def Set = map::HashMap(<long, char>);

fn void! main() {
    File* stdout = std::io::stdout();
    char[4096] stdout_buffer;
    usz stdout_len = 0;
    Set filter;
    filter.temp_init();
    @pool() {
        while (true) {
            char[]! line = io::treadline();
            if (catch line) {
                break;
            }
            long key = hash(line);
            if (filter.has_key(key)) {
                continue;
            } else {
                filter.set(key, 0);
                if (stdout_len + line.len + 1 >= stdout_buffer.len) {
                    stdout.write(stdout_buffer[0:stdout_len])!;
                    stdout_len = 0;
                }
                mem::copy(stdout_buffer[stdout_len:stdout_len + line.len], line.ptr, line.len);
                stdout_len += line.len;
                stdout_buffer[stdout_len] = '\n';
                stdout_len += 1;
            }
        }
    };
    stdout.write(stdout_buffer[0:stdout_len])!;
}

fn long hash(char[] input) @inline {
    return hash::fnv64a::encode(input);
}
