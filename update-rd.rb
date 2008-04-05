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

#
# Set targets.
#
target_libs = ["gtk2"]
target_modules = ["Gtk"]

target_libs.each do |lib|
  require lib
end

default_output_dir = "doc"
options = OpenStruct.new
options.replace = false

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
	prop_name.gsub(/(#{@target_modules.join("|")})/, "\\1::")
      end
    end
  end

  def blurb
    blurb = @prop.blurb
    if blurb
      blurb = blurb.gsub(/TRUE/, "true")
      blurb = blurb.gsub(/(#{@target_modules.join("|")})/, "\\1::")
    else
      ""
    end
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
    explanation = blurb.gsub(/^\s*the/i, "")
    explanation.gsub!(/^\s*Whether(.*)/i, "value whether\\1 or not")
    explanation.gsub!(/^\s*If/i, "value if")

    attr_explanation = blurb.gsub(/^Whether/, "true if")
    attr_explanation.gsub!(/^If/, "true if")

    if @prop.readable?
      detail = "\n    Gets the #{explanation}.\n" +
      "     * Returns: #{attr_explanation}\n"
      if @prop.value_type.to_class == TrueClass
        name.gsub!(/is_/, "")
        prop_methods << [name + "?", detail]
      else
        prop_methods << [name, detail]
      end
    end
    if @prop.writable?
      detail = "(#{name})\n    Sets the #{explanation}.\n" +
      "     * #{name}: #{attr_explanation}\n" +
      "     * Returns: #{name}\n"
      prop_methods << ["#{name}=", detail]

      detail = "(#{name})\n    Same as #{name}=.\n" +
      "     * #{name}: #{attr_explanation}\n" +
      "     * Returns: self\n"
      prop_methods << ["set_#{name}", detail]
    end
    prop_methods
  end
end

class UpdateRD
  RETURNS = "     * Returns: self"

  def initialize(target_modules, output_dir, replace)
    @target_modules = target_modules
    @output_dir = output_dir
    @replace = replace
    @target_classes = []
    @current_class = nil
    @indexes = {}
    FileUtils.mkdir_p(@output_dir)
    @dag = RBBR::MetaInfo::ModuleDAG.full_module_dag
  end

  def run
    nest_classes(Object)
    (@dag.roots - [Object]).sort_by {|x| x.inspect}.each do |mod|
      nest_classes(mod)
    end
    output_classes
    # output_index
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
      puts ""
    end
  end

  def put_methods(title, methods, methods_info=nil, prefix="", postfix="",
                  default_desc=nil)
    method_names = []
    methods_info ||= []
    method_names = methods_info.collect do |name, desc|
      name = name.gsub(/(?:\A\S*?[\.\#]|\(.*\Z|\s*\{.*\Z)/, '')
    end
    methods -= method_names
    method_names = (method_names + methods).uniq
    target_methods = methods_info
    target_methods += methods.sort.collect do |name|
      ["#{prefix}#{name}#{postfix}"]
    end
    return method_names if target_methods.size == 0

    puts "== " + title
    puts
    last_putted = true
    target_methods.each do |name, desc|
      last_putted = false
      puts "--- #{name}"
      method_description = desc || default_desc
      if method_description.respond_to?(:call)
        method_description = method_description.call(name)
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
    method_names
  end

  def target_module?(mod)
    /(#{@target_modules.join("|")})/ =~ mod.inspect
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

  def read_entries(component)
    title, *entries = component.split(/^---\s*.*?/m)
    entries.collect do |entry|
      entry.split(/\n+/, 2)
    end
  end

  def read_initial_info(klass)
    return unless File.exists?(rd_file(klass))
    introduction, *components = File.read(rd_file(klass)).split(/^==\s+.*?/m)
    info = {}

    return unless /\A[\r\n\s]*=\s*(?:class|module)\s+(.*)/ =~ introduction
    return if $1 != klass.inspect
    description = $POSTMATCH.strip
    info[:description] = description

    components.each do |component|
      case component
      when /\ADescription/
        info[:description] += "\n\n== #{component}"
      when /\AClass Methods/
        info[:class_methods_info] = read_entries(component)
      when /\AModule Functions/
        info[:module_functions_info] = read_entries(component)
      when /\AInstance Methods/
        info[:instance_methods_info] = read_entries(component)
      when /\AConstants/
        info[:constants_info] = read_entries(component)
      when /\AProperties/
        info[:properties_info] = read_entries(component)
      when /\AStyle Properties/
        info[:style_properties_info] = read_entries(component)
      when /\AChild Properties/
        info[:child_properties_info] = read_entries(component)
      when /\ASignals/
        info[:signals_info] = read_entries(component)
      when /\ASee Also/
        title, info[:see_also] = component.split(/\n+/, 2)
      when /\AChangeLog/
        title, info[:change_log] = component.split(/\n+/, 2)
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

  def output_index
    File.open(File.join(@output_dir, "index.rd"), "w") do |index|
      index.puts "= Index"
      index.puts
      @indexes.sort_by {|klass, info| klass.inspect}.each do |klass, info|
        index.puts "  * #{klass.inspect}"

        info[:constants].sort.each do |name, desc|
          next if @indexes.has_key?(klass.const_get(name))
          index.puts "  * #{klass.inspect}::#{name}"
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
    if klass.private_instance_methods(false).include?("initialize")
      ["new"]
    else
      []
    end
  end

  def output_class(klass)
    put_classmodule_info(klass)
    if klass.class?
      put_class_methods(klass)
    else
      put_module_functions(klass)
    end
    put_instance_methods(klass)
    put_constants(klass)
    put_all_properties(klass)
    put_signals(klass)
    put_see_also(klass)
    put_change_log(klass)
  end

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
                  klass.inspect + ".", "", RETURNS)
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
                  klass.inspect + ".", "", RETURNS)
  end

  def put_instance_methods(klass)
    if klass.class?
      instance_methods = klass.public_instance_methods(false) +
        klass.protected_instance_methods(false)
    else
      instance_methods = klass.public_instance_methods(false) - ["initialize"] +
        klass.protected_instance_methods(false)
    end
    klass.included_modules.each do |mod|
      if target_module?(mod)
        instance_methods += mod.public_instance_methods(false) +
          mod.protected_instance_methods(false)
      end
    end
    @indexes[klass][:instance_methods] =
      put_methods("Instance Methods", instance_methods,
                  @indexes[klass][:instance_methods_info], "", "", RETURNS)
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
    property_descriptions = {}
    property_names = properties.collect do |property|
      name = "#{property.name}: #{property.type} (#{property.flags})"
      property_descriptions[name] = "    #{property.blurb}"
      name
    end

    @indexes[klass][key.to_sym] =
      put_methods(title, property_names, @indexes[klass]["#{key}_info".to_sym],
                  "", "", Proc.new {|name| property_descriptions[name]})
  end

  def put_all_properties(klass)
    properties = find_properties(klass, GLib::Object, "")
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
                      "", ": self", "     * self: #{klass.inspect}")
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
    see_also = @indexes[klass][:see_also]
    if see_also
      puts see_also
#     else
#       puts "  * Index"
#       puts
    end
  end

  def put_change_log(klass)
    puts "== ChangeLog"
    puts
    change_log = @indexes[klass][:change_log]
    if change_log
      puts change_log
    else
      puts
    end
  end
end

UpdateRD.new(target_modules, options.output_dir, options.replace).run
