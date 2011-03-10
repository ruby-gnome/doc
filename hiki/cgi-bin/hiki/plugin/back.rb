add_body_enter_proc do
  cmd   = @cgi.params[ 'c' ][ 0 ]
  cmd   = 'view' if cmd == nil
  if cmd != 'view'
     add_plugin_command( 'view', 'Back', {'p' => true} )
  end
end

