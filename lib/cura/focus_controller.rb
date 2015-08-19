if Kernel.respond_to?(:require)
  require "cura/attributes/has_initialize"
  require "cura/attributes/has_attributes"
  require "cura/attributes/has_application"
end

module Cura
  
  class FocusController
    
    include Attributes::HasInitialize
    include Attributes::HasAttributes
    include Attributes::HasApplication
    
    def initialize(attributes={})
      @index = 0
      
      super
      
      # TODO: raise error if window or application is nil
    end
    
    # @method window
    # Get the window of the currently focused component.
    #
    # @return [Window]
    
    # @method window=(value)
    # Set the window of the currently focused component.
    #
    # @param [#to_i] value
    # @return [Window]
    
    attribute(:window) { |value| validate_window(value) }
    
    # @method index
    # Get the index of the currently focused component.
    #
    # @return [Integer]
    
    # @method index=(value)
    # Set the index of the currently focused component.
    # This will dispatch a Event::Focus instance to the object.
    #
    # @param [#to_i] value
    # @return [Integer]
    
    attribute(:index) { |value| set_index(value) }
    
    protected
    
    def validate_window(window)
      raise TypeError, "must be a Cura::Window" unless window.is_a?(Window)
      
      window
    end
    
    def set_index(value)
      index = value.to_i
      focusable_children = focusable_children_of(@window.root)
      index %= focusable_children.length
      
      @window.application.event_dispatcher.target = focusable_children[index]
      
      index
    end
    
    def update_focused_index(component)
      focusable_children = focusable_children_of(@window.root)
      
      @index = focusable_children.index(component)
    end
    
    # Recursively find all children which are focusable.
    def focusable_children_of(component)
      result = []
      
      component.children.each do |child|
        result << child if child.focusable?
        result << focusable_children_of(child) if child.respond_to?(:children)
      end
      
      result.flatten
    end
    
  end
  
end
