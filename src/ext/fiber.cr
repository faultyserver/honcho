class Fiber
  property? alive : Bool = true

  # This is literally just the ensure block of `Fiber.run`
  def kill
    {% if flag?(:preview_mt) %}
      Crystal::Scheduler.enqueue_free_stack @stack
    {% else %}
      Fiber.stack_pool.release(@stack)
    {% end %}

    # Remove the current fiber from the linked list
    Fiber.fibers.delete(self)

    # Delete the resume event if it was used by `yield` or `sleep`
    @resume_event.try &.free

    @alive = false
    Crystal::Scheduler.reschedule
  end
end
