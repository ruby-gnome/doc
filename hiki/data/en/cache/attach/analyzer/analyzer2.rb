#!/usr/bin/ruby
require 'rubygems'
require 'gd2'
require 'bindata'
require 'gst'
Gst.init

class Analyzer
  def initialize(infile)
    @mainloop = GLib::MainLoop.new(GLib::MainContext.default, true);

    @pipeline = Gst::Pipeline.new("appsink")

    @samples_per_pixel = 40
    @samples = 10000
    
    
#    @source = Gst::ElementFactory.make("audiotestsrc")
#    @source.freq = 50
#    @source.volume = 0.7
#    @source.wave = 0
    
    @source = Gst::ElementFactory.make("filesrc")
    @source.location = infile 

    @convertor = Gst::ElementFactory.make("audioconvert")

    @sink = Gst::ElementFactory.make("appsink")

    @decoder = Gst::ElementFactory.make("decodebin")
    @decoder.signal_connect("new-decoded-pad") do | dbin, pad, is_last |
      pad.link @convertor.get_pad("sink")
      @convertor >> @sink
    end

    @pipeline.add @source, @decoder, @convertor, @sink
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
  
  def play
    @pipeline.play
    
    
    GLib::Timeout.add(50) do
      height = 600
      
      image = GD2::Image::TrueColor.new(@samples, height)
      
      width = @sink.get_pad("sink").negotiated_caps[0]["width"]
      depth = @sink.get_pad("sink").negotiated_caps[0]["depth"]
      signed = @sink.get_pad("sink").negotiated_caps[0]["signed"]
      endianness = @sink.get_pad("sink").negotiated_caps[0]["endianness"]
      channels = @sink.get_pad("sink").negotiated_caps[0]["channels"]
      
      height_per_channel = height / channels
      half_of_height_per_channel = height / channels / 2
      
      max_sample_value = 2 ** depth

      if endianness == 1234
        if width == 32
          wrapper = BinData::Int32le
        elsif width == 16
          wrapper = BinData::Int16le
        else
          raise RuntimeError, "TODO" #TODO
        end
      else
        if width == 32
          wrapper = BinData::Int32be
        elsif width == 16
          wrapper = BinData::Int16be
        else
          raise RuntimeError, "TODO" #TODO
        end
      end


      bwidth = width /8
      bdepth = depth /8
      
      last_y_positions = []

      pixel_y_min = []
      pixel_y_max = []
      
      x = 0
      
      loop_skip_bytes = bwidth * channels * @samples_per_pixel

      image.draw do |pen|
        pen.color = GD2::Color[1.0, 1.0, 1.0]
        pen.fill

        pen.color = GD2::Color[0, 0, 0]

        loop do
          buf = @sink.pull_buffer
          
          offset = 0
          
          while offset < buf.length
            channels.times do |channel|
              channel_offset = offset + channel * bwidth
              val = wrapper.read buf.data[channel_offset..channel_offset+bdepth]
              
              if signed
                y = (val * height_per_channel / max_sample_value) + half_of_height_per_channel + channel * height_per_channel
              else
                y = (val * height_per_channel / max_sample_value) + channel * height_per_channel
              end

              pen.move_to x, last_y_positions[channel] if last_y_positions[channel]
              last_y_positions[channel] = y
              pen.line_to x, y

            end
            
            x += 1
            
            
            offset += loop_skip_bytes
          end
          
          if x >= @samples
            puts "Finish"
            image.export(File.expand_path("~/out.png"))
            exit
          end
        end
      end
      
    end
    
    @mainloop.run
  end
  
  def stop
    @pipeline.stop
  end
end


def usage
    puts "Usage: #{__FILE__} infile"
    exit 2
end


usage if ARGV.length != 1

analyzer = Analyzer.new ARGV[0]

begin 
  analyzer.play
rescue Interrupt 
  # Ctrl+C pressed
ensure
  analyzer.stop
end
