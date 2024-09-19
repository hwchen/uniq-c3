module bufio;

import std::io;
import std::math;

struct StdOut {
    File* stdout;
    char[4096] buffer;
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

struct StdIn (InStream) {
    File* stdin;
    char[] buffer;
    usz start;
    usz end;
}

fn void StdIn.init(&self, char[]buf) {
    self.stdin = std::io::stdin();
    self.buffer = buf;
}

fn usz! StdIn.read(&self, char[] dest) @dynamic {
    usz dest_index = 0;

    while (dest_index < dest.len) {
        usz written = math::min(dest.len - dest_index, self.end - self.start);
        mem::copy(dest[dest_index..], self.buffer[self.start..], written);
        // somehow a read is still triggered even when we haven't gotten through the buffer yet
        // Looks like it's after an endline. Is there some weird interaction with treadline? Yes,
        // I had to pass StdIn to readline by pointer; doing it by value passed in a copy of the original
        // each time. Not sure why it was easy to miss this. I guess in Odin one struct controls the state,
        // but here it's passing a struct to a function.
        if (written == 0) {
            // buf empty, fill it
            usz n = self.stdin.read(self.buffer)!;
            if (n == 0) {
                // reading from the unbuffered stream returned nothing
                // so we have nothing left to read.
                return dest_index;
            }
            self.start = 0;
            self.end = n;
        }
        self.start += written;
        dest_index += written;
    }
    return dest.len;
}

fn char! StdIn.read_byte(&self) @dynamic {
    char[1] dest;
    usz n = self.read(&dest)!;
    // TODO should read return an error?
    if (n == 0) {
        return IoError.FILE_NOT_FOUND?;
    }
    return dest[0];
}

// Required because I can't seem to get StdIn to implement InStream. Copied from std.
macro String! readline(stream = io::stdin(), Allocator allocator = allocator::heap())
{
	bool $is_stream = @typeis(stream, InStream);
	$if $is_stream:
		$typeof(&stream.read_byte) func = &stream.read_byte;
		char val = func((void*)stream)!;
	$else
		char val = stream.read_byte()!;
	$endif

    if (val == '\n') return "";
    @pool(allocator)
    {
        DString str = dstring::temp_with_capacity(256);
    	if (val != '\r') str.append(val);
    	while (1)
    	{
    	    $if $is_stream:
    	        char! c = func((void*)stream);
    	    $else
    	        char! c = stream.read_byte();
    	    $endif
    		if (catch err = c)
    		{
    			if (err == IoError.EOF) break;
    			return err?;
    		}
    		if (c == '\r') continue;
    		if (c == '\n') break;
    		str.append_char(c);
    	}
    	return str.copy_str(allocator);
    };
}

// Required because I can't seem to get StdIn to implement InStream. Copied from std.
macro String! treadline(stream = io::stdin())
{
	return readline(stream, allocator::temp()) @inline;
}

