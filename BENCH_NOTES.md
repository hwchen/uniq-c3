# 2025-03-27

Note that zuniq uses pre-hash, as does runiq quick, which allows collisions.

Data generated using `jen` from github.com/whitfin/jen under MIT license. Template from github.com/whitfin/runiq under MIT license.

```
uniq-c3 txml|🈳 ❯ just big-hyperfine
cat bigdata/big.jsonl > /dev/null && werk build -Dprofile=release && hyperfine  'zuniq bigdata/big.jsonl' './target/uniq bigdata/big.jsonl' 'runiq --filter=simple bigdata/big.jsonl' 'runiq --filter=quick bigdata/big.jsonl'
[ ok ] build
Benchmark 1: zuniq bigdata/big.jsonl
  Time (mean ± σ):     13.728 s ±  0.168 s    [User: 11.057 s, System: 2.669 s]
  Range (min … max):   13.398 s … 14.038 s    10 runs

Benchmark 2: ./target/uniq bigdata/big.jsonl
  Time (mean ± σ):     11.972 s ±  0.107 s    [User: 9.886 s, System: 2.084 s]
  Range (min … max):   11.816 s … 12.176 s    10 runs

Benchmark 3: runiq --filter=simple bigdata/big.jsonl
  Time (mean ± σ):     29.735 s ±  0.089 s    [User: 24.126 s, System: 5.602 s]
  Range (min … max):   29.569 s … 29.867 s    10 runs

Benchmark 4: runiq --filter=quick bigdata/big.jsonl
  Time (mean ± σ):     17.581 s ±  0.112 s    [User: 13.619 s, System: 3.959 s]
  Range (min … max):   17.478 s … 17.833 s    10 runs

Summary
  ./target/uniq bigdata/big.jsonl ran
    1.15 ± 0.02 times faster than zuniq bigdata/big.jsonl
    1.47 ± 0.02 times faster than runiq --filter=quick bigdata/big.jsonl
    2.48 ± 0.02 times faster than runiq --filter=simple bigdata/big.jsonl
```

```
uniq-c3 txml|🈳 > just big-bench
cat bigdata/big.jsonl > /dev/null && werk build -Dprofile=release && poop  'zuniq bigdata/big.jsonl' './target/uniq bigdata/big.jsonl' 'runiq --filter=simple bigdata/big.jsonl' 'runiq --filter=quick bigdata/big.jsonl'
[ ok ] build
Benchmark 1 (3 runs): zuniq bigdata/big.jsonl
  measurement          mean ± σ            min … max           outliers         delta
  wall_time          13.5s  ±  103ms    13.5s  … 13.7s           0 ( 0%)        0%
  peak_rss           2.75GB ±  183KB    2.75GB … 2.75GB          0 ( 0%)        0%
  cpu_cycles         47.2G  ±  125M     47.0G  … 47.3G           0 ( 0%)        0%
  instructions       21.7G  ± 64.9      21.7G  … 21.7G           0 ( 0%)        0%
  cache_references    627M  ± 3.43M      624M  …  630M           0 ( 0%)        0%
  cache_misses        212M  ±  495K      211M  …  212M           0 ( 0%)        0%
  branch_misses      75.8M  ± 43.7K     75.8M  … 75.8M           0 ( 0%)        0%
Benchmark 2 (3 runs): ./target/uniq bigdata/big.jsonl
  measurement          mean ± σ            min … max           outliers         delta
  wall_time          11.7s  ± 65.8ms    11.6s  … 11.7s           0 ( 0%)        ⚡- 13.6% ±  1.4%
  peak_rss           2.43GB ± 59.7KB    2.43GB … 2.43GB          0 ( 0%)        ⚡- 11.6% ±  0.0%
  cpu_cycles         42.2G  ±  247M     41.9G  … 42.4G           0 ( 0%)        ⚡- 10.5% ±  0.9%
  instructions       17.1G  ± 64.1K     17.1G  … 17.1G           0 ( 0%)        ⚡- 21.0% ±  0.0%
  cache_references    606M  ± 2.06M      604M  …  608M           0 ( 0%)        ⚡-  3.4% ±  1.0%
  cache_misses        203M  ±  835K      203M  …  204M           0 ( 0%)        ⚡-  4.1% ±  0.7%
  branch_misses      71.7M  ± 39.2K     71.7M  … 71.8M           0 ( 0%)        ⚡-  5.3% ±  0.1%
Benchmark 3 (3 runs): runiq --filter=simple bigdata/big.jsonl
  measurement          mean ± σ            min … max           outliers         delta
  wall_time          29.1s  ± 92.6ms    29.0s  … 29.2s           0 ( 0%)        💩+115.0% ±  1.6%
  peak_rss           2.67GB ±  293KB    2.67GB … 2.67GB          0 ( 0%)        ⚡-  2.9% ±  0.0%
  cpu_cycles         85.2G  ±  503M     84.7G  … 85.5G           0 ( 0%)        💩+ 80.7% ±  1.8%
  instructions       48.5G  ± 43.7K     48.5G  … 48.5G           0 ( 0%)        💩+124.1% ±  0.0%
  cache_references   1.90G  ± 13.9M     1.89G  … 1.92G           0 ( 0%)        💩+203.6% ±  3.6%
  cache_misses        287M  ± 3.57M      284M  …  291M           0 ( 0%)        💩+ 35.6% ±  2.7%
  branch_misses       253M  ± 2.82M      251M  …  256M           0 ( 0%)        💩+234.2% ±  6.0%
Benchmark 4 (3 runs): runiq --filter=quick bigdata/big.jsonl
  measurement          mean ± σ            min … max           outliers         delta
  wall_time          17.3s  ±  149ms    17.2s  … 17.5s           0 ( 0%)        💩+ 27.7% ±  2.1%
  peak_rss            456MB ±  219KB     456MB …  457MB          0 ( 0%)        ⚡- 83.4% ±  0.0%
  cpu_cycles         40.3G  ±  559M     39.9G  … 40.9G           0 ( 0%)        ⚡- 14.7% ±  1.9%
  instructions       20.8G  ± 77.2      20.8G  … 20.8G           0 ( 0%)        ⚡-  3.8% ±  0.0%
  cache_references    918M  ± 11.1M      906M  …  928M           0 ( 0%)        💩+ 46.3% ±  3.0%
  cache_misses       82.9M  ±  608K     82.3M  … 83.5M           0 ( 0%)        ⚡- 60.9% ±  0.6%
  branch_misses       178M  ±  696K      177M  …  179M           0 ( 0%)        💩+134.7% ±  1.5%
  ```
