module set;
import std::io;
import wyhash;

macro ulong char[].myhash(char[] c) => wyhash::hash(0, c);

struct Entry {
	char[] key;
}

// uses high 7 bits of hash for fingerprint, as low bits are
// already used to find the index.
bitstruct Metadata: char {
	char fingerprint: 0..6;
	bool used: 7;
}

fn char take_fingerprint(ulong hash) @inline {
	return (char)(hash >> (64 - 7));
}

fn void Metadata.set_tombstone(&m) @inline {
	m.fingerprint = 1;
	m.used = false;
}

fn bool Metadata.is_tombstone(m) @inline {
	// depends on layout of bitstruct
	return (char)m == 1;
}

// Does not handle empty strings as keys.
struct Set (Printable) {
	Allocator allocator;
	usz count;
	Metadata[] metadatas;
	Entry[] entries;
}

fn void Set.init(&self, Allocator allocator, usz capacity = 16) {
	// check that capacity is a power of 2
	assert((capacity & (capacity - 1)) == 0, "capacity must be a power of 2");

	self.allocator = allocator;
	self.metadatas = allocator::new_array(self.allocator, Metadata, capacity);
	self.entries = allocator::new_array(self.allocator, Entry, capacity);
}

fn void Set.tinit(&self, int capacity = 16) {
	self.init(tmem);
}

fn bool Set.is_initialized(&self) {
	return (bool)self.allocator;
}

fn void Set.free(&self) {
	if (!self.allocator) return;
	allocator::free(self.allocator, self.metadatas);
	allocator::free(self.allocator, self.entries);
}

fn bool Set.is_empty(self) {
	return self.count == 0;
}

// returns true if entry already exists.
fn bool Set.insert(&self, char[] key) {
	// If the map isn't initialized, use the defaults to initialize it.
	if (!self.allocator) {
		self.init(tmem);
	}
	// max load 80%
	if ((float)self.count * 1.25 >= self.metadatas.len) {
		self.reallocator();
	}

	return self.add_entry(key);
}

fn bool Set.add_entry(&self, char[] key) @local {
	ulong hash = key.myhash();
	ulong mask = self.metadatas.len - 1;
	ulong idx = hash & mask;
	char fingerprint = take_fingerprint(hash);

	while (true) {
		if (!self.metadatas[idx].used) {
			self.metadatas[idx].used = true;
			self.metadatas[idx].fingerprint = fingerprint;
			self.count += 1;
			self.entries[idx].key = key;
			return true;
		}

		if (self.metadatas[idx].fingerprint == fingerprint) {
			char[] k = self.entries[idx].key;
			if (k == key) {
				return false;
			}
		}

		idx = (idx + 1) & mask;
	}
}

fn void Set.reallocator(&self) {
	Metadata[] old_metadatas = self.metadatas;
	self.metadatas = allocator::new_array(self.allocator, Metadata, old_metadatas.len * 2);
	Entry[] old_entries = self.entries;
	self.entries = allocator::new_array(self.allocator, Entry, old_entries.len * 2);

	usz old_count = self.count;
	self.count = 0;
	foreach (idx, metadata : old_metadatas) {
		if (metadata.used) {
			self.add_entry(old_entries[idx].key);
		}
		if (self.count == old_count) break;
	}

	allocator::free(self.allocator, old_metadatas);
	allocator::free(self.allocator, old_entries);
}

fn usz Set.len(&map) @inline {
	return map.count;
}

fn void? Set.remove(&self, char[] key) @maydiscard {
	if (!self.count) return NOT_FOUND?;
	ulong hash = key.myhash();
	ulong mask = self.metadatas.len - 1;
	ulong idx = hash & mask;
	char fingerprint = take_fingerprint(hash);

	while (true) {
		switch {
			case self.metadatas[idx].is_tombstone():
				break;
			case !self.metadatas[idx].used:
				return NOT_FOUND?;
			case self.metadatas[idx].fingerprint == fingerprint:
				if (self.entries[idx].key == key) {
					self.metadatas[idx].set_tombstone();
					self.count -= 1;
					return;
				}
		}
		idx = (idx + 1) & mask;
	}
}

fn void Set.clear(&self) {
	// TODO is this correct?
	mem::zero_volatile(bitcast(self.metadatas, char[]));
	//foreach (&metadata : self.metadatas) {
	//	*metadata = {};
	//}
	self.count = 0;
}
