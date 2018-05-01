module Honcho
  struct Message
    enum Event
      STARTED
      FINISHED
      EXCEPTION
    end

    {% for event in Event.constants %}
      def self.{{event.id.downcase}}(owner : String) : self
        new(owner, Event::{{event}})
      end
    {% end %}


    property owner : String
    property event : Event

    def initialize(@owner : String, @event : Event); end
  end
end
