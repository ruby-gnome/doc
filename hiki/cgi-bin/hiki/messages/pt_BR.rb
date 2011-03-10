# $Id: en.rb,v 1.4 2004/04/02 00:45:01 hitoshi Exp $
# pt_BR.rb
#
# Copyright (C) 2004 Joao Pedrosa <joaopedrosa@yahoo.com>
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
  module Messages_pt_BR
    include Messages_en

    def msg_recent; 'Recente' end
    def msg_create; 'Criar' end
    def msg_diff; 'Diff' end
    def msg_edit; 'Editar' end
    def msg_search; 'Buscar' end
    def msg_admin; 'Admin' end
    def msg_search_result; 'Resultados da Busca' end
    def msg_search_hits; '\'%1$s\': %3$d página(s) foram encontradas de %2$d páginas.' end
    def msg_search_not_found; '\'%s\' não foi achado.' end
    def msg_search_comment; 'Buscar do site todo. Ignorar Maiúsculas/Minúsculas. Hiki retorna páginas que contêm todas as palavras da busca' end
    def msg_frontpage; 'Cima' end
    def msg_hitory; 'Historia' end
    def msg_index; 'Índices' end
    def msg_recent_changes; 'Alterações' end
    def msg_newpage; 'Novo' end
    def msg_no_recent; '<P>Não existem dados.</P>' end
    def msg_thanks; 'Obrigado.' end
    def msg_save_conflict; 'Conflito na atualização. Suas alterações não foram salvas. Copie suas alterações para o seu editor. E recarregue a página e a edite novamente.' end
    def msg_time_format; "%d/%m/%Y #DAY# %H:%M:%S" end
    def msg_date_format; "%d/%m/%Y" end
    def msg_day; %w(Dom Seg Ter Qua Qui Sex Sáb) end
    def msg_preview; 'Confirme o resultado abaixo, e salve-o clicando no botão "Salvar" se não existirem problemas.' end
    def msg_mail_on; 'Enviar e-mail de atualizado' end
    def msg_mail_off; 'Não enviar e-mail de atualizado' end
    def msg_use; 'Usar' end
    def msg_unuse; 'Não usar' end
    def msg_password_title; 'Senha do Admin' end
    def msg_password_enter; 'Entre com a senha do Admin.' end
    def msg_password; 'Senha' end
    def msg_ok; 'OK' end
    def msg_preview_button; 'Preview'; end
    def msg_save; 'Save'; end
    def msg_invalid_password; 'Senha errada. Suas alterações não foram salvas ainda.' end
    def msg_save_config; 'Suas alterações foram salvas' end
    def msg_freeze; 'Esta página está congelada. Você precisa da senha de Admin para salvar esta página.' end
    def msg_freeze_mark; '[Congelar]' end
    def msg_already_exist; 'A página já existe.' end
    def msg_page_not_exist; 'A página não existe. Por favor, crie-a você mesmo :-)' end
    def msg_invalid_filename(s); "Nome da página inválido. Ele pode conter caracteres inválidos ou o número de caracteres excedeu o limite de #{s} bytes. Tente outro nome." end
    def msg_delete; 'Deletado' end
    def msg_delete_page; 'A página foi deletada.' end
    def msg_follow_link; 'Clique na âncora (link) abaixo para mostrar a página: ' end
    def msg_match_title; '[encontrado no título]' end
    def msg_match_keyword; '[encontrado em palavra-chave]' end
    def msg_duplicate_page_title; 'O título da página já existe.' end
    def msg_missing_anchor_title; 'Criar e editar nova %s.' end
  end
end
