#!/usr/bin/ruby
require 'gst'
Gst.init

class LevelMeter
  LEVEL_ELEMENT_NAME = "my_fancy_level_meter"
  MINIMUM_LEVEL = -60.0   # the scale range will be from this value to 0 dB, has to be negative
  METER_WIDTH = 70        # the meter will be ... characters width
  INTERVAL = 50000000    # how often update the meter? (in nanoseconds)
  
  def initialize(infile)
    @minimum_level_positive = -1 * MINIMUM_LEVEL # convert that only once, to save CPU power
  
    @mainloop = GLib::MainLoop.new(GLib::MainContext.default, true);

    @pipeline = Gst::Pipeline.new("levelmeter")
    
    @source = Gst::ElementFactory.make("filesrc")
    @source.location = infile 

    @convertor = Gst::ElementFactory.make("audioconvert")

    @level = Gst::ElementFactory.make("level", LEVEL_ELEMENT_NAME)
    @level.interval = INTERVAL
    @level.message = true

    @sink = Gst::ElementFactory.make("autoaudiosink")

    @decoder = Gst::ElementFactory.make("decodebin")
    @decoder.signal_connect("new-decoded-pad") do | dbin, pad, is_last |
      pad.link @convertor.get_pad("sink")
      @convertor >> @level >> @sink
    end

    @pipeline.add @source, @decoder, @convertor, @level, @sink
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

        when Gst::Message::Type::ELEMENT
          if message.source.name == LEVEL_ELEMENT_NAME
            channels = message.structure["peak"].size
            channels.times do |i|
              peak = message.structure["peak"][i] > MINIMUM_LEVEL ? (METER_WIDTH * (message.structure["peak"][i]) / @minimum_level_positive).round + METER_WIDTH : 0
              rms = message.structure["rms"][i] > MINIMUM_LEVEL ? (METER_WIDTH * (message.structure["rms"][i]) / @minimum_level_positive).round + METER_WIDTH : 0

              # Temporary array used to draw the bars. Maybe not too efficient but simple
              x = []
              x[0] = "["
              x[METER_WIDTH+2] = "]"

              (1..METER_WIDTH+1).each{ |j| x[j] = " " }
              (1..peak+1).each{ |j| x[j] = "=" }
              x[rms+1] = "#"
              x[peak+1] = "|"

              puts "#{i} #{x.join} peak: #{sprintf("%.2f", message.structure["peak"][i])}dB, RMS: #{sprintf("%.2f", message.structure["rms"][i])}dB"
            end
            xaxis_left = "  #{sprintf("%.2f", MINIMUM_LEVEL)}dB"
            xaxis_right = "0dB"
            
            puts xaxis_left + " " * (METER_WIDTH + 2 - xaxis_left.size) + xaxis_right
          end
      end
      true
    end
  end
  
  def play
    @pipeline.play
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

meter = LevelMeter.new ARGV[0]

begin 
  meter.play
rescue Interrupt 
  # Ctrl+C pressed
ensure
  meter.stop
end
