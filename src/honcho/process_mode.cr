module Honcho
  enum ProcessMode
    # The process is intended to run forever, and will always be restarted
    # after exiting, regardless of whether it exited normally or not.
    PERMANENT
    # The process is meant to run once, with no guarantee of successful
    # completion. The process will never be restarted.
    ONE_SHOT
    # The process is meant to run until successful completion. The process
    # will only be restarted if it exits abnormally.
    TRANSIENT
  end
end
