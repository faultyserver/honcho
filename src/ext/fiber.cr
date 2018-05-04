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
