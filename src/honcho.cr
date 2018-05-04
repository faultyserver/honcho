require "./honcho/*"

class Fiber
  property? alive : Bool = true

  def kill
    @alive = false
  end

  def resume : Nil
    if !alive?
      remove
      return
    end

    previous_def
  end

  protected def remove
    @@stack_pool << @stack

    # Remove the current fiber from the linked list
    if prev_fiber = @prev_fiber
      prev_fiber.next_fiber = @next_fiber
    else
      @@first_fiber = @next_fiber
    end

    if next_fiber = @next_fiber
      next_fiber.prev_fiber = @prev_fiber
    else
      @@last_fiber = @prev_fiber
    end

    # Delete the resume event if it was used by `yield` or `sleep`
    @resume_event.try &.free

    Scheduler.reschedule
  end
end

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
