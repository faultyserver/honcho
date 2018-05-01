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

    def initialize(@name : String, @supervisor : Channel(Message), @mode : Mode = Mode::PERMANENT, &@proc : ->)
    end

    # A process is considered "alive" so long as the channel connected to it
    # remains open.
    def alive? : Bool
      @channel.open?
    end

    def run
      puts "starting process"
      @fiber = spawn do
        @supervisor.send(Message.started(@name))
        @proc.call
        @supervisor.send(Message.finished(@name))
      rescue
        @supervisor.send(Message.exception(@name))
      end
    end
  end
end
