module Hiki::Filter
  add_filter do |new_page, old_page, posted_by_user|
    trap_mail = @cgi.params["trap-mail"][0] || ''
    trap_password = @cgi.params["trap-password"][0] || ''
    !trap_mail.empty? or !trap_password.empty?
  end
end
