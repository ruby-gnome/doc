def hiki_footer
  <<EOS
  <div id=footer></div>
<div style="margin-top:1em; margin-left: 20%;text-align:right;border-style: dashed; border-color: #ff9999; border-width: 1px 0px 1px 0px;">
Copyright &copy; 2003-2009 Ruby-GNOME2 Project<br>
This document is distributed under the terms of the <a href="http://www.gnu.org/licenses/fdl.html">GNU Free Documentation License</a>.
</div>
<div style="text-align:right;padding:0.5em;">
Powered by <a href="http://www.namaraii.com/hiki/">Hiki</a> #{HIKI_VERSION}.<br>
</div>
<!-- Piwik -->
<script type="text/javascript">
var pkBaseURL = (("https:" == document.location.protocol) ? "https://apps.sourceforge.net/piwik/ruby-gnome2/" : "http://apps.sourceforge.net/piwik/ruby-gnome2/");
document.write(unescape("%3Cscript src='" + pkBaseURL + "piwik.js' type='text/javascript'%3E%3C/script%3E"));
</script><script type="text/javascript">
piwik_action_name = '';
piwik_idsite = 1;
piwik_url = pkBaseURL + "piwik.php";
piwik_log(piwik_action_name, piwik_idsite, piwik_url);
</script>
<object><noscript><p><img src="http://apps.sourceforge.net/piwik/ruby-gnome2/piwik.php?idsite=1" alt="piwik"/></p></noscript></object>
<!-- End Piwik Tag -->
EOS
end
