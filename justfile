set shell := ["bash", "-uc"]

hyperfine *args="":
    werk build -Dprofile=release && hyperfine --warmup 200 {{args}} \
    'zuniq /usr/share/dict/words' \
    './target/uniq /usr/share/dict/words' \
    'runiq --filter=simple /usr/share/dict/words' \
    'runiq --filter=quick /usr/share/dict/words'

# Note that order matters, because on new laptop there's not enough warmup
bench *args="":
    werk build -Dprofile=release && poop {{args}} \
    'zuniq /usr/share/dict/words' \
    './target/uniq /usr/share/dict/words' \
    'runiq --filter=simple /usr/share/dict/words' \
    'runiq --filter=quick /usr/share/dict/words'

# quick sanity check
diff-test:
    werk build && diff <(./target/uniq - < /usr/share/dict/words) <(cat /usr/share/dict/words)

words:
    werk build && ./target/uniq - < /usr/share/dict/words

bigdata:
    jen template/basic.tera -l 25000000 > bigdata/big.jsonl

big-hyperfine *args="":
    cat bigdata/big.jsonl > /dev/null && \
    werk build -Dprofile=release && hyperfine {{args}} \
    'zuniq bigdata/big.jsonl' \
    './target/uniq bigdata/big.jsonl' \
    'runiq --filter=simple bigdata/big.jsonl' \
    'runiq --filter=quick bigdata/big.jsonl'

big-bench *args="":
    cat bigdata/big.jsonl > /dev/null && \
    werk build -Dprofile=release && poop {{args}} \
    'zuniq bigdata/big.jsonl' \
    './target/uniq bigdata/big.jsonl' \
    'runiq --filter=simple bigdata/big.jsonl' \
    'runiq --filter=quick bigdata/big.jsonl'
