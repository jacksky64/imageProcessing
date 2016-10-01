function send_mail(to, subject, txt)

FROM = 'me@myhost.invalid';             % for gmail, this is the email address
SMTPSERVER = 'smtp.myhost.invalid';     % for gmail: smtp.gmail.com
SMTPUSER   = 'MYUSERNAME';              % for gmail, this is again the email address
SMTPPASSWD = 'MYPASSWORD';              % password in plain text (not secure!)

setpref('Internet','SMTP_Server',SMTPSERVER);
setpref('Internet','SMTP_Username',SMTPUSER);
setpref('Internet','SMTP_Password',SMTPPASSWD);
setpref('Internet','E_mail',FROM);

% SSL authentification (gmail needs this)
jprops = java.lang.System.getProperties;
jprops.setProperty('mail.smtp.auth','true');
jprops.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
jprops.setProperty('mail.smtp.socketFactory.port','465');

sendmail(to, subject, txt);
