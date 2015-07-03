module TodoList
  
  class Sidebar < Cura::Component::Pack
    
    attr_reader :create_list_textbox
    
    def initialize(attributes={})
      attributes = { fill: true }.merge(attributes)
      
      super(attributes)
      
      header_pack = Cura::Component::Pack.new( orientation: :horizontal )
      add_child(header_pack)
      
      @create_list_textbox = Cura::Component::Textbox.new( width: (width/3).floor*2, margin: { right: 1 } )
      @create_list_textbox.on_event(:key_down, self) { |event, sidebar| sidebar.create_list if event.name == :enter }
      header_pack.add_child(@create_list_textbox)
      
      @create_list_button = Cura::Component::Button.new( width: (width/3).floor, text: 'Create', padding: { left: 1, right: 1 } )
      @create_list_button.on_event(:click, self) { |event, sidebar| sidebar.create_list }
      header_pack.add_child(@create_list_button)
      
      listbox_header_label = Cura::Component::Label.new( text: 'Lists', bold: true, underline: true, margin: { top: 1 } )
      add_child(listbox_header_label)
      
      @listbox = Cura::Component::Listbox.new( width: @width )
      @listbox.on_event(:key_down, self) do |event, sidebar|
        if event.control? && event.name == :D
          selected_object.destroy

          previous_selected_index = @selected_index
          sidebar.fill_listbox
          self.selected_index = [ previous_selected_index, count-1 ].min
        end
        
        if event.target == self && event.control? && event.name == :E
          selected_child.focusable = true
          selected_child.focus
        end
      end
      
      add_child(@listbox)
      
      fill_listbox
    end
    
    def create_list
      name = @create_list_textbox.text
      
      List.create( name: name )
      
      fill_listbox
      
      @create_list_textbox.clear
      @create_list_textbox.focus
    end
    
    def fill_listbox
      @listbox.delete_children
      
      List.all.each do |list|
        list_textbox = Cura::Component::Textbox.new( text: list.name, width: @listbox.width, background: Cura::Color.black, foreground: Cura::Color.white, focusable: false )
        list_textbox.on_event(:key_down, @listbox) do |event, listbox|
          if event.name == :enter
            list.name = text
            
            list.save
            
            self.focusable = false
            listbox.focus
          end
        end
        
        @listbox.add_child( list_textbox, list )
      end
    end
    
  end
  
end
