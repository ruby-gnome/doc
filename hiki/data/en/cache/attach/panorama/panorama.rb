#!/usr/bin/ruby
require 'gst'
Gst.init

class PanoramaMeter
  LEVEL_ELEMENT_NAME = "my_fancy_level_meter"
  METER_WIDTH = 74            # the meter will be ... characters width
  INTERVAL = 5000000          # how often update the meter? (in nanoseconds)
  METER_RESOLUTION = 1048576 
  
  def initialize(infile)
    @corrected_meter_width = METER_WIDTH % 2 == 0 ? METER_WIDTH + 1 : METER_WIDTH
    @meter_center = @corrected_meter_width / 2
       
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
          puts
          exit 1

        when Gst::Message::Type::EOS
          @pipeline.stop
          @mainloop.quit
          puts
          exit 0

        when Gst::Message::Type::ELEMENT
          if message.source.name == LEVEL_ELEMENT_NAME
            channels = message.structure["peak"].size
            x = []
            x[0] = "["
            x[@corrected_meter_width+2] = "]"
            (1..@corrected_meter_width+1).each{ |j| x[j] = " " }
            
            x[@meter_center] = "|"

            if channels == 1
              x[@meter_center] = "#"

            else 
              # Get absolute values of peak levels and normalize them to be 
              # always in range of 0...METER_RESOLUTION to avoid situation 
              # where e.g. L = -3dB and R = -1dB draws indicator much more
              # on the left side that in L = -9dB and R = -3dB.
              
              left = message.structure["peak"][0].abs
              right = message.structure["peak"][1].abs
              
              if not (left.infinite? or right.infinite?)
                if left == 0
                  position = @corrected_meter_width 

                elsif right == 0
                  position = 1

                else
                  max = left >= right ? left : right
                  left = (left * METER_RESOLUTION / max).round
                  right = (right * METER_RESOLUTION / max).round

                  if left > right
                    position = @meter_center - ((@corrected_meter_width * left / (right + left)).round - @meter_center)

                  elsif right > left
                    position = (@corrected_meter_width * right / (right + left)).round
                    
                  elsif left == right
                    position = @meter_center
                  end
                end
                x[position] = "#"
                $stderr.write "L #{x.join} R\r"
              end
            end
            
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

meter = PanoramaMeter.new ARGV[0]

begin 
  meter.play
rescue Interrupt 
  # Ctrl+C pressed
  puts 
ensure
  meter.stop
end
