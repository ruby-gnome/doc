#
# labels
#
#
# preferences (resources)
#
add_conf_proc( 'default', 'Basic preferences' ) do
  saveconf_default
  <<-HTML
      <h3 class="subtitle">Nombre del sitio</h3>
      <p>Escribe el nombre del sitio. Esto aparecera como Titulo.</p>
      <p><input name="site_name" value="#{CGI::escapeHTML(@conf.site_name)}" size="40"></p>
      <h3 class="subtitle">Autor</h3>
      <p>Escribe tu nombre.</p>
      <p><input name="author_name" value="#{CGI::escapeHTML(@conf.author_name)}" size="40"></p>
      <h3 class="subtitle">Direccion de E-Mail</h3>
      <p>Escribe tu e-mail.</p>
      <p><input name="mail" value="#{CGI::escapeHTML(@conf.mail)}" size="40"></p>
      <h3 class="subtitle">Notificar por correo los cambios.</h3>
      <p>Si esta ON, un correo es enviado a la direccion de e-mail especificada en Preferencias Basicas via servidor SMTP cuando una pagina es actualizada. Si esta OFF ningun correo es enviado.</p>
      <p><select name="mail_on_update">
         <option value="true"#{@conf.mail_on_update ? ' selected' : ''}>ON</option>
         <option value="false"#{@conf.mail_on_update ? '' : ' selected'}>OFF</option>
         </select></p>
  HTML
end

add_conf_proc( 'password', 'Password' ) do
  saveconf_password
  <<-HTML
      <h3 class="password">Password</h3>
      <p>Escriba passwords solo cuando quiera cambiar la password.</p>
      <p>Password actual: <input type="password" name="old_password" size="40"></p>
      <p>Password nueva: <input type="password" name="password1" size="40"></p>
      <p>Password nueva (confirm): <input type="password" name="password2" size="40"></p>
  HTML
end

add_conf_proc( 'theme', 'Appearance' ) do
  saveconf_theme
  r = <<-HTML
      <h3 class="subtitle">Tema</h3>
      <p>Selecciona un tema.
      <p><select name="theme">
  HTML
  @conf_theme_list.each do |theme|
    r << %Q|<option value="#{theme[0]}"#{if theme[0] == @conf.theme then " selected" end}>#{theme[1]}</option>|
  end
  r << <<-HTML
      </select></p>
      <h3 class="subtitle">URL del Tema</h3>
      <p>Escribe la URL del tema.</p>
      <p><input name="theme_url" value="#{CGI::escapeHTML(@conf.theme_url)}" size="60"></p>
      <h3 class="subtitle">Directorio de Temas</h3>
      <p>Escribe el directorio de temas</p>
      <p><input name="theme_path" value="#{CGI::escapeHTML(@conf.theme_path)}" size="60"></p>
      <h3 class="subtitle">Barra Lateral</h3>
      <p>ON si se muestra la Barra Lateral.</p>
      <p><select name="sidebar">
         <option value="true"#{@conf.use_sidebar ? ' selected' : ''}>ON</option>
         <option value="false"#{@conf.use_sidebar ? '' : ' selected'}>OFF</option>
         </select></p>
      <h3 class="subtitle">Class name of the main area (CSS)</h3>
      <p>Enter the class name of the main area (default: 'main').</p>
      <p><input name="main_class" value="#{CGI::escapeHTML(@conf.main_class)}" size="20"></p>
      <h3 class="subtitle">Class name of the side bar (CSS)</h3>
      <p>Enter the class name of the side bar (default: 'sidebar').</p>
      <p><input name="sidebar_class" value="#{CGI::escapeHTML(@conf.sidebar_class)}" size="20"></p>
      <h3 class="subtitle">Auto link</h3>
      <p>Si quieres usar la funcion auto link, selecciona 'On'.</p>
      <p><select name="auto_link">
         <option value="true"#{@conf.auto_link ? ' selected' : ''}>ON</option>
         <option value="false"#{@conf.auto_link ? '' : ' selected'}>OFF</option>
         </select></p>
  HTML
end
