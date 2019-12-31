# Honcho

Honcho is an in-application process<sup>1</sup> supervisor for Crystal, inspired by [erlang's `supervisor` module](http://erlang.org/doc/man/supervisor.html). Supervisors enable code to be aware of when things crash and automatically handle them in a variety of ways. For example:

- using the `group` strategy, and entire set of processes can be brought down and/or restarted when one child goes down.
- using the `transient` mode, a process can be restarted until it succeeds, regardless of how it crashes (or a sibling crashes and causes it to restart).
- using `delay`, restarts can be kept from overloading the system or breaking rate limits when code crashes by waiting a set period of time before restarting the process.

The real power of supervisors is the ability to group and nest them into trees of management that give full control over the lifetimes of every process in the tree. Strategies, modes, and delays can all be applied individually to every process in the tree, including supervisors themselves!

**This project is still _somewhat_ early in development. It should be usable, but lacks proper testing and many features. Use at your own discretion.**

Honcho is up-to-date as of Crystal 0.32.1 (released December 18th, 2019). Since this library relies on some internal behaviors, it is not guaranteed to work with future versions without an update to itself. However, as of version `0.1.0`, Honcho's monkey-patching is simply a copy-paste of [the `ensure` block of `Fiber.run`](https://github.com/crystal-lang/crystal/blob/633116c2f8de119bff142a05132ffbcda41db0a5/src/fiber.cr#L95-L110), so behavior should be predictable and even work in multi-threaded environments!

<sup>1</sup> In accordance with erlang's parlance, `process` in this context refers to a program-level flow of execution. This may be actual OS processes, threads, fibers, or any other concurrent execution mechanism the language provides.

# Notes

This project also [monkey patches the `Fiber` class](src/ext/fiber.cr) to allow supervisors to remotely kill off child fibers. This should be fairly safe, but could potentially cause issues. If you encounter anything abnormal, please [file an issue](https://github.com/faultyserver/honcho/issues/new) so it can be addressed.

# Usage

```crystal
require "honcho"

sv = Honcho::Visor.new(strategy: Honcho::Strategy::ISOLATED)

puts "Starting ISOLATED strategy example. Press Ctrl+C to exit."

sv.start_supervised("permanent service", mode: Honcho::ProcessMode::PERMANENT, delay: 3.0) do
  puts "permanent service running. will never go down"
  i = 1
  loop do
    sleep(0.4)
    puts "permanent service iteration number: #{i}"
    i += 1
  end
end

sv.start_supervised("broken service", mode: Honcho::ProcessMode::PERMANENT) do
  sleep(1)
  puts "| broken service going down. will restart."
  raise "exit abnormally"
end

sv.start_supervised("one shot service", mode: Honcho::ProcessMode::ONE_SHOT) do
  sleep(5)
  puts "> one shot service going down. will not restart"
  raise "exit abnormally"
end

sv.run
```

Running this example will output:

```
Starting ISOLATED strategy example. Press Ctrl+C to exit.
permanent service running. will never go down
permanent service iteration number: 1
permanent service iteration number: 2
| broken service going down. will restart.
permanent service iteration number: 3
permanent service iteration number: 4
| broken service going down. will restart.
permanent service iteration number: 5
permanent service iteration number: 6
permanent service iteration number: 7
| broken service going down. will restart.
permanent service iteration number: 8
permanent service iteration number: 9
| broken service going down. will restart.
permanent service iteration number: 10
permanent service iteration number: 11
permanent service iteration number: 12
> one shot service going down. will not restart
| broken service going down. will restart.
permanent service iteration number: 13
permanent service iteration number: 14
| broken service going down. will restart.
```

For more examples, check out the [samples directory](samples/).

# Installation

```yaml
dependencies:
  honcho:
    github: faultyserver/honcho
```

# See Also

[Earl](https://github.com/ysbaddaden/earl) is a library that implements Service objects for Crystal and provides much of the same functionality as Honcho, but does so by enforcing a structure on your application.

Earl is likely a better solution for your needs if you are:

- building a new application with Agent-based design in mind.
- not a fan of monkey-patching standard library features.
