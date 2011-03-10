#!/usr/bin/env ruby
require 'fileutils'
require 'optparse'
require 'hiki/hiki/page'

paths = [
  File.expand_path(File.join(File.dirname(__FILE__), "hiki"))
]

paths.each do |path|
  $LOAD_PATH.unshift(path)
end

BEGIN { $stdout.binmode }

$KCODE    = 'e'

if FileTest::symlink?( __FILE__ )
  org_path = File::dirname( File::expand_path( File::readlink( __FILE__ ) ) )
else
  org_path = File::dirname( File::expand_path( __FILE__ ) )
end
$:.unshift( org_path.untaint, "#{org_path.untaint}/hiki" )
$:.delete(".") if File.writable?(".")

require 'hiki/config'

module Hiki
  class Page
    attr_reader :body
    def print(*message); nil; end
  end

  class Command
    attr_reader :page
    def page_name=(page_name)
      @p = CGI.unescape(page_name)
    end

    def overwrite_plugin
      class << @plugin
        def add_referer(db); nil; end
        def referers(db); ''; end
        def show_referer(db); ''; end
      end
    end
  end
end

class HikiWriter
  def initialize(args)
    parse_option(args)
    load_config
    setup_output_dir
    setup_output_files
  end

  def load_config
    lang = @options[:lang]
    conf_dir = (lang && File.exist?(lang)) ? lang : './'
    FileUtils.cd(conf_dir) do |dir|
      @conf = Hiki::Config::new
      @conf.lang = lang if lang
    end
  end

  def parse_option(argv)
    @options = {}
    opt = OptionParser.new
    opt.on('-p pagename', '--pagename pagename') { |pagename| @options[:pagename] = [pagename] }
    opt.on('-o outdir', '--outdir outdir') { |outdir| @options[:outdir] = outdir }
    opt.on('-l lang', '--lang lang') { |lang| @options[:lang] = lang }
    opt.parse!(ARGV)
  end

  def setup_output_dir
    @out_dir = @options[:outdir] || 'out/' + @conf.lang
    FileUtils.mkdir_p @out_dir
  end

  def setup_output_files
    text_path = @conf.data_path + '/text/*'
    @files = @options[:pagename] || Dir.glob(text_path)
  end

  def run
    @files.each_with_index do |file, index|
      page_name = File.basename(file)
      db = @conf.database
      db.open_db {
        cgi = CGI::new
        cmd = Hiki::Command::new( cgi, db, @conf )

        cmd.overwrite_plugin
        cmd.page_name = page_name

        cmd.dispatch
        write page_name, cmd.page.body
      }
    end
  rescue Exception => err
    require 'cgi'
    puts CGI.escapeHTML( "#{err} (#{err.class})\n" )
    puts CGI.escapeHTML( err.backtrace.join( "\n" ) )
    puts cmd.instance_variable_get(:@p)
  end

  def write(page_name, page_body)
    File.open(@out_dir + '/' + page_name + '.html', 'w') do |fp|
      fp.write adjust(page_body)
    end
  end

  def adjust(body)
    body = body.dup
    replace_command_anchor!(body)
    replace_wikipage_anchor!(body)
    body
  end

  def replace_command_anchor!(body)
    @@command_line ||= /\<a.*?\?c=.*?\>(.*?)\<\/a\>/
    body.gsub!(@@command_line) { $1 == '?' ? '' : $1 }
  end

  def replace_wikipage_anchor!(body)
    @@wikipage_rex ||= /\<a(.*?)#{@conf.cgi_name}\?*(.*?)(["'])(.*?)\<\/a\>/
    body.gsub!(@@wikipage_rex) { "<a#{$1}./#{$2.size == 0 ? "FrontPage" : $2}.html#{$3}#{$4}</a>" }
  end
end

if __FILE__ == $0
  writer = HikiWriter.new ARGV
  writer.run
end
