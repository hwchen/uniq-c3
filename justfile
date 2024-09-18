build:
    c3c compile -O3 ./uniq.c3

benchmark:
    c3c compile -O3 ./uniq.c3 && hyperfine --warmup 10 \
    'cat /usr/share/dict/words | ./uniq'
