#!/usr/bin/env ruby
#
# update-rd.rb: based on mkrd.rb
#   Modified by Kouhei Sutou
#
# Original:
# mkrd.rb: Create RD style skeleton
#
#   $Id: mkrd.rb,v 1.9 2005/06/07 14:09:56 ktou Exp $
#
# Usage: LANG="C"; ruby mkrd.rb
# You need set LANG environment variables to "C"
#
# Copyright (C) 2003 Masao Mutoh
#
# This program is free software.
# You can distribute/modify this program under
# the terms of the Ruby Distribute License.
#

require 'English'
require 'fileutils'
require 'optparse'
require 'ostruct'
require 'cgi'

ENV["LANG"] = "C"

#
# Set targets.
#
target_libs = ["atk", "bonobo2", "bonoboui2", "gconf2", "gdk_pixbuf2",
               "glib2", "gio2", "gnome2", "gnomecanvas2", "gnomeprint2",
               "gnomeprintui2", "gnomevfs", "gst", "gtk2", "gtkglext",
               "gtkhtml2", "gtkmozembed", "gtksourceview", "libart2",
               "libglade2", "pango", "poppler", "rsvg2", "vte"]
target_packages = {
  "Ruby/ATK" => ["Atk"],
  "Ruby/Bonobo2" => ["Bonobo"],
  "Ruby/BonoboUI2" => ["Bonobo::UI", "Bonobo::Dock", "Bonobo::Window"],
  "Ruby/GConf2" => ["GConf"],
  "Ruby/GdkPixbuf2" => ["Gdk::Pixbuf", "Gdk::Pixdata"],
  "Ruby/GLib2" => ["GLib"],
  "Ruby/GIO2" => ["GLib"],
  "Ruby/GNOME2" => ["Gnome"],
  "Ruby/GnomeCanvas2" => ["Gnome::Canvas"],
  "Ruby/GnomePrint" => ["Gnome::Print", "Gnome::GPA"],
  "Ruby/GnomePrintUI" => ["Gnome::PrintUI",
                          "Gnome::FontSelection",
                          "Gnome::FontPreview",
                          "Gnome::FontDialog",
                          "Gnome::PrintConfigDialog",
                          "Gnome::PrintContentSelector",
                          "Gnome::PrintDialog",
                          "Gnome::PrintJobPreview",
                          "Gnome::PaperSelector",
                          "Gnome::PrintPreview",
                          "Gnome::PrintUnitSelector"],
  "Ruby/GnomeVFS" => ["GnomeVFS"],
  "Ruby/GStreamer" => ["Gst"],
  "Ruby/GTK2" => ["Gtk"],
  "Ruby/GDK2" => ["Gdk"],
  "Ruby/GtkGLExt" => ["Gtk::GL", "Gdk::GL"],
  "Ruby/GtkHtml2" => ["Gtk::Html"],
  "Ruby/GtkMozEmbed" => ["Gtk::MozEmbed"],
  "Ruby/GtkSourceView" => ["Gtk::SourceView"],
  "Ruby/Libart2" => ["Art"],
  "Ruby/Libglade2" => ["GladeXML"],
  "Ruby/Pango" => ["Pango"],
  "Ruby/Poppler" => ["Poppler"],
  "Ruby/RSVG" => ["RSVG"],
  "Ruby/VTE" => ["Vte"],
}

target_libs.each do |lib|
  begin
    require lib
  rescue LoadError
    puts "can't load #{lib}"
  end
end

default_output_dir = "en/text"
options = OpenStruct.new
options.replace = false
options.index_page_name_template = nil

opts = OptionParser.new do |opts|
  opts.banner += " [OUTPUT_DIR]"

  opts.separator ""
  opts.on("-oDIR", "--output-dir=DIR",
          "Output into DIR. [#{default_output_dir}]") do |dir|
    options.output_dir = dir
  end

  opts.on("--[no-]replace", "Don't merge exist RD.") do |replace|
    options.replace = replace
  end

  opts.on("iTEMPLATE", "--index-page-name-template=TEMPLATE",
          "Index page name template. '%s' will be replaced module name.",
          "[#{options.index_page_name_template}]") do |template|
    options.index_page_name_template = template
  end
end

options.output_dir = opts.parse!(ARGV).shift || default_output_dir


#################################################################
# Don't touch below.
#################################################################
require 'rbbr/metainfo'

class Class
  def class?
    true
  end
end

class Module
  def class?
    false
  end
