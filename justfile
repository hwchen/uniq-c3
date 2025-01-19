set shell := ["bash", "-uc"]

# -O3 for optimized build
build *args="":
    c3c compile {{args}} uniq.c3 bufio.c3 set.c3

# -O3 for optimized build
run *args="":
    c3c compile-run {{args}} uniq.c3 bufio.c3 set.c3

test:
    c3c compile-test set.c3

# 4096_00 init capacity appears to be in a magic range for ouniq
# at 2^17 for c3, it beats zuniq.
hyperfine *args="":
    just build -O3 && hyperfine --warmup 10 {{args}} \
    './uniq /usr/share/dict/words' \
    'ouniq --initial-capacity 1024 < /usr/share/dict/words' \
    'ouniq --initial-capacity 4096_00 < /usr/share/dict/words' \
    'runiq /usr/share/dict/words' \
    'zuniq /usr/share/dict/words'

bench *args="":
    just build -O3 && poop {{args}} \
    './uniq /usr/share/dict/words' \
    'runiq /usr/share/dict/words' \
    'zuniq /usr/share/dict/words'

# quick sanity check
diff-test:
    just build && diff <(./uniq - < /usr/share/dict/words) <(cat /usr/share/dict/words)
