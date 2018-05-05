module Honcho
  struct Process
    property name : String
    property supervisor : Channel(Message)
    property mode : ProcessMode
    property proc : ->
    property fiber : Fiber?
    property? alive : Bool

    def initialize(@name : String, @supervisor : Channel(Message), @mode : ProcessMode = ProcessMode::PERMANENT, &@proc : ->)
      @alive = true
    end

    def kill
      @fiber.try(&.kill)
    end

    def restart
      kill
      run
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
