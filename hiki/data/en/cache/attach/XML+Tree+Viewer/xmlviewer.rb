#!/usr/bin/env ruby
# XML Tree Viewer
#
# Copyright (c) 2003,2004 Masao Mutoh
#
# You can redistribute it and/or modify it under the terms of
# the Ruby's licence.
#
$KCODE="U"

require 'gtk2'
require 'rexml/document'

module Utils
  module_function
  def show_error_dialog(window, text)
    dialog = Gtk::MessageDialog.new(window, Gtk::Dialog::MODAL, 
                                    Gtk::MessageDialog::ERROR, 
                                    Gtk::MessageDialog::BUTTONS_CLOSE, text)
    dialog.run
    dialog.destroy
  end
end

class XmlTreeView < Gtk::TreeView
  TITLE = "XML Tree "
  def initialize
    @stocks = Hash["element", [Gtk::Stock::YES, "#000088"],
      "namespace", [Gtk::Stock::REMOVE, "#008800"],
      "text", [Gtk::Stock::NEW, "black"],
      "attribute", [Gtk::Stock::APPLY, "#AA9900"]]
    @ns = Hash.new

    @model = Gtk::TreeStore.new(Gdk::Pixbuf, String)
    super(@model)

    pix = Gtk::CellRendererPixbuf.new
    text = Gtk::CellRendererText.new
    text.editable = true
    text.editable_set = true
    text.mode = Gtk::CellRenderer::MODE_EDITABLE
    text.signal_connect("edited") do |cell, path, str|
      @model.get_iter(path).set_value(1, str)
    end

    @column = Gtk::TreeViewColumn.new
    @column.pack_start(pix, false)
    @column.set_cell_data_func(pix) do |column, cell, model, iter|
      cell.pixbuf = iter.get_value(0) 
    end
    @column.pack_start(text, true)
    @column.set_cell_data_func(text) do |column, cell, model, iter|
      begin
        Pango.parse_markup(iter.get_value(1))
        cell.markup = iter.get_value(1)
      rescue RuntimeError
        Utils.show_error_dialog(@parent_window, "#{$!}\n#{iter.get_value(1)}")
      end
    end
    @column.sort_column_id = 1
    append_column(@column)
    set_rules_hint(true)
  end

  def expand_all
    expand_row(Gtk::TreePath.new("0"), true)
  end

  def collapse_all
    collapse_row(Gtk::TreePath.new("0"))
  end

  def create_span(text, color)
     %Q[<span foreground="#{color}">#{text}</span>]
  end

  def create_iter(parent, stock, text)
    iter = @model.append(parent)
    iter.set_value(0, render_icon(@stocks[stock][0], Gtk::IconSize::MENU, text))
    iter.set_value(1, create_span(text, @stocks[stock][1]))
  end

  def create_attribute(attr, iter)
    ary = attr[0].split(/:/)
    if ary[0] =~ /xmlns/
      @ns["xml"] = "http://www.w3.org/XML/1998/namespace" unless @ns.has_key?("xml")
      create_iter(iter, "namespace", "#{ary[1]} = #{attr[1]}") if ary.size == 2
    else
      if ary.size == 2 and uri = @ns[ary[0]]
        text = "{#{uri}}#{ary[1]} (QName #{attr[0]}) = #{attr[1]}"
      else
        text = "#{attr[0]} = #{attr[1]}"
      end
      create_iter(iter, "attribute", text)
    end
  end

  def clear_tree
    @model.clear
    @ns.clear
  end

  def rebuild_tree(window, xmldata, filename)
    @parent_window = window
    clear_tree
    begin
      @model.freeze_notify
      create_tree(REXML::Document.new(xmldata).root)
    rescue REXML::ParseException
      Utils.show_error_dialog(@parent_window, $!)
    ensure
      @model.thaw_notify
      title = TITLE
      title += filename if filename
      @column.title = title
    end
    self
  end

  def create_tree(element, parent = nil)
    # Element
    if element.kind_of?(REXML::Element)
      # Namespace
      if element.namespace
        @ns["xml"] = "http://www.w3.org/XML/1998/namespace" unless @ns.has_key?("xml")
        str = "{#{element.namespace}} #{element.name}"
        prefix = element.prefix.size > 0 ? element.prefix : "#default"
        @ns[prefix] = element.namespace
        str += " (QName #{element.expanded_name})" if element.prefix.size > 0
      else
        str = element.name
      end

      iter = create_iter(parent, "element", str)

      # Attributes
      element.attributes.each{|*attr|
        create_attribute(attr, iter)
      }

      # Namespaces
      @ns.each{|key, value|
        create_iter(iter, "namespace", "#{key} = #{value}")
      } if @ns.size > 0

      # Children
      element.each{|v|
        create_tree(v, iter)
      }
    elsif element.kind_of?(REXML::Text)
      str = element.to_s.
        gsub(/&/, '&amp;').gsub(/"/, '&quot;').gsub(/</, '&lt;').gsub(/>/, '&gt;').
        gsub(/\r/, create_span('\r', '#AA4444')).
        gsub(/\n/, create_span('\n', '#AA4444') + "\n").
        gsub(/\t/, create_span('\t     ', '#FF5555')).
        gsub(/\n\s*$/, '')

      create_iter(parent, "text", str)
    end	
  end
end

class XmlTreeViewWindow < Gtk::Dialog
  def initialize(path)
    super("XML Tree Viewer for Ruby/GTK", nil, 
          Gtk::Dialog::MODAL|Gtk::Dialog::NO_SEPARATOR,
          [Gtk::Stock::OPEN, 0], ["Expand", 1], ["Collapse", 2], [Gtk::Stock::QUIT, 3])

    path = select_file if path.nil?
    tv = XmlTreeView.new.rebuild_tree(self, *read_file(path))
    vbox.add(Gtk::ScrolledWindow.new.add(tv))
    signal_connect("response") do |widget, response|
      case response
      when 0
        tv.rebuild_tree(self, *read_file(select_file))
      when 1
        tv.expand_all
      when 2
        tv.collapse_all
      when 3
        destroy
        Gtk.main_quit
      end
    end
  end

  def read_file(path)
    if path 
      if File.directory?(path)
        Utils.show_error_dialog(self, "Directory was selected. Select XML file.")
        ["", nil]
      else
        [File.open(path){|f| ret = f.readlines.join }, path] 
      end
    else
      ["", nil]
    end
  end

  def select_file
    filename = nil
    fs = Gtk::FileSelection.new("Open a XML file").set_modal(true).
      set_filename(Dir.pwd + "/").set_transient_for(self)
    fs.signal_connect("destroy") { Gtk.main_quit }
    fs.ok_button.signal_connect("clicked") do
      filename = fs.filename
      fs.destroy
      Gtk.main_quit
    end
    fs.cancel_button.signal_connect("clicked") do
      fs.destroy
      Gtk.main_quit
    end
    fs.show_all
    Gtk.main
    filename
  end
end

if $0 == __FILE__
  Gtk.init
  win = XmlTreeViewWindow.new(ARGV[0]).set_default_size(400, 400).show_all
  Gtk.main
end

