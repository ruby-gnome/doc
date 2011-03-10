require 'gtk2'

class FileTreeView < Gtk::TreeView
  def initialize(path)
    @model = Gtk::TreeStore.new(String, String) #fullpath, name
    @column = Gtk::TreeViewColumn.new("Files", 
                                      Gtk::CellRendererText.new, {:text => 1})
    super(@model)

    append_column(@column)
    build_tree(path)
  end

  def build_tree(path)
    root = append_child(nil, path)
    root[1] = path

    append_children(root)
    
    signal_connect("row_expanded") do |tview, titer, tpath|
      append_children(titer)
    end
    expand_row(Gtk::TreePath.new("0"), false)
  end
  
  def append_children(titer)
    child_iter = titer.first_child
    if child_iter != nil and ! child_iter[0]
      Dir.glob(titer[0] + "/*").each do |child_path|
        append_child(titer, child_path)
      end
      @model.remove(child_iter)    # REMOVE ONCE
    end
  end

  def append_child(parent, path)
    iter = @model.append(parent)
    iter[0] = path
    iter[1] = File.basename(path)
    if FileTest.directory?(path)
      @model.append(iter)          # DUMMY CHILD
    end
    iter
  end
end

Gtk.init

fileview = FileTreeView.new(ARGV[0])
scroll = Gtk::ScrolledWindow.new.add(fileview)
Gtk::Window.new.add(scroll).set_default_size(400, 400).show_all

Gtk.main
