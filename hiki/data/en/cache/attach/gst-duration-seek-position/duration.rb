#!/usr/bin/ruby
require 'gst'

Gst.init

class DurationMeter
  PIPELINE_NAME = "durationmeter"
  def initialize
    @pipeline = Gst::Pipeline.new PIPELINE_NAME

    @source = Gst::ElementFactory.make("filesrc")
    @source.location = ARGV[0]

    @convertor = Gst::ElementFactory.make("audioconvert")

    @sink = Gst::ElementFactory.make("alsasink")

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
          puts "Error"
          puts message.structure["debug"]
          
          @pipeline.stop

          exit 1

        when Gst::Message::Type::STATE_CHANGED
          if message.source.name == PIPELINE_NAME
            if message.structure["new-state"] == Gst::State::PLAYING
              puts "State changed to PLAYING"

              GLib::Timeout.add(100) do
                q = Gst::QueryPosition.new(Gst::Format::TIME)
                @pipeline.query(q)
                position = q.parse[1] / 1000000
                puts "Position: #{position} ms"
                
                if position > 2000 and position < 5000 # Seek to 5s after reaching 2s

                  $meter.position = 5000 # Not too pretty to use global variables, but it's only example

                  false # Stop this Timeout to avoid running multiple ones after seeking
                else
                  true
                end
              end

            elsif message.structure["new-state"] == Gst::State::READY
              puts "State changed to READY"

            elsif message.structure["new-state"] == Gst::State::NULL
              puts "State changed to NULL"

            elsif message.structure["new-state"] == Gst::State::PAUSED
              puts "State changed to PAUSED"

              q = Gst::QueryDuration.new(Gst::Format::TIME)
              @pipeline.query(q)
              puts "Total duration: #{q.parse[1]/1000000} ms\n\n"
                
            end
          end

        when Gst::Message::Type::EOS
          puts "End of stream"
          @pipeline.stop
          exit 0
      end
      true
    end
  end
  
  def play
    @pipeline.play
  end

  def position=(position_in_ms)
    puts "Seeking to #{position_in_ms} ms"
		@pipeline.send_event(Gst::EventSeek.new(1.0, Gst::Format::Type::TIME, Gst::Seek::FLAG_FLUSH.to_i | Gst::Seek::FLAG_KEY_UNIT.to_i, Gst::Seek::TYPE_SET, position_in_ms * 1000000, Gst::Seek::TYPE_NONE, -1))
  end
  
  def stop
    @pipeline.stop
  end
end

$meter = DurationMeter.new
$meter.play

$mainloop = GLib::MainLoop.new GLib::MainContext.default, true
$mainloop.run
