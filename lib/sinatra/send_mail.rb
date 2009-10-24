require 'sinatra/base'
require 'net/smtp'

module Sinatra
   module SendMail
      module Helpers
         def send_mail(from, to, subject, message, opts = {})

            # Garapagoring
            if options.smtp_locale == 'ja_JP'
               require 'nkf'
               message = NKF.nkf("-Wjm0", message)
               if opts['content_type'] == 'text/html'
                  message.sub!(/content="text\/html; charset=UTF-8"/, 'content="text/html; charset=iso-2022-jp"')
               end
            end

            contents = mail_header(from, to, subject, opts)
            contents << message
            Net::SMTP.start(options.smtp_server, options.smtp_port,
                             options.smtp_domain,
                             opts['account'], opts['password'],
                             opts[' authtype']) {|smtp|
              smtp.sendmail( contents, from, to )
            }
         end

         private
         def mail_header(from, to, subject, opts)
            opts['content_type'] ||= 'text/plain'
            # Garapagoring
	    if options.smtp_locale == 'ja_JP'
               require 'nkf'
               subject = NKF.nkf("-WMm0", subject)
               cset = 'charset="iso-2022-jp"'
            end
            <<EOT.chomp('') + "\n\n"
From: #{from}
To: #{to}
Subject: #{subject}
Mime-Version: 1.0
Content-Type: #{opts['content_type']}; #{cset}
#{opts['extra_header']}
EOT
         end
      end

      def self.registered(app)
         app.helpers SendMail::Helpers

         app.set :smtp_server, 'localhost'
         app.set :smtp_port,   '25'
         app.set :smtp_domain, '127.0.0.1'
         app.set :smtp_locale, ''
     end
   end

   register SendMail
end
