# ここ目次

# パラメータ
# baseLevel : インデントのベースレベル（デフォルトは1）
# page      : ページ名（デフォルトは現在のページ）
#
# 設定(hikiconf.rb)
# toc_here_leader    : 目次部の前に付ける文字列。"!"の数だけ付く。デフォルトは">"
# toc_here_cr        : 目次部の各行の行末文字列。デフォルトは"<br>"
# toc_here_start     : 目次部の始まりのタグ。デフォルトは'<div class="toc">'。
# toc_here_end       : 目次部の終了のタグ。デフォルトは"</div>"。
# toc_here_no_header : 見出しがない場合のメッセージ。デフォルトは""。
#

def toc_here(baseLevel = 1, page = @page)
   toc_leader = @options['toc_here_leader'].nil? ? '&gt;' : @options['toc_here_leader']
   toc_cr = @options['toc_here_cr'].nil? ? '<br>' : @options['toc_here_cr']
   toc_start = @options['toc_here_start'].nil? ? '<div class="toc">' : @options['toc_here_start']
   toc_end = @options['toc_here_end'].nil? ? '</div>' : @options['toc_here_end']
   toc_no_header = @options['toc_here_no_header'].nil? ? 'no header' : @options['toc_here_no_header']
   
   toc_num = 0
   s = "#{toc_start}\n"

   if !page.nil? && !page.empty? && @db.exist?(page) then
      @db.load(page).each_line do |line|
         next if line !~ /^(!+)/
         level = $1.size - baseLevel
         title = line.gsub(/^!+/, "")
         title.gsub!(/\[\[([^|:]+)[|:].+\]\]/, "\\1")
         title.chomp!
         head = title
         s << toc_leader * level unless level == 0
         s << "<a href=\"#l#{toc_num}\" title=\"#{title}\">#{head}</a>#{toc_cr}\n"

         toc_num += 1
      end
   end

   s << toc_no_header if toc_num == 0
   s << "#{toc_end}\n"
   s
end

