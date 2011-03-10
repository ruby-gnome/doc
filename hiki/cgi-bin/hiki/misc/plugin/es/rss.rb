# $Id: rss.rb,v 1.1.2.1 2003/05/01 02:35:52 hitoshi Exp $
# Copyright (C) 2003 TAKEUCHI Hitoshi <hitoshi@namaraii.com>

def label_rss_recent
  'Ultimas actualizaciones'
end

def label_rss_config; 'RSS publication'; end
def label_rss_mode_title; 'Select the format.'; end
def label_rss_mode_candidate
  [ 'unified diff',
    'word diff (digest)',
    'word diff (full text)',
    'HTML (full text)', ]
end
def label_rss_menu_title; 'add RSS menu'; end
def label_rss_menu_candidate
  [ 'Yes', 'No' ]
end

