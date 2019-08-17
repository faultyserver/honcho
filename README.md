# Honcho

Honcho is an in-application process supervisor for Crystal, inspired by [erlang's `supervisor` module](http://erlang.org/doc/man/supervisor.html).

**This project is still _very_ early in development. It should be usable, but lacks proper testing and many features. Use at your own discretion.**

Honcho is up-to-date as of Crystal 0.30.1 (released August 12th, 2019). Since this library relies on some internal behaviors, it is not guaranteed to work with future versions without an update to itself.


# Notes

Currently, there's an issue with debug information when compiling the `Fiber` extensions. To avoid this, you'll need to compile/run your applications with `--no-debug`.

This project also [monkey patches the `Fiber` class](src/ext/fiber.cr) to allow supervisors to remotely kill off child fibers. This should be fairly safe, but could potentially cause issues. If you encounter anything abnormal, please [file an issue](https://github.com/faultyserver/honcho/issues/new) so it can be addressed.


# Usage

Coming Soon. For the time being, check out the [samples](samples/).

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