end

class Property
  attr_reader :name

  def initialize(name, prop, target_modules)
    @name = name
    @prop = prop
    @target_modules = target_modules
  end

  def type
    klass = @prop.value_type
    prop_name = klass.name
    if klass.to_class == "TrueClass"
      "true or false"
=begin
    elsif klass.fundamental.to_s =~ /GEnum|GType/
      prop_klass = @prop.value_type.to_class.inspect.split(/::/)
      prop_klass.pop
      %Q[((<#{prop_name}|#{prop_klass.join("::")}\##{prop_name}>))]
=end
    else
      case prop_name
      when /gint|guint|gulong|glong/
	"Integer"
      when /gfloat|gdouble/
	"Float"
      when "GStrv"
	"Array"
      when "GValueArray"
	"Array"
      when "gchararray"
	"String"
      when "gboolean"
	"true or false"
      else
	prop_name.gsub(/(#{Regexp.union(*@target_modules)})/, "\\1::")
      end
    end
  end

  def blurb
    blurb = @prop.blurb
    return nil if blurb.nil?

    blurb = blurb.gsub(/TRUE/, "true")
    blurb.gsub(/(#{Regexp.union(*@target_modules)})/, "\\1::")
  end

  def flags
    flags = []
    if @prop.readable?
      flags << "Read"
    end
    if @prop.writable?
      flags << "Write"
    end
    if flags.size > 1
      flag = flags.join("/")
    else
      flag = flags[0]
    end
    flag
  end

  def canonical_method(str)
    str.gsub(/-/, "_")
  end

  def methods
    prop_methods = []
    name = canonical_method(@name)
    if blurb
      explanation = blurb.gsub(/^\s*the\s*/i, "")
      explanation.gsub!(/^\s*Whether(.*)/i, "value whether\\1 or not")
      explanation.gsub!(/^\s*If/i, "value if")
      explanation.gsub!(/\.\s*\z/i, "")

      attr_explanation = blurb.gsub(/^Whether/, "true if")
      attr_explanation.gsub!(/^If/, "true if")
      attr_explanation.gsub!(/\.\s*\z/i, "")
    else
      explanation = name
      attr_explanation = "((*FIXME*))"
    end

    if @prop.readable?
      detail = "    Gets the #{explanation}.\n" +
        "     * Returns: #{attr_explanation}\n"
      if @prop.value_type.to_class == TrueClass
        name.gsub!(/is_/, "")
        prop_methods << ["#{name}?", detail]
      else
        prop_methods << [name, detail]
      end
    end
    if @prop.writable?
      detail = "    Sets the #{explanation}.\n" +
        "     * #{name}: #{attr_explanation}\n" +
        "     * Returns: #{name}"
      prop_methods << ["#{name}=", detail, "(#{name})"]

      detail = "    Same as #{name}=.\n" +
        "     * #{name}: #{attr_explanation}\n" +
        "     * Returns: self\n"
      prop_methods << ["set_#{name}", detail, "(#{name})"]
    end
    prop_methods
  end
end

class UpdateRD
  RETURNS = "     * Returns: self: ((*FIXME*))"

  def initialize(target_packages, output_dir, replace,
                 index_page_name_template=nil)
    @target_packages = target_packages
    @target_modules = target_packages.collect do |package, modules|
      modules
    end.flatten.sort_by do |target_module|
      -target_module.size
    end
    @output_dir = output_dir
    @replace = replace
    @target_classes = []
    @current_class = nil
    @indexes = {}
    @index_page_name_template = index_page_name_template
    FileUtils.mkdir_p(@output_dir)
    @dag = RBBR::MetaInfo::ModuleDAG.full_module_dag
  end

  def run
    nest_classes(Object)
    (@dag.roots - [Object]).sort_by {|x| x.inspect}.each do |mod|
      nest_classes(mod)
    end
    output_classes
    output_indexes
  end

  private
  def put_classmodule_info(mod)
    if mod.class?
      puts "= class #{mod.inspect}"
    else
      puts "= module #{mod.inspect}"
    end
    puts
    description = @indexes[mod][:description]
    if description and !description.empty?
      puts(description)
      puts
    end

    if mod.class? and Object != mod
      puts "== Object Hierarchy"
      puts
      superclasses = [mod]
      sp = mod
      while sp = sp.superclass
        superclasses.push(sp)
      end
      depth = 0
      while sp = superclasses.pop
        if @indexes.has_key?(sp) and sp != mod
          # sp_text = "((<#{sp.inspect}>))"
          sp_text = sp.inspect
        else
          sp_text = sp.inspect
        end
        puts "#{' ' * 2 * depth}* #{sp_text}"
        depth += 1
      end
      puts ""
    end
    included_modules_at = mod.included_modules_at
    unless included_modules_at.empty?
      puts "== Included Modules"
      puts
      included_modules_at.sort_by {|x| x.inspect}.each do |included_mod|
        puts "  * #{included_mod.inspect}"
      end
      puts
    end
  end

  def extract_name(name)
    name = name.gsub(/\A[A-Z]\S*?(?:\.|\#|(\[))/,  # SomeClass.xxx => xxx
                     '\\1')                        # SomeClass#xxx => xxx
                                                   # SomeClass[xxx] => [xxx]
    name = name.gsub(/\s*[\(\{:].*\z/, '') # xxx(...) => xxx
                                           # xxx {...} => xxx
                                           # xxx: ... => xxx
    name.gsub(/\[.*\]\s*(=)?.*\z/, '[]\1') # [xxx] => []
                                           # [xxx] = value => []=
  end

  def call_if_can(value, *args)
    if value.respond_to?(:call)
      value.call(*args)
    else
      value
    end
  end

  def put_methods(title, methods, methods_info=nil, prefix="", postfix="",
                  default_desc=nil)
    method_names = []
    methods_info ||= []
    method_names = methods_info.reject do |name, desc|
      name.nil?
    end.collect do |name, desc|
      extract_name(name)
    end
    methods -= method_names
    method_names = (method_names + methods).uniq
    target_methods = methods_info
    target_methods += methods.sort.collect do |name|
      _prefix = call_if_can(prefix, name)
      _postfix = call_if_can(postfix, name)
      ["#{_prefix}#{name}#{_postfix}"]
    end

    unless target_methods.empty?
      put_method_section(title, target_methods, default_desc)
    end
    method_names
  end

  def put_method_section(title, target_methods, default_desc)
    puts "== #{title}"
    puts
    last_putted = true
    target_methods.each do |name, desc, group_name, group_description|
      last_putted = false
      if group_name and /\A\s*\z/ !~ group_name
        puts "=== #{group_name.strip}"
        puts
      end
      if group_description and /\A\s*\z/ !~ group_description
        puts(group_description.rstrip)
        puts
      end
      next if name.nil?
      puts "--- #{name}"
      method_description = desc || default_desc
      if method_description.respond_to?(:call)
        method_description = method_description.call(extract_name(name))
      end
      method_description = method_description.to_s.rstrip
      unless method_description.empty?
        puts
        puts(method_description)
        puts
        last_putted = true
      end
    end
    puts unless last_putted
  end

  def target_module?(mod)
    /\A(#{Regexp.union(*@target_modules)})/ =~ mod.inspect
  end

  def nest_classes(klass)
    if target_module?(klass)
      unless @indexes.has_key?(klass)
        @target_classes << klass
        @indexes[klass] = {}
      end
    end

    @dag.arc(klass).each do |subklass|
      nest_classes(subklass)
    end
  end

  def klass_to_page_name(klass)
    CGI.escape(klass.name)
  end

  def rd_file(klass)
    File.join(@output_dir, klass_to_page_name(klass))
  end

  def read_section(section)
    title, *entries = section.split(/^---\s*.*?/m)
    entries = entries.collect do |entry|
      name, description = entry.split(/\n+/, 2)
      [name.strip, description]
    end
    [title, entries]
  end

  def read_sections(component)
    section_infos = []

    title, component = component.split(/\n+/, 2)
    first_section, *sections = component.split(/^===(?!=)\s*/m)
    if sections.empty?
      sections = ["\n#{first_section}"] if first_section
    else
      section_infos << [nil, nil, nil, first_section]
    end

    sections.each do |section|
      group_info, entries = read_section(section)
      group_title, group_description = group_info.split(/\n+/, 2)
      entries[0][2, 0] = [group_title, group_description].compact
      section_infos.concat(entries)
    end
    section_infos
  end

  def read_initial_info(klass)
    return unless File.exists?(rd_file(klass))
    introduction, *components = File.read(rd_file(klass)).split(/^==(?!=)\s*/m)
    info = {}

    return unless /\A[\r\n\s]*=\s*(?:class|module)\s+(.*)\s*/ =~ introduction
    return if $1 != klass.inspect
    description = $POSTMATCH.strip
    info[:description] = description

    components.each do |component|
      case component
      when /\ADescription/
        info[:description] << "\n\n" unless info[:description].empty?
        info[:description] << "== #{component.strip}"
      when /\AClass Methods/
        info[:class_methods_info] = read_sections(component)
      when /\AModule Functions/i
        info[:module_functions_info] = read_sections(component)
      when /\AInstance Methods/i
        info[:instance_methods_info] = read_sections(component)
      when /\AConstants/
        info[:constants_info] = read_sections(component)
      when /\AProperties/
        info[:properties_info] = read_sections(component)
      when /\AStyle Properties/
        info[:style_properties_info] = read_sections(component)
      when /\AChild Properties/
        info[:child_properties_info] = read_sections(component)
      when /\ASignals/
        info[:signals_info] = read_sections(component)
      when /\ASee Also/
        title, info[:see_also] = component.split(/\n+/, 2)
      when /\AChangeLog/
        title, info[:change_log] = component.split(/\n+/, 2)
      when /\AObject Hierarchy/
      when /\AIncluded Modules/
      else
        # $stderr.puts("unknown section: #{component}")
      end
    end
    @indexes[klass].merge!(info)
  end

  def output_classes
    @target_classes.uniq.sort_by {|x| x.inspect}.each do |klass|
      read_initial_info(klass) unless @replace
      File.open(rd_file(klass), "w") do |rd|
        stdout = $stdout
        begin
          $stdout = rd
          output_class(klass)
        ensure
          $stdout = stdout
        end
      end
    end
  end

  def output_indexes
    if @target_packages.size == 1 and @index_page_name_template.nil?
      output_index("index")
    else
      @target_packages.each do |package, target_modules|
        template = @index_page_name_template || "index-%s"
        template += "-%s" unless /%s/ =~ template
        page_name = template % package.downcase.gsub(/\//, "-")
        output_index(page_name, package, target_modules)
      end
    end
  end

  def output_index(index_page_name, package=nil, target_modules=[])
    File.open(File.join(@output_dir, index_page_name), "w") do |index|
      if package
        index.puts "= #{package} API Index"
      else
        index.puts "= Index"
      end
      index.puts
      @indexes.sort_by {|klass, info| klass.inspect}.each do |klass, info|
        unless target_modules.empty?
          matched_modules = @target_modules.find_all do |target_module|
            /\A#{target_module}/ =~ klass.name
          end
          next unless target_modules.include?(matched_modules.first)
        end
        index.puts "  * #{klass.inspect}"

        info[:constants].sort.each do |name, desc|
          begin
            next unless klass.const_defined?(name)
          rescue NameError
            next
          end
          constant = klass.const_get(name)
          next unless @indexes.has_key?(constant)
          index.puts "  * #{constant.inspect}"
        end

        methods = info[:class_methods] || info[:module_functions]
        methods.sort.each do |name, desc|
          index.puts "  * #{klass.inspect}.#{name}"
        end

        info[:instance_methods].sort.each do |name, desc|
          index.puts "  * #{klass.inspect}\##{name}"
        end
      end
    end
  end

  def new_methods(klass)
    if klass.respond_to?(:gtype) and klass.method(:gtype).arity <= 0
      return [] if klass.gtype.abstract?
    end
    private_instance_methods = klass.private_instance_methods(false)
    private_instance_methods = private_instance_methods.collect do |name|
      name.to_s
    end
    return ["new"] if private_instance_methods.include?("initialize")
    []
  end

  def output_class(klass)
    put_classmodule_info(klass)
    if klass.class?
      put_class_methods(klass)
    else
      put_module_functions(klass)
    end
    properties = find_properties(klass, GLib::Object, "")
    put_instance_methods(klass, properties)
    put_constants(klass)
    put_all_properties(klass, properties)
    put_signals(klass)
    put_see_also(klass)
    put_change_log(klass)
  end

  def class_method_prefix_generator(klass)
    Proc.new do |name|
      if /\A\[/ =~ name
        klass.inspect
      else
        "#{klass.inspect}."
      end
    end
  end
  alias_method :module_function_prefix_generator, :class_method_prefix_generator

  def put_class_methods(klass)
    methods = klass.methods - klass.superclass.methods
    singleton_class = (class << klass; self; end)
    singleton_class.ancestors.each do |ancestor|
      methods -= ancestor.instance_methods
    end
    methods += new_methods(klass)
    @indexes[klass][:class_methods] =
      put_methods("Class Methods", methods,
                  @indexes[klass][:class_methods_info],
                  class_method_prefix_generator(klass), "", RETURNS)
  end

  def put_module_functions(klass)
    methods = klass.methods + new_methods(klass)
    klass.included_modules_at.each do |included|
      methods -= included.methods
    end
    methods -= Object.methods
    @indexes[klass][:module_functions] =
      put_methods("Module Functions", methods,
                  @indexes[klass][:module_functions_info],
                  module_function_prefix_generator(klass), "", RETURNS)
  end

  def put_instance_methods(klass, properties)
    property_descriptions = {}
    property_postfixes = {}
    properties.each do |property|
      property.methods.each do |name, detail, postfix|
        property_descriptions[name] = detail
        property_postfixes[name] = postfix
      end
    end

    if klass.class?
      instance_methods = klass.public_instance_methods(false) +
        klass.protected_instance_methods(false)
    else
      instance_methods = klass.public_instance_methods(false) - ["initialize"] +
        klass.protected_instance_methods(false)
    end

    included_module_descriptions = {}
    klass.included_modules.each do |mod|
      next unless target_module?(mod)
      (mod.public_instance_methods(false) +
       mod.protected_instance_methods(false)).each do |method|
        next if instance_methods.include?(method)
        instance_methods << method
        description = "    See #{mod.name}##{method}."
        included_module_descriptions[method] = description
      end
    end

    default_descriptions = Proc.new do |name|
      property_descriptions[name] ||
        included_module_descriptions[name] ||
        RETURNS
    end
    @indexes[klass][:instance_methods] =
      put_methods("Instance Methods", instance_methods,
                  @indexes[klass][:instance_methods_info],
                  "",
                  Proc.new {|name| property_postfixes[name] || ""},
                  default_descriptions)
  end

  def put_constants(klass)
    constants = []
    klass.constants_at.each do |const|
      constants << const unless @indexes.has_key?(klass.const_get(const))
    end
    @indexes[klass][:constants] =
      put_methods("Constants", constants, @indexes[klass][:constants_info])
  end

  def find_properties(klass, parent, prefix)
    if klass < parent
      klass.send("#{prefix}properties", false).sort.collect do |name|
        property = klass.send("#{prefix}property", name)
        Property.new(name, property, @target_modules)
      end
    else
      {}
    end
  end

  def put_properties(klass, title, properties, key)
    property_postfixes = {}
    property_descriptions = {}
    property_names = properties.collect do |property|
      name = property.name
      property_postfixes[name] = ": #{property.type} (#{property.flags})"
      property_descriptions[name] = "    #{property.blurb}"
      name
    end

    @indexes[klass][key.to_sym] =
      put_methods(title, property_names, @indexes[klass]["#{key}_info".to_sym],
                  "",
                  Proc.new {|name| property_postfixes[name]},
                  Proc.new {|name| property_descriptions[name]})
  end

  def put_all_properties(klass, properties)
    put_properties(klass, "Properties", properties, "properties")

    put_special_properties(klass, "Style Properties", Gtk::Widget, "style_")
    put_special_properties(klass, "Child Properties", Gtk::Container, "child_")
  end

  def put_special_properties(klass, title, parent, prefix)
    properties = find_properties(klass, parent, prefix)
    put_properties(klass, title, properties, "#{prefix}properties")
  end

  def put_signals(klass)
    if klass < GLib::Instantiatable or klass < GLib::Interface
      begin
        signals = klass.signals(false)
        @indexes[klass][:signals] =
          put_methods("Signals", signals, @indexes[klass][:signals_info],
                      "", ": self",
                      "     * self: #{klass.name}: ((*FIXME*))")
      rescue
        $stderr.print $!
        $stderr.print klass.inspect, "\n"
        exit
      end
    end
  end

  def put_see_also(klass)
    puts "== See Also"
    puts
    see_also = (@indexes[klass][:see_also] || '').rstrip
    unless see_also.empty?
      puts see_also
      puts
#     else
#       puts "  * Index"
#       puts
    end
  end

  def put_change_log(klass)
    puts "== ChangeLog"
    puts
    change_log = (@indexes[klass][:change_log] || '').rstrip
    puts change_log
  end
end

updater = UpdateRD.new(target_packages, options.output_dir,
                       options.replace, options.index_page_name_template)
updater.run
