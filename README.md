Requirements to run on local machine:

sudo apt-get install ssmtp

Setting up gmail email server: 
Make sure you enable 'allow less secure apps' on gmail settings

echo 'UseSTARTTLS=YES
FromLineOverride=YES
root=admin@example.com
mailhub=smtp.gmail.com:587
AuthUser=MYEMAIL@GMAIL.COM
AuthPass=MYPASSOWRD' >> /etc/ssmtp/ssmtp.conf