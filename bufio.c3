module bufio;

import std::io;

struct StdOut {
    File* stdout;
    char[32] buffer;
    usz end;
}

fn void StdOut.init(&self) {
     self.stdout = std::io::stdout();
}

fn usz! StdOut.writen(&self, char[] s) {
    if (self.end + s.len + 1 >= self.buffer.len) {
        self.stdout.write(self.buffer[0:self.end])!;
        self.end = 0;
    }
    // io::printfn("%s", self.buffer[self.end:self.end]); // this causes an index out of bounds
    // so mem::copy just uses slice to end of buffer. It should use a pointer anyways.
    mem::copy(&self.buffer[self.end], s.ptr, s.len);
    self.end += s.len;
    self.buffer[self.end] = '\n';
    self.end += 1;
    return s.len + 1;
}

fn void! StdOut.flush(&self) {
    self.stdout.write(self.buffer[0:self.end])!;
    self.end = 0;
}
