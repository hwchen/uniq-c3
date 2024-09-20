module set;

// Note: mem::new_array zeroes
// On laptop, bench time went from 64ms to  44ms

struct Set {
    int count;
    ulong[] entries;
}

fn void Set.init_capacity(&self, int capacity) {
    self.entries = mem::new_array(ulong, capacity);
}

// returns true if call sets entry. returns false if entry already exists
fn bool Set.insert(&self, ulong hash) {
    // max load 50%
    if ((self.count + 1) * 2 >= self.entries.len) {
        self.realloc();
    }
    ulong idx = hash % (ulong)self.entries.len;

    while (true) {
        ulong* entry = &self.entries[idx];
        if (*entry == hash) {
            return false;
        }
        if (*entry == 0) {     // TODO should actually bias, in case there's a zero-value hash
            self.count += 1;
            *entry = hash;
            return true;
        }
        idx = (idx + 1) % (ulong)self.entries.len;
    }
}

fn bool Set.contains(&self, ulong hash) {
    ulong idx = hash % (ulong)self.entries.len;

    while (true) {
        ulong entry = self.entries[idx];
        if (entry == hash) {
            return true;
        }
        if (entry == 0) {
            return false;
        }
        idx = (idx + 1) % (ulong)self.entries.len;
    }
}

fn void Set.realloc(&self) {
    ulong[] old_entries = self.entries;
    self.entries = mem::new_array(ulong, old_entries.len * 2);
    foreach(entry:old_entries) {
        self.insert(entry);
    }
    free(old_entries);
}

fn void! test_set() @test {
    // Not tested: 0 value, as that's the default. Will fix when impl biasing
    Set set;
    set.init_capacity(2);
    set.insert(1);
    set.insert(11);
    set.insert(11);

    assert(set.contains(1));
    assert(set.contains(11));
    assert(!set.contains(111));
}
