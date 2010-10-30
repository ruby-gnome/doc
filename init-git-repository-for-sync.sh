#!/bin/sh

run()
{
    $@
    if test $? -ne 0; then
	echo "Failed $@"
	exit 1
    fi
}

ruby_gnome2_repos=https://ruby-gnome2.svn.sourceforge.net/svnroot/ruby-gnome2
sf_jp_ruby_gnome2_home=/home/groups/r/ru/ruby-gnome2

run git remote add sf.jp ssh://kous@shell.sourceforge.jp$sf_jp_ruby_gnome2_home/data/hiki-repos
run git config --path remote.sf.jp.uploadpack $sf_jp_ruby_gnome2_home/local/bin/git-upload-pack
run git config --path remote.sf.jp.receivepack $sf_jp_ruby_gnome2_home/local/bin/git-receive-pack
run git fetch sf.jp
run git branch hiki sf.jp/master
