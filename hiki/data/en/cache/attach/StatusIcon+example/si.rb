#!/usr/bin/env ruby
# encoding: UTF-8

=begin
	Copyright 2009 Vincent Carmona

	you can redistribute this example and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
=end

=begin
This example displays a icon in tray and show how to manage interactions with the mouse.
Documentations on StatusIcon class are provided at http://ruby-gnome2.sourceforge.jp/hiki.cgi?cmd=view&p=Gtk%3A%3AStatusIcon .
=end

require 'gtk2'

###**************************###
## Displayed Icon
###**************************###
si=Gtk::StatusIcon.new
##use a stock image
si.stock=Gtk::Stock::DIALOG_INFO
##or a personnal one
#si.pixbuf=Gdk::Pixbuf.new('/path/to/image')
si.tooltip='StatusIcon'

###**************************###
## Handle left click on icon
###**************************###
si.signal_connect('activate'){|icon| icon.blinking=!(icon.blinking?)}

###**************************###
## Pop up menu on rigth click
###**************************###
##Build a menu
info=Gtk::ImageMenuItem.new(Gtk::Stock::INFO)
info.signal_connect('activate'){p "Embedded: #{si.embedded?}"; p "Visible: #{si.visible?}"; p "Blinking: #{si.blinking?}"}
quit=Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
quit.signal_connect('activate'){Gtk.main_quit}
menu=Gtk::Menu.new
menu.append(info)
menu.append(Gtk::SeparatorMenuItem.new)
menu.append(quit)
menu.show_all
##Show menu on rigth click
si.signal_connect('popup-menu'){|tray, button, time| menu.popup(nil, nil, button, time)}

###**************************###
## Handle scroll events
#* Need a recent gtk version (>=2.16 ?)
###**************************###
si.signal_connect('scroll-event'){|icon, event|
	modifier=event.state#A GdkModifierType indicating the state of modifier keys and mouse buttons
##Handle only control and shift key
	ctrl_shift=(Gdk::Window::CONTROL_MASK|Gdk::Window::SHIFT_MASK)
	mod=modifier&ctrl_shift
	case mod
	when 0
		print "(None)"
	when Gdk::Window::CONTROL_MASK
		print "Control+"
	when Gdk::Window::SHIFT_MASK
		print "Shift+"
	when (Gdk::Window::CONTROL_MASK|Gdk::Window::SHIFT_MASK)
		print "Control+Shift+"
	end
##Check for direction
	case event.direction
	when Gdk::EventScroll::UP
		print "up\n"
	when Gdk::EventScroll::DOWN
		print "down\n"
	end
}

###**************************###
## Main loop
###**************************###
Gtk.main
