require "./honcho/*"

module Honcho
  class Visor
    property children : Hash(String, Process)
    property bus : Channel(Message)

    def initialize
      @children = {} of String => Process
      @bus = Channel(Message).new
      spawn(run)
    end


    def start_supervised(name : String, mode : Process::Mode = Mode::PERMANENT, &block)
      @children[name] = begin
        p = Process.new(name, bus, mode, &block)
        p.run
        p
      end
      # Yield immediately so the process can start running
      Fiber.yield
    end

    def run
      loop do
        message = @bus.receive
        puts message.inspect
        handle_event(@children[message.owner], message.event)
        Fiber.yield
      end
    end


    # Keep the parent process alive by infinitely looping, but always yielding
    # immediately.
    def keep_alive
      loop{ Fiber.yield }
    end


    private def handle_event(process : Process, event : Message::Event)
      case event
      when .finished?
        if process.mode.permanent?
          process.run
        end
      when .exception?
        if process.mode.permanent? || process.mode.transient?
          process.run
        end
      end
    end
  end
end


sv = Honcho::Visor.new

sv.start_supervised("permanent with raise", Honcho::Process::Mode::PERMANENT) do
  sleep(2)
  raise "forced broken"
end

sv.start_supervised("one shot with raise", Honcho::Process::Mode::ONE_SHOT) do
  sleep(3)
  raise "forced broken"
end

sv.start_supervised("permanent no raise", Honcho::Process::Mode::PERMANENT) do
  sleep(3)
end

sv.keep_alive
