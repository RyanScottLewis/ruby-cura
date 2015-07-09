if Kernel.respond_to?(:require)
  require 'cura/attributes/has_initialize'
  require 'cura/attributes/has_attributes'
  require 'cura/attributes/has_application'
  require 'cura/attributes/has_events'
  require 'cura/event/base'
end

module Cura
  module Event
    
    # Polls or peeks for events since the last execution and dispatches them to the appropriate component.
    class Dispatcher
      
      include Attributes::HasInitialize
      include Attributes::HasAttributes
      include Attributes::HasApplication
      
      def initialize(attributes={})
        super
        
        raise ArgumentError, 'application must be set' if @application.nil?
        @target = @application if @target.nil?
        @wait_time = 0
      end
      
      # Get the time to wait for events in milliseconds.
      #
      # @return [Integer]
      attr_reader :wait_time
    
      # Set the time to wait for events in milliseconds.
      # Set to 0 to wait forever (poll instead of peek).
      #
      # @param [#to_i] value The new value.
      # @return [Integer]
      def wait_time=(value)
        value = value.to_i
        value = 0 if value < 0
      
        @wait_time = value
      end
      
      # Get the object with an event handler to dispatch events to.
      #
      # @return [Cura::Attributes::HasEvents]
      attr_reader :target
      
      # Set the object with an event handler to dispatch events to.
      #
      # @param [Cura::Attributes::HasEvents] value
      # @return [Cura::Attributes::HasEvents]
      def target=(value)
        raise TypeError, 'target must be a Cura::Attributes::HasEvents' unless value.is_a?(Attributes::HasEvents)
        
        @target = value
      end
      
      # Poll or peek for events and dispatch it if one was found.
      #
      # @return [Event::Dispatcher]
      def run
        event = @wait_time == 0 ? poll : peek(@wait_time)
        
        dispatch_event(event) unless event.nil?
      end
      
      # Wait forever for an event.
      #
      # @return [Event::Base]
      def poll
        @application.adapter.poll_event
      end
      
      # Wait a set amount of time for an event.
      #
      # @param [#to_i] milliseconds The amount of time to wait in milliseconds.
      # @return [nil, Event::Base] The event, if handled.
      def peek(milliseconds=100)
        @application.adapter.peek_event( milliseconds.to_i )
      end
      
      # Dispatch an event to the target or application, if the target is nil.
      #
      # @param [#to_sym] event The name of the event class to create an instance of or an event instance.
      # @param [#to_hash, #to_h] options
      # @option options [#to_i] :target The optional target of the event, overrides this dispatcher's #target value.
      # @return [Event::Base] The dispatched event.
      def dispatch_event(event, options={})
        event = Event.new_from_name(event) if event.respond_to?(:to_sym)
        raise TypeError, 'event must be an Event::Base' unless event.is_a?(Event::Base)
        
        options = options.to_hash rescue options.to_h
        
        if event.is_a?(Event::MouseDown) || event.is_a?(Event::MouseUp)
          component = @application.top_most_component_at( x: event.x , y: event.y )
          
          event.target = component
        end
         
        event.target ||= @target
        
        event.target.event_handler.handle(event)
        
        event
      end
      
    end
    
  end
end
