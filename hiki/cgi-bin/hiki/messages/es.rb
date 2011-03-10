# $Id: es.rb,v 1.6 2005/01/28 04:35:29 fdiary Exp $
# es.rb
#

# Copyright (C) 2005 Angel Carballo <angelcarballo@gmail.com>
# You can redistribute it and/or modify it under the terms of
# the Ruby's licence.
#
# Original file is en.rb:
# Copyright (C) 2003 Masao Mutoh <mutoh@highway.ne.jp>
# You can redistribute it and/or modify it under the terms of
# the Ruby's licence.
#
# Original file is ja.rb:
# Copyright (C) 2002-2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>
# You can redistribute it and/or modify it under the terms of
# the Ruby's licence.
#
require "messages/en.rb"
module Hiki
  module Messages_es
    include Messages_en
    def msg_recent; ' Reciente' end
    def msg_create; 'Crear' end
    def msg_diff; 'Diff' end
    def msg_edit; 'Editar' end
    def msg_search; 'Buscar' end
    def msg_admin; 'Administrar' end
    def msg_search_result; 'Resultados de la busqueda' end
    def msg_search_hits; '\'%1$s\': %3$d resultado(s) fueron encontrados en %2$d paginas.' end
    def msg_search_not_found; '\'%s\'no se encontro.' end
    def msg_search_comment; 'Buscar en todo el sitio. Ignora Mayusculas/minusculas. Hiki devualve paginas que contienen todas las palabras de tu busqueda' end
    def msg_frontpage; 'Arriba' end
    def msg_hitory; 'History' end
    def msg_index; 'Indexes' end
    def msg_recent_changes; 'Cambios' end
    def msg_newpage; 'Nuevo' end
    def msg_no_recent; '<P>No hay datos.</P>' end
    def msg_thanks; 'Thanks.' end
    def msg_save_conflict; 'Problema con tu actualizacion. Tus cambios no han sido guardados. Copia los cambios tu mismo a un editor. Recarga la pagina y editala de nuevo.' end
    def msg_time_format; "%Y-%m-%d #DAY# %H:%M:%S" end
    def msg_date_format; "%Y-%m-%d " end
    def msg_day; %w(Sun Mon Tue Wed Thr Fri Sat) end
    def msg_preview; 'Compruebe el resultado abajo, y guardelo pulsando el boton Save si no hay problemas' end
    def msg_mail_on; 'Enviar correo actualizado' end
    def msg_mail_off; 'No enviar correo actualizado' end
    def msg_use; 'Usar' end
    def msg_unuse; 'No usar' end
    def msg_password_title; 'Password de Administrador' end
    def msg_password_enter; 'Inserte password de Administrador.' end
    def msg_password; 'Password' end
    def msg_ok; 'OK' end
    def msg_invalid_password; 'Password incorrecta. Tus cambios no han sido guardados.' end
    def msg_save_config; 'Cambios guardados' end
    def msg_freeze; 'Esta pagina esta bloqueada. Necesitas un password de Administrador para guardar esta pagina.' end
    def msg_freeze_mark; '[Bloqueada]' end
    def msg_already_exist; 'La pagina ya existe.' end
    def msg_page_not_exist; 'La pagina no existe. Por favor, creala tu mismo :-)' end
    def msg_invalid_filename(s); "Contiene caracteres invalidos, o supera la longitud maxima(#{s}byte). Cambia el nombre de la pagina." end
    def msg_delete; 'Eliminado' end
    def msg_delete_page; 'Pagina eliminada.' end
    def msg_follow_link; 'Haz click en el link inferior para mostrar tu pagina. ' end
    def msg_match_title; '[matched in title]' end
    def msg_match_keyword; '[matched in keyword]' end
    def msg_duplicate_page_title; 'El titulo de la pagina ya existe.' end
    def msg_missing_anchor_title; 'Crear nuevo %s y editar.' end
    # (config)
    def config_label; 'Configuracion Hiki'; end
    # (diff)
    def diff_add_label; 'Las palabras a&ntilde;adidas se muestran como <ins class="added">aqui</ins>.'; end
    def diff_del_label; 'Las palabras eliminadas se muestran como <del class="deleted">aqui</del>.'; end
    # (edit)
    def msg_title; 'Titulo'; end
    def msg_keyword_form; 'Clave (una clave por linea)'; end
    def msg_freeze_checkbox; 'Bloquear la pagina actual.'; end
    def msg_password_form; 'Password'; end
    def msg_preview_button; 'Preview'; end
    def msg_save; 'Guardar'; end
    def msg_latest; 'Refer recent version'; end
    def msg_rules; %Q|Ver <a href="#{@cgi_name}?TextFormattingRules">Reglas de formateo de texto</a> si lo necesitas.|; end
    # (view)
    def msg_last_modified; 'Ultimas actualizaciones'; end
    def msg_keyword; 'Clave'; end
    def msg_reference; 'Referencias'; end
  end
end
