# -O3 for optimized build
build *args="":
    c3c compile {{args}} uniq.c3 bufio.c3

# -O3 for optimized build
run *args="":
    c3c compile-run {{args}} uniq.c3 bufio.c3

benchmark *args="":
    just build -O3 && hyperfine --warmup 10 {{args}} \
    './uniq < /usr/share/dict/words' \
    'ouniq < /usr/share/dict/words' \
    'runiq /usr/share/dict/words'

# quick sanity check
test:
    just build -O3 && diff <(./uniq < /usr/share/dict/words) <(cat /usr/share/dict/words)
