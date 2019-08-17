class Fiber
  property? alive : Bool = true

  def kill
    Fiber.stack_pool.release(@stack)

    # Remove the current fiber from the linked list
    @@fibers.delete(self)

    # Delete the resume event if it was used by `yield` or `sleep`
    @resume_event.try &.free

    @alive = false
    Crystal::Scheduler.reschedule
  end
end
