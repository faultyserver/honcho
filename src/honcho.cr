require "./ext/*"
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
        puts "Got exception from #{process.name}"
        # if process.mode.permanent? || process.mode.transient?
        #   process.run
        # end

        @children.each do |_, p|
          next if p == process
          puts "#{p.name}: #{p.alive?}"
          p.kill if p.alive?
        end
      end
    end
  end
end
