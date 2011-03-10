#!/usr/bin/ruby
require 'gst'
Gst.init

class Mp3Converter
  def initialize(infile, outfile)
    @mainloop = GLib::MainLoop.new(GLib::MainContext.default, true);

    @pipeline = Gst::Pipeline.new("converter")
    
    @source = Gst::ElementFactory.make("filesrc")
    @source.location = infile 

    @convertor = Gst::ElementFactory.make("audioconvert")

    @encoder = Gst::ElementFactory.make("lame")

    @sink = Gst::ElementFactory.make("filesink")
    @sink.location = outfile

    @decoder = Gst::ElementFactory.make("decodebin")
    @decoder.signal_connect("new-decoded-pad") do | dbin, pad, is_last |
      pad.link @convertor.get_pad("sink")
      @convertor >> @encoder >> @sink
    end

    @pipeline.add @source, @decoder, @convertor, @encoder, @sink
    @source >> @decoder

    @pipeline.bus.add_watch do | bus, message |
      case message.type
        when Gst::Message::Type::ERROR
          $stderr.puts "Error"
          @mainloop.quit
          exit 1

        when Gst::Message::Type::EOS
          @pipeline.stop
          @mainloop.quit
          exit 0
      end
      true
    end
  end
  
  def convert
    @pipeline.play
    @mainloop.run
  end
  
  def stop
    @pipeline.stop
  end
end


def usage
    puts "Usage: #{__FILE__} infile outfile.mp3"
    exit 2
end


usage if ARGV.length != 2

converter = Mp3Converter.new ARGV[0], ARGV[1]

begin 
  converter.convert
rescue Interrupt 
  # Ctrl+C pressed
ensure
  converter.stop
end
