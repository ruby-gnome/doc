#!/usr/bin/env ruby
#
require 'hwedit_glade'
require 'kconv'

class Hwedit < HweditGlade

  DEFAULT_FILECHARSET = Kconv::SJIS
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    super(path_or_data, root, domain, localedir, flag)
    @window = @glade['main_window']
    @editor = @glade['textview1']
    @filedialog = @glade['filechooser']
    @aboutdialog = @glade['aboutdialog']
    initialize_editor
  end
  def initialize_editor
    @filename = nil
    @filecharset = DEFAULT_FILECHARSET
    @editor.buffer.text = ""
    update_window_title
  end
  
  def on_new1_activate(widget)
    puts "on_new1_activate"
    initialize_editor
  end
  
  def on_open1_activate(widget)
    puts "on_open1_activate"
    show_opendialog
  end
  def show_opendialog
    @filedialog.action = Gtk::FileChooser::ACTION_OPEN
    @filedialog.title  = 'Open Dialog'
    if @filedialog.run == Gtk::Dialog::RESPONSE_OK
      if File.exist?(get_platform_filename(@filedialog.filename))
        @filename = @filedialog.filename
        read_file(@filename)
        update_window_title
      end
    end
    @filedialog.hide
  end
  def read_file(filename)
    text = ""
    File.open(get_platform_filename(filename)) do |f|
      text = f.readlines.join
    end
    @filecharset = Kconv.guess(text)
    if @filecharset == Kconv::UNKNOWN
      @filecharset = DEFAULT_FILECHARSET
    end
    @editor.buffer.text = Kconv.kconv(text, Kconv::UTF8, @filecharset)
    @editor.move_cursor(Gtk::MOVEMENT_BUFFER_ENDS, -1, false)
  end
  
  def on_save1_activate(widget)
    puts "on_save1_activate"
    if @filename
      save_file(@filename)
    else
      show_savedialog
    end
  end
  def on_save_as1_activate(widget)
    puts "on_save_as1_activate"
    show_savedialog
  end
  def save_file(filename)
    File.open(get_platform_filename(filename), 'w') do |f|
      f.write(Kconv.kconv(@editor.buffer.text, @filecharset, Kconv::UTF8))
    end
  end
  def show_savedialog
    @filedialog.action = Gtk::FileChooser::ACTION_SAVE
    @filedialog.title  = 'Save Dialog'
    loop do
      if @filedialog.run == Gtk::Dialog::RESPONSE_OK
        next unless @filedialog.filename
        if File.exist?(get_platform_filename(@filedialog.filename))
          next unless overwrite_file?(@filedialog.filename)
        else
          next unless filename_valid?(@filedialog.filename)
        end
        @filename = @filedialog.filename
        save_file(@filename)
        update_window_title
      end
      break
    end
    @filedialog.hide
  end
  def overwrite_file?(filename)
    dialog = Gtk::MessageDialog.new(
            @filedialog, Gtk::Dialog::MODAL,
            Gtk::MessageDialog::QUESTION,
            Gtk::MessageDialog::BUTTONS_OK_CANCEL,
            filename + "\n already exists. Do you overwrite it?")
    result = dialog.run
    dialog.destroy
    result == Gtk::Dialog::RESPONSE_OK
  end
  def filename_valid?(filename)
    begin
      File.open(get_platform_filename(filename), 'w') do |f| end
    rescue Errno::EINVAL => err
      p err
      dialog = Gtk::MessageDialog.new(
              @filedialog, Gtk::Dialog::MODAL,
              Gtk::MessageDialog::ERROR,
              Gtk::MessageDialog::BUTTONS_CLOSE,
              File.basename(filename) + " is an invalid file name.")
      dialog.run
      dialog.destroy
      return false
    end
    true
  end
  
  def update_window_title
    @window.title = 'Hello World Editor - ' + File.basename(@filename || 'untitled')
  end
  
  def get_platform_filename(filename)
    if RUBY_PLATFORM.include?('mswin32')
      return Kconv.tosjis(filename)
    else
      return Kconv.toutf8(filename)
    end
  end

  def on_quit1_activate(widget)
    puts "on_quit1_activate"
    unless @window.signal_emit('delete_event', nil)
      @window.signal_emit('destroy')
    end
  end

  def on_cut1_activate(widget)
    puts "on_cut1_activate"
    @editor.cut_clipboard
  end
  def on_copy1_activate(widget)
    puts "on_copy1_activate"
    @editor.copy_clipboard
  end
  def on_paste1_activate(widget)
    puts "on_paste1_activate"
    @editor.paste_clipboard
  end
  
  def on_about1_activate(widget)
    puts "on_about1_activate"
#    @aboutdialog.run do |response|
#      case response
#      when Gtk::Dialog::RESPONSE_DELETE_EVENT
#        puts "RESPONSE_DELETE_EVENT"
#      when Gtk::Dialog::RESPONSE_CLOSE#GTK_RESPONSE_CLOSE#
#        puts "RESPONSE_CLOSE"
#      end
#    end
    @aboutdialog.run
    @aboutdialog.hide
  end
  
  def on_main_window_delete_event(widget, arg0)
    puts "on_main_window_delete_event"
    false
  end
  def on_main_window_destroy(widget)
    puts "on_main_window_destroy"
    Gtk.main_quit
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH   = 'hwedit.glade'
  PROG_NAME   = 'hwedit'
  Hwedit.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
