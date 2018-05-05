module Honcho
  enum Strategy
    # Each child process is treated independently. If a child process crashes,
    # no other child processes are affected.
    #
    # This is most similar to the `one_for_one` strategy from erlang's
    # `supervisor` module.
    ISOLATED
    # All child processes are managed in a unified way, effectively treating
    # all child processes as a single process. If a child process crashes, all
    # other children are killed and restarted appropriately.
    #
    # This is most similar to the `one_for_all` strategy from erlang's
    # `supervisor` module.
    UNIFIED
  end
end
