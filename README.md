# BenchVersion

## Current results

```
> mix run bench.exs
Compiling 1 file (.ex)
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
Number of Available Cores: 12
Available memory: 16 GB
Elixir 1.11.0-dev
Erlang 22.0

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 42 s

Benchmarking compiled requirement...
Benchmarking matching requirement...
Benchmarking requirement...

Name                           ips        average  deviation         median         99th %
matching requirement        2.13 K      468.76 μs    ±16.49%         460 μs         686 μs
compiled requirement        1.19 K      837.09 μs     ±6.95%         822 μs     1113.36 μs
requirement               0.0421 K    23776.66 μs     ±2.09%       23615 μs    25674.38 μs

Comparison:
matching requirement        2.13 K
compiled requirement        1.19 K - 1.79x slower +368.34 μs
requirement               0.0421 K - 50.72x slower +23307.90 μs

Memory usage statistics:

Name                    Memory usage
matching requirement       531.85 KB
compiled requirement       157.52 KB - 0.30x memory usage -374.33594 KB
requirement                250.99 KB - 0.47x memory usage -280.85938 KB

**All measurements for memory usage were the same**
```
