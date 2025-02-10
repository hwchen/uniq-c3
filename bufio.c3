module bufio;

import std::io;
import std::math;

struct StdOut {
    File* stdout;
    char[] buffer;
    usz end;
}

fn void StdOut.init(&self, char[] buffer) {
    self.stdout = std::io::stdout();
    self.buffer = buffer;
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

struct BufReader {
	InStream wrapped_stream;
	char[] bytes;
	usz read_idx;
	usz write_idx;
}

fn void BufReader.init(&self, InStream stream, char[] buf) {
	self.wrapped_stream = stream;
	self.bytes = buf;
}

fn char! BufReader.read_byte(&self)
{
	if (self.read_idx == self.write_idx) {
		self.refill()!;
		if (self.read_idx == self.write_idx) return IoError.EOF?;
	}
	char c = self.bytes[self.read_idx];
	self.read_idx++;
	return c;
}

fn void! BufReader.refill(&self) @local @inline
{
	self.read_idx = 0;
	self.write_idx = self.wrapped_stream.read(self.bytes)!;
}

fn void! BufReader.close(&self) {
	return self.wrapped_stream.close();
}

// reads to a buf, instead of the std lib's reading to an allocation
macro char[]! readline(stream = BufReader, char[] buf)
{
	char val = stream.read_byte()!;

    if (val == '\n') return "";

	if (val != '\r') buf[0] = val;

	usz idx = 1;
	while (1)
	{
		char! c = stream.read_byte();
		if (catch err = c)
		{
			if (err == IoError.EOF) break;
			return err?;
		}
		if (c == '\r') continue;
		if (c == '\n') break;
		if (idx >= buf.len) return IoError.OUT_OF_SPACE?;
		buf[idx] = c;
		idx += 1;
	}
	return buf[0:idx];
}
