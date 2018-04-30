require "./supervisor/*"

module Super
  class Visor
    property children : Hash(String, Process)
    property bus : Channel(Message)

    def initialize
      @children = {} of String => Process
      @bus = Channel(Message).new
      spawn(run)
    end


    def start_supervised(name : String, &block)
      @children[name] = begin
        p = Process.new(name, bus, &block)
        p.run
        p
      end
      # Yield immediately so the process can start running
      Fiber.yield
    end

    def run
      loop do
        puts "waiting for messages"
        message = @bus.receive
        puts message.inspect
        case message.event
        when Message::Event::EXCEPTION
          @children[message.owner].run
        end
        Fiber.yield
      end
    end


    # Keep the process alive by infinitely looping, but yielding immediately.
    def keep_alive
      loop{ Fiber.yield }
    end
  end
end


sv = Super::Visor.new

sv.start_supervised("sleep then raise") do
  sleep(2)
  raise "forced broken"
end

sv.start_supervised("another sleeper") do
  sleep(3)
  raise "forced broken"
end

sv.keep_alive
