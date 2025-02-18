set shell := ["bash", "-uc"]

hyperfine *args="":
    werk build -Dprofile=release && hyperfine --warmup 10 {{args}} \
    './target/uniq /usr/share/dict/words' \
    'ouniq /usr/share/dict/words' \
    'zuniq /usr/share/dict/words'

bench *args="":
    werk build -Dprofile=release && poop {{args}} \
    './target/uniq /usr/share/dict/words' \
    'ouniq /usr/share/dict/words' \
    'zuniq /usr/share/dict/words' \
    'runiq --filter=Naive /usr/share/dict/words' \
    'runiq --filter=Digest /usr/share/dict/words'

# quick sanity check
diff-test:
    werk build && diff <(./target/uniq - < /usr/share/dict/words) <(cat /usr/share/dict/words)
