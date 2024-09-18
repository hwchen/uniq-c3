build:
    c3c compile -O3 ./uniq.c3

benchmark *args="":
    c3c compile -O3 ./uniq.c3 && hyperfine --warmup 10 {{args}} \
    './uniq < /usr/share/dict/words' \
    'ouniq < /usr/share/dict/words' \
    'runiq /usr/share/dict/words'
