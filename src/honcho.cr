require "./honcho/*"

module Honcho
  class Visor
    property children : Hash(String, Process)
    property bus : Channel(Message)

    def initialize
      @children = {} of String => Process
      @bus = Channel(Message).new
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
        handle_event(@children[message.owner], message.event)
      end
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
channel = Channel(Int32).new(4)

sv.start_supervised("provider", Honcho::Process::Mode::PERMANENT) do
  i = 0
  loop do
    i += 1
    puts "producer sent #{i}"
    channel.send(i)
  end
end

4.times do |n|
  sv.start_supervised("consumer#{n}", Honcho::Process::Mode::PERMANENT) do
    i = channel.receive
    puts "consumer#{n} received #{i}"
    sleep(1)
  end
end

sv.run
