def sendmail(subject, body)
  require 'time'
  message = <<EndOfMail
From: #{@conf.mail_from ? @conf.mail_from : @conf.mail}
To: #{@conf.mail.untaint}
Subject: #{subject.to_jis}
Date: #{Time.now.rfc2822}
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
X-Mailer: Hiki #{HIKI_VERSION}

#{body.to_jis}
EndOfMail

  open( "|/usr/sbin/sendmail #{@conf.mail}", 'w' ) do |o|
     o.write(message)
  end
end

