module Honcho
  struct Process
    enum Mode
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

    property name : String
    property supervisor : Channel(Message)
    property mode : Mode
    property proc : ->
    property fiber : Fiber?
    property? alive : Bool

    def initialize(@name : String, @supervisor : Channel(Message), @mode : Mode = Mode::PERMANENT, &@proc : ->)
      @alive = true
    end

    def kill
      @fiber.try(&.kill)
    end

    def run
      @fiber = spawn do
        @alive = true
        @supervisor.send(Message.started(@name))
        @proc.call
        @alive = false
        @supervisor.send(Message.finished(@name))
      rescue ex
        @alive = false
        @supervisor.send(Message.exception(@name))
      end
    end
  end
end
