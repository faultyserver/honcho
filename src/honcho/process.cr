module Honcho
  struct Process
    property name : String
    property supervisor : Channel(Message)
    property mode : ProcessMode
    # Number of seconds to wait before restarting this process
    property restart_delay : Float64
    property proc : ->
    property fiber : Fiber?
    property? alive : Bool

    def initialize(@name : String, @supervisor : Channel(Message), **options, &@proc : ->)
      @mode = options[:mode]? || ProcessMode::PERMANENT
      @restart_delay = (options[:delay]? || 0.0).to_f64
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
