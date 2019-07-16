Update: this project has been suspended and superceded by http://rebloom.io
===

TopK: an almost deterministic top k elements counter Redis module
===

The basic algorithm (1st one): https://www.cs.berkeley.edu/~satishr/cs270/sp11/rough-notes/Streaming-two.pdf

When TopK reaches cardinality of `k` and a new element needs to be added, the following eviction policy it practiced:
1. The frequencies of all existing observations are decreased by 1.
2. If there is an observation that can be evicted, it is replaced by the element.

Quick start guide
---

1. Build a Redis server with support for modules.
2. Build the TopK module: `make`
3. To load a module, Start Redis with the `--loadmodule /path/to/module.so` option, add it as a directive to the configuration file or send a `
MODULE LOAD` command.

TopK API
---

### `TOPK.ADD key k elem [elem ...]`

> Complexity: O(log(N)), where N is the size of the zset.

Adds elements to a topk zset.

`k` is the topk zset's maximal size. If `k` is zero, the topk zset has no size limit (sort of).

Notes:
  - elem can't begin with the prefix _'TOPK'_.
  - Using different a `k` from call to call is perfectly possible, and could be even interesting.
  - Optimization in the variadic form: first incr existing elements, then do one sweep of decr, then remove < 1 as needed. This may screw the probabilities (someone can probably dis/prove), **so just use non variadic calls to play safe if you want.**

An error is returned when:
  - The zset isn't a topk 
  - The operation requires running `TOPK.SHRINK` before.

**Reply:** Integer. If positive, it is the number of new elements added, if negative it is the number of elements removed due to k overflow, if 0 then only the offset was updated.

### `TOPK.PRANK key ele [ele ...]`

> Complexity: nasty
 
 Returns the percentile rank for the element.
 
 **Reply:** Array of Integers, nil if key or element not found

### `TOPK.PRANGE key from to [DESC|ASC]` 
> Complexity: nasty too

Returns the elements in the percentile range.

Both `from` and `to` must be between 0 and 100, and `from` must be less than or equal to `to`. The optional switch determines the reply's sort order, where `DESC` (the default) means ordering from highest to lowest frequency.

**Reply:** Array of strings.

### `TOPK.SHRINK key [k]`

> Complexity: O(N) where N is the number of members in the zset.

Resets the global offset after applying it to all members, trims size to `k` if specified and not zero.

**Reply:** String, "OK"

### `TOPK.DEBUG command key [arg]`

Debugging helper. `command` should be:

* `MAKE` - requires an integer `arg`, fills topk `key` with 1..`arg` observations with respective frequencies.
* `SHOW` - displays useful (?) information about the topk zset.

Contributing
---

Issue reports, pull and feature requests are welcome.

License
---

AGPLv3 - see [LICENSE](LICENSE)
