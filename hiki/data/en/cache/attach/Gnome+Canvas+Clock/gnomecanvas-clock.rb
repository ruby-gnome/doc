#!/usr/bin/env ruby
#
# GnomeCanvas based analog clock widget
#
# Copyright (c) 2004 Geoff Youngs
#
# You can redistribute it and/or modify it under the terms of
# the Ruby's licence.

require 'gnomecanvas2'

class Clock < Gtk::VBox
  Point = Struct.new("Point", :x, :y)
  class Point
    def to_p
     [x,y]
    end
    def -(p)
      [x-p.x, y-p.y]
    end
  end
  def clockhandposition(center, len, val, max)
    angle = (Math::PI * (((val * 360.0) / max) - 90.0)) / 180.0
    Point.new(center.x + (len * Math.cos(angle)),
                         center.y + (len * Math.sin(angle)))
  end
  def basehandposition(center, len, val, max)
    angle = (Math::PI * ((val * 360.0) / max)) / 180.0
    Point.new(center.x + (len * Math.cos(angle)),
                         center.y + (len * Math.sin(angle)))
  end
  def setup_clock()
    topleft = Point.new(1.0,1.0)
    bottomright = Point.new(100.0, 100.0)
    center = Point.new(bottomright.x/2, bottomright.y/2)
    @face=Gnome::CanvasEllipse.new(@canvas.root, {:x1 => topleft.x,
                 :y1 => topleft.y,
                 :x2 => bottomright.x,
                 :y2 => bottomright.y,
                 :fill_color => "white",
                 :outline_color => "steelblue",
                 :width_pixels => 1})
    @radius = o = center.x * 0.50
    o  = @radius / 2
    @size =  center.x
    @knob=Gnome::CanvasEllipse.new(@canvas.root, {:x1 => center.x-o,
                 :y1 => center.y-o,
                 :x2 => center.x+o,
                 :y2 => center.y+o,
                 :fill_color_rgba => 0x00669933})

    @time = Time.now
    @hourh = Gnome::CanvasPolygon.new(@canvas.root,
                                          {:points => hourhand(center),
                                            :fill_color_rgba => 0x00000080,
                                            :join_style => Gdk::GC::JOIN_ROUND,
                                            :outline_color => "black"})
    @minuteh = Gnome::CanvasPolygon.new(@canvas.root,
                                          {:points => minutehand(center),
                                            :fill_color_rgba => 0x00000080,
                                            :join_style => Gdk::GC::JOIN_ROUND,
                                            :outline_color => "black"})
    @secondh = Gnome::CanvasPolygon.new(@canvas.root,
                                          {:points => secondhand(center),
                                            :fill_color_rgba => 0xff000080,
                                            :join_style => Gdk::GC::JOIN_ROUND,
                                            :outline_color => "red"})

                 
  end
  def hourhand(center)
    val = (@time.hour % 12) + (@time.min / 60.0)
    posn = clockhandposition(center, @radius * 0.6, val, 12)
    size = @radius * 0.08
    start = basehandposition(center, size, val, 12)
    retn = basehandposition(center, - size, val, 12)
    backp = clockhandposition(center, - size, val, 12)
    [start.to_p, posn.to_p, retn.to_p, backp.to_p]
  end
  def minutehand(center)
    posn = clockhandposition(center, [@radius - 4, @radius * 0.8].max, @time.min, 60)
    size = @radius * 0.03
    start = basehandposition(center, size, @time.min, 60)
    retn = basehandposition(center, -size, @time.min, 60)
    backp = clockhandposition(center, - size, @time.min, 60)
    [start.to_p, posn.to_p, retn.to_p, backp.to_p]
  end
  def secondhand(center)
    posn = clockhandposition(center, @radius * 0.9, @time.sec, 60)
    size = @radius * 0.01
    start = basehandposition(center, size, @time.sec, 60)
    retn = basehandposition(center, -size, @time.sec, 60)
    backp = clockhandposition(center, - size, @time.sec, 60)
    [start.to_p, posn.to_p, retn.to_p, backp.to_p]
  end
  def draw_clock(resize=false)
    return false if destroyed?
    setup_clock() unless defined?(@face)
    center = Point.new(@width/2, @height/2)
    
    if resize
      @face.x1, @face.y1 = center.x - @radius, center.y - @radius
      @face.x2, @face.y2 = center.x + @radius, center.y + @radius
      o = @radius * 0.5
      @knob.x1, @knob.y1 = center.x-o, center.y-o
      @knob.x2, @knob.y2 = center.x+o, center.y+o
    end
    @time = Time.now
    @hourh.points = hourhand(center)
    @minuteh.points = minutehand(center)
    @secondh.points = secondhand(center)
    @label.set_markup(sprintf("<small><small>%02i:%02i</small></small>",@time.hour, @time.min))
  end

  def initialize()
    super()
    @box = Gtk::EventBox.new
    pack_start(@box)
    @label = Gtk::Label.new
    @label.show
    pack_end(@label,false,false,0)
    set_border_width(@pad = 2)
    set_size_request((@width = 48)+(@pad*2), (@height = 48)+(@pad*2))
    @canvas = Gnome::Canvas.new(true)
    @box.add(@canvas)
    draw_clock()
    @box.signal_connect('size-allocate') { |w,e,*b| 
      @width, @height = [e.width,e.height].collect{|i|i - (@pad*2)}
      @size = [@width,@height].min
      @radius = @size / 2
      @canvas.set_size(@width,@height)
      @canvas.set_scroll_region(0,0,@width,@height)
      draw_clock(true)
      false
    }
    signal_connect_after('show') {|w,e| start() }
    signal_connect_after('hide') {|w,e| stop() }
    @canvas.show()
    @box.show()
    show()
  end
  def start
	@tid= Gtk::timeout_add(1000) { draw_clock(); true }
  end
  def stop
	Gtk::timeout_remove(@tid) if @tid
	@tid = nil
  end
  def set_bg(bg)
  	modify_bg(Gtk::STATE_NORMAL, bg)
  	@box.modify_bg(Gtk::STATE_NORMAL, bg)
  	@canvas.modify_bg(Gtk::STATE_NORMAL, bg)
  end
end


if $0 == __FILE__

class Viewer < Gtk::Window
  def initialize()
    super()
    set_title("Analog Clock")
    signal_connect("delete_event") { |i,a| Gtk::main_quit }
    set_default_size(200,220)
    add(Clock.new)
    show()
  end
end

Gtk.init()

view = Viewer.new
view.show

Gtk.main()
  
end


