module Honcho
  struct Process
    property name : String
    property supervisor : Channel(Message)
    property proc : ->
    property fiber : Fiber?

    def initialize(@name : String, @supervisor : Channel(Message), &@proc : ->)
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
