require 'pathname'

LOG_PATH = Pathname.new(__FILE__).join( '..', '..', '..', 'debug.log' )
LOG_PATH.truncate(0) if LOG_PATH.exist?

require 'logger'
LOGGER = Logger.new(LOG_PATH)

require 'cura'

module HelloWorld
  class Application < Cura::Application
    
    on_event(:key_down) do |event|
      stop if event.key_name == :cancel # CTRL+C
    end
    
    def initialize(attributes={})
      super
      
      window = Cura::Window.new
      add_window(window)
      
      pack = Cura::Component::Pack.new( width: window.width, height: window.height, fill: true )
      window.add_child(pack)
      
      label_header = Cura::Component::Label.new( text: 'Cura', bold: true, underline: true, alignment: { horizontal: :center }, margins: { top: 1, bottom: 1 } )
      pack.add_child(label_header)
      
      label_hello = Cura::Component::Label.new( text: 'Hello, world!', alignment: { horizontal: :center } )
      pack.add_child(label_hello)
      
      label_hello_kanji = Cura::Component::Label.new( text: '今日は', alignment: { horizontal: :center }, margins: { bottom: 5 } )
      pack.add_child(label_hello_kanji)
      
      # textbox_1 = Cura::Component::Textbox.new( alignment: { horizontal: :center } )
      # pack.add_child(textbox_1)
      #
      # textbox_1.focus
    end
  
  end
end
