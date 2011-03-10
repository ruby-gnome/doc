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
    
#    @source = Gst::ElementFactory.make("audiotestsrc")
#    @source.freq = 1000
#    @source.volume = 1.0
#    @source.wave = 0
    
    @samples_per_pixel = 1
    @samples = 300
    
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
      image.alpha_blending = true
      
      width = @sink.get_pad("sink").negotiated_caps[0]["width"]
      depth = @sink.get_pad("sink").negotiated_caps[0]["depth"]
      signed = @sink.get_pad("sink").negotiated_caps[0]["signed"]
      endianness = @sink.get_pad("sink").negotiated_caps[0]["endianness"]
      channels = @sink.get_pad("sink").negotiated_caps[0]["channels"]
      
      height_per_channel = height / channels

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


      image.draw do |pen|
        pen.color = GD2::Color[1.0, 1.0, 1.0]
        pen.fill

        pen.color = GD2::Color[0, 0, 0]

        i = 0

        sample = 0
        spp_counter = 0
        
        channel = 0
        
        tmp = []
        tmp2 = []
        channels.times{|x| tmp[x] = []}
        
        loop do
          @sink.pull_buffer.data.each_byte do |b|
            puts b
            if i == width / 8 - 1

              tmp[channel][i] = b
              
              i = 0
              channel += 1

              if channel == channels
                channel = 0
                
                channels.times do |c|
                  val = wrapper.read tmp[c].collect{ |x| x.chr }.join
                  
                  if signed
                    y = (val * height_per_channel / (2 ** depth)) + height_per_channel/2 + c * height_per_channel
                  else
                    y = (val * height_per_channel / (2 ** depth)) + c * height_per_channel
                  end              
                  
                  # Store last Y position per channel
                  pen.move_to sample, tmp2[c] if tmp2[c]
                  tmp2[c] = y
                  pen.line_to sample, y

                  spp_counter += 1
                  
                  if spp_counter == @samples_per_pixel
                    sample += 1
                    spp_counter = 0
                  end
                end
                
              end
              
            else
              tmp[channel][i] = b
              i += 1
            end
          end

          
          if sample >= @samples
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
