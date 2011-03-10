eval( open( 'hikiconfall.rb' ){|f|f.read.untaint} )

@lang            = "en"
@charset         = 'ISO-8859-1'
@data_path       = @data_path + @lang
#@index_page      = @index_page + "/"
@cache_path      = @data_path + '/cache'
@mail_from       = "ruby-gnome2-hiki-#{@lang}@sourceforge.jp"
@base_url       += ""

