set shell := ["bash", "-uc"]

# -O3 for optimized build
build *args="":
    c3c compile {{args}} -l ./lib/xxhash.a uniq.c3 bufio.c3 set.c3

# -O3 for optimized build
run *args="":
    c3c compile-run {{args}} -l ./lib/xxhash.a uniq.c3 bufio.c3 set.c3

test:
    c3c compile-test set.c3

hyperfine *args="":
    just build -O3 && hyperfine --warmup 10 {{args}} \
    './uniq /usr/share/dict/words' \
    'zuniq /usr/share/dict/words' \
    'ouniq --initial-capacity 1000000 < /usr/share/dict/words' \
    'runiq /usr/share/dict/words'

bench *args="":
    just build -O3 && poop {{args}} \
    './uniq /usr/share/dict/words' \
    'zuniq /usr/share/dict/words' \
    'runiq /usr/share/dict/words'

# quick sanity check
diff-test:
    just build && diff <(./uniq - < /usr/share/dict/words) <(cat /usr/share/dict/words)

# TODO use makefile? but this compilation pretty fast anyways
# I'll just vendor the xxhash.a and can regenerate when needed
# Decided not to submodule, just clone xxHash into repo root and run this recipe
# ref 3e321b4407318ac1348c0b80fb6fbae8c81ad5fa
build-xxhash:
    clang -c -O3 -o xxhash.o xxHash/xxhash.c -fPIC && ar r ./lib/xxhash.a xxhash.o
    rm xxhash.o
