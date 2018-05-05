module Honcho
  class Visor
    property children : Hash(String, Process)
    property bus : Channel(Message)
    property strategy : Strategy
    property handler : Process, Message::Event ->

    def initialize(@strategy : Strategy = Strategy::ISOLATED)
      @children = {} of String => Process
      @bus = Channel(Message).new

      @handler =
        case @strategy
        when .isolated?
          ->handle_isolated(Process, Message::Event)
        when .unified?
          ->handle_unified(Process, Message::Event)
        else
          raise "Supervisor strategy #{@strategy} is not yet supported."
        end
    end


    def start_supervised(name : String, mode : ProcessMode = ProcessMode::PERMANENT, &block)
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
        @handler.call(@children[message.owner], message.event)
      end
    end

    private def handle_isolated(process : Process, event : Message::Event) : Nil
      case event
      when .finished?
        if process.mode.permanent?
          process.run
        end
      when .exception?
        puts "restarting #{process.name}"
        if process.mode.permanent? || process.mode.transient?
          process.run
        end
      end
    end

    private def handle_unified(process : Process, event : Message::Event) : Nil
      case event
      when .finished?
        if process.mode.permanent?
          process.run
        end
      when .exception?
        puts "restarting #{process.name}"

        @children.each do |_, p|
          next if p == process
          if p.mode.permanent? || p.mode.transient?
            p.restart if p.alive?
          else
            p.kill if p.alive?
          end
        end

        if process.mode.permanent? || process.mode.transient?
          process.run
        end
      end
    end
  end
end
