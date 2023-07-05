#!/usr/bin/env bash

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

wordpress_dl="https://wordpress.org/latest.zip"
apache2_conf="https://www.dropbox.com/s/fj41jfcsg8o6v95/apache2.conf?dl=0"
apache2_event_conf="https://www.dropbox.com/s/jda4apdxt9l1fjk/apache2_event_conf.txt?dl=0"
salt_url="https://api.wordpress.org/secret-key/1.1/salt/"
nginx_conf="https://theifwd.com/config/snginx.vhost.conf"
php5_dotdeb="https://www.dropbox.com/s/w58x37rg5qwjuyd/php5_dotdeb.txt?dl=0"
php7_dotdeb="https://www.dropbox.com/s/9hw2e8eh5jl8zjn/php7_dotdeb.txt?dl=0"
php_sury="https://www.dropbox.com/s/d7y2c3h85q5do1i/php_sury.txt?dl=0"
php_sury_apache="https://www.dropbox.com/s/jgtddqbmnt59ggb/php_sury_apache.txt?dl=0"

tambah_domain_apache() {
        clear
        echo -e "##### Skrip add domain by Kaito Saikyou #####"
        echo -e "Telegram: \e[32mhttps://t.me/kaitosaikyo/${end}"
        echo -e "Email: \e[32mkaitosaikyotl@gmail.com${end}"
        echo "_________________"
        rm -fr wordpress latest.zip domain.txt domain-tanpa-titik.txt db_name.txt db_name1.txt u_name.txt u_name1.txt versi{1..4}.txt versi.txt /var/www/html/info.php
        echo
        echo "Mau tambah domain? Ga usah bingung lagi"
        echo "Yang perlu Anda masukkan hanya nama domain"
        echo
        echo "Skrip ini juga bisa digunakan untuk menginstall sub domain."
        echo "Yang perlu diinput nanti bukan nama domain, melainkan sub domainnya"
        echo "Misal domainnya bernama example.com, maka kalo mau install subdomain,"
        echo "input full URL sub domainnya, misalnya ${yel}sub.example.com${end}"
        echo
        echo "Silahkan ketik nama domain, misal ${blu}example.com${end}, tanpa www dan tanpa http"
        echo "(Kalo salah input hapus dengan CTRL + Backspace)"
        echo
        while true
        do
                read -p $'\e[34m'"Domain${end}: " domain
                read -p $'\e[34m'"Masukan nama domain (sekali lagi)${end}: " domain2
                echo
                [ "$domain" = "$domain2" ] && break
                echo "Nama domain ga cocok, ulang lagi ya!"
        done
        periksa="/etc/apache2/sites-available/$domain.conf"
        if [ -f "$periksa" ]
        then
                echo -e "\e[33mDomain tidak bisa diinstall karena sudah terpasang di server ini${end}"
                echo -e "\e[33mSilahkan jalankan kembali skrip ini, masukkan domain lain.${end}"
                echo ""
        else
                echo $domain >> domain.txt
                clean_domain_1=`sed 's/[^a-zA-Z0-9]//g'  domain.txt > domain-tanpa-titik.txt`
                untuk_db=`cat domain-tanpa-titik.txt`
                echo $untuk_db >> db_name1.txt
                echo $untuk_db >> u_name1.txt
                sed 's/^/db_/' db_name1.txt > db_name.txt
                sed 's/^/u_/' u_name1.txt > u_name.txt
                db_name=`cat db_name.txt`
                u_name=`cat u_name.txt`
                rm -f domain.txt domain-tanpa-titik.txt db_name.txt db_name1.txt u_name.txt u_name1.txt
                file="/root/.pwdmysql"
                if [ -f "$file" ]
                then
                        echo
                else
                        echo "Sorry, skrip ini hanya bekerja di server yang di setting Kaito Saikyo"
                        echo "Info lanjut silahkan chat Telegram https://t.me/kaitosaikyo/ "
                        exit 1
                fi
                echo "Sip, udah semua.."
                echo "Tekan '${yel}y${end}' lalu Enter untuk melanjutkan (tunggu maks. 1 menit)"
                read -p "Atau '${yel}t${end}' lalu Enter untuk membatalkan ... <y/t> ?" tanya
                echo
                if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
                then
                        echo "${blu}Mohon tunggu...${end}"
			ufw default deny outgoing > /dev/null 2>&1
			ufw allow out to any port 80 > /dev/null 2>&1
			ufw allow out to any port 443 > /dev/null 2>&1
			ufw allow out to any port 43 > /dev/null 2>&1
			ufw allow out to any port 53 > /dev/null 2>&1
			ufw allow out to any port 22 > /dev/null 2>&1
			ufw allow out to any port 51622 > /dev/null 2>&1
			service ufw restart > /dev/null 2>&1
                        echo
                        password_root_mysql=`cat /root/.pwdmysql`
                        password_wp_config=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`
                        mysql -uroot -p$password_root_mysql -e "CREATE DATABASE $db_name /*\!40100 DEFAULT CHARACTER SET utf8 */;"
                        mysql -uroot -p$password_root_mysql -e "CREATE USER $u_name@localhost IDENTIFIED BY '$password_wp_config';"
                        mysql -uroot -p$password_root_mysql -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$u_name'@'localhost';"
                        mysql -uroot -p$password_root_mysql -e "FLUSH PRIVILEGES;"
                        wget -q --no-check-certificate $apache2_conf -O master2.vhost
                        sed -i "s/xDOMAINx/$domain/g" master2.vhost
                        mv master2.vhost /etc/apache2/sites-available/$domain.conf
                        dos2unix /etc/apache2/sites-available/$domain.conf > /dev/null 2>&1
                        touch /root/.rnd
                        mkdir -p /etc/ssl/$domain
                        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/C=ID/ST=DKI/L=Jakarta/O=Tech/CN=$domain" -keyout /etc/ssl/$domain/$domain.key -out /etc/ssl/$domain/$domain.crt > /dev/null 2>&1
                        curl -L -# -k --connect-timeout 5 --retry 1 $wordpress_dl -o latest.zip
                        unzip -qq latest.zip
                        rm -f latest.zip
                        mv wordpress /var/www/html/$domain
                        mv /var/www/html/$domain/wp-config-sample.php /var/www/html/$domain/wp-config.php
                        sed -i "s/database_name_here/$db_name/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/username_here/$u_name/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/password_here/$password_wp_config/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/( '/('/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/' )/')/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/table_prefix =/table_prefix  =/g" /var/www/html/$domain/wp-config.php
                        salts=$(curl -s $salt_url)
                        while read -r salt; do
                        cari="define('$(echo "$salt" | cut -d "'" -f 2)"
                        ganti=$(echo "$salt" | cut -d "'" -f 4)
                        sed -i "/^$cari/s/put your unique phrase here/$(echo $ganti | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" /var/www/html/$domain/wp-config.php
                        done <<< "$salts"
                        dos2unix /var/www/html/$domain/wp-config.php > /dev/null 2>&1
                        chown -R www-data:www-data /var/www/html/$domain
                        a2ensite $domain > /dev/null 2>&1
                        service apache2 reload
                        clear
                        echo "_________________"
                        echo
                        echo "Selamat, domain ${blu}$domain${end} baru saja ditambahkan ke server ini"
                        echo "Silahkan daftarkan dan ganti NS ke NS Cloudflare, lalu tunggu +/- 30 menit supaya domain bisa diakses."
                        echo "_________________"
                        echo
                        echo "Setelah menunggu 30 menit-an, silahkan kunjungi:"
                        echo
                        echo "http://$domain"
                        echo
                        echo "Atau kalo domainnya ingin pake ${red}www${end} kunjungi"
                        echo
                        echo "http://www.$domain"
                        echo
                        echo "Anda nanti akan dibawa ke proses instalasi Wordpress"
                        echo "_________________"
                        echo
                        echo "Oia, Jika Anda perlu rincian database, silahkan gunakan rincian di bawah ini"
                        echo
                        echo "${yel}DATABASE${end}: $db_name"
                        echo "${yel}USERNAME${end}: $u_name"
                        echo "${yel}PASSWORD${end}: $password_wp_config"
                        echo
                else
                        rm -f db_name1.txt  db_name.txt  domain-tanpa-titik.txt  domain.txt  u_name1.txt  u_name.txt info.php
                        exit 0
                fi
        fi
}

reconfig_apache() {
        echo -e "\e[33m##### PERHATIAN: Ada Update #####${end}"
        echo "Konfigurasi Apache pada server Anda masih pake settingan lama"
        echo "Mau diperbaharui ngga?"
        echo
        echo "Kalo mau, tekan '${yel}y${end}' lalu Enter untuk melanjutkan (tunggu beberapa menit)"
        echo "Atau '${yel}t${end}' lalu Enter untuk tetap menggunakan settingan jadul."
        echo 
        echo "${blu}WARNING:${end}"
        echo "${red}Kalo salah satu web Anda ada yang pake format HTTPS${end}"
        echo "${red}yang SSL nya itu dapat beli, konsultasikan dulu ke saya${end}"
        echo "${red}Karena akan merusak settingan${end}"
        echo 
        read -p "Jawab <y/t> (Kalo ragu t aja, nanti kabari saya)?" tanya
        echo
        if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
        then
                echo "${blu}Siaap, sebentar ya...${end}"
                echo
                sleep 2
                echo -e "##### TAHAP 1 (dari 2) #####"
                echo
                ls -I 000-default.conf -I default-ssl.conf -I phpmyadmin.conf -I file-manager.conf -1 /etc/apache2/sites-enabled/ > list.txt
                sed -i 's/.conf//g' list.txt
                for domain in $(cat list.txt); do
                        unlink /etc/apache2/sites-enabled/$domain.conf
                        rm -f /etc/apache2/sites-available/$domain.conf
                        echo "Konfigurasi ulang domain ${blu}$domain${end} tahap 1 (dari 2)"
                done
                echo
                echo -e "##### TAHAP 2 (dari 2) #####"
                echo
                sleep 3
                for domain in $(cat list.txt); do
                        wget -q --no-check-certificate $apache2_conf -O master2.vhost
                        sed -i "s/xDOMAINx/$domain/g" master2.vhost
                        mv master2.vhost /etc/apache2/sites-available/$domain.conf
                        dos2unix /etc/apache2/sites-available/$domain.conf > /dev/null 2>&1
                        touch /root/.rnd
                        echo "Konfigurasi ulang domain ${blu}$domain${end} tahap 2 (dari 2)"
                        mkdir -p /etc/ssl/$domain
                        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/C=ID/ST=DKI/L=Jakarta/O=Tech/CN=$domain" -keyout /etc/ssl/$domain/$domain.key -out /etc/ssl/$domain/$domain.crt > /dev/null 2>&1
                        a2ensite $domain > /dev/null 2>&1
                done
                echo
                service apache2 reload
                echo "dh20180617" > /.dhversion
                rm -f list.txt
                echo "Mantaap, dalam ${red}5${end} detik, Anda akan dilanjutkan ke proses add domain seperti biasa"
                sleep 5
        else
                echo "Ya sudah kalo ga mau,"
                echo "Dalam ${red}5${end} detik Anda akan dilanjutkan ke proses add domain seperti biasa"
                sleep 5
                echo
        fi
        clear
        tambah_domain_apache
}



tambah_domain_apache_event() {
        clear
        echo -e "##### Skrip add domain by Kaito Saikyo #####"
        echo -e "Telegram: \e[32mhttps://t.me/kaitosaikyo/${end}"
        echo -e "Email: \e[33mkaitosaiktotl@gmail.com${end}"
        echo "_________________"
        rm -fr wordpress latest.zip domain.txt domain-tanpa-titik.txt db_name.txt db_name1.txt u_name.txt u_name1.txt versi{1..4}.txt versi.txt /var/www/html/info.php
        echo
        echo "Mau tambah domain? Ga usah bingung lagi"
        echo "Yang perlu Anda masukkan hanya nama domain"
        echo
        echo "Skrip ini juga bisa digunakan untuk menginstall sub domain."
        echo "Yang perlu diinput nanti bukan nama domain, melainkan sub domainnya"
        echo "Misal domainnya bernama example.com, maka kalo mau install subdomain,"
        echo "input full URL sub domainnya, misalnya ${yel}sub.example.com${end}"
        echo
        echo "Silahkan ketik nama domain, misal ${blu}example.com${end}, tanpa www dan tanpa http"
        echo "(Kalo salah input hapus dengan CTRL + Backspace)"
        echo
        while true
        do
                read -p $'\e[34m'"Domain${end}: " domain
                read -p $'\e[34m'"Masukan nama domain (sekali lagi)${end}: " domain2
                echo
                [ "$domain" = "$domain2" ] && break
                echo "Nama domain ga cocok, ulang lagi ya!"
        done
        periksa="/etc/apache2/sites-available/$domain.conf"
        if [ -f "$periksa" ]
        then
                echo -e "\e[33mDomain tidak bisa diinstall karena sudah terpasang di server ini${end}"
                echo -e "\e[33mSilahkan jalankan kembali skrip ini, masukkan domain lain.${end}"
                echo ""
        else
                echo $domain >> domain.txt
                clean_domain_1=`sed 's/[^a-zA-Z0-9]//g'  domain.txt > domain-tanpa-titik.txt`
                untuk_db=`cat domain-tanpa-titik.txt`
                echo $untuk_db >> db_name1.txt
                echo $untuk_db >> u_name1.txt
                sed 's/^/db_/' db_name1.txt > db_name.txt
                sed 's/^/u_/' u_name1.txt > u_name.txt
                db_name=`cat db_name.txt`
                u_name=`cat u_name.txt`
                rm -f domain.txt domain-tanpa-titik.txt db_name.txt db_name1.txt u_name.txt u_name1.txt
                file="/root/.pwdmysql"
                if [ -f "$file" ]
                then
                        echo
                else
                        echo "Sorry, skrip ini hanya bekerja di server yang di setting Kaito Saikyo"
                        echo "Info lanjut silahkan chat Telegram https://t.me/kaitosaikyo "
                        exit 1
                fi
                echo "Sip, udah semua.."
                echo "Tekan '${yel}y${end}' lalu Enter untuk melanjutkan (tunggu maks. 1 menit)"
                read -p "Atau '${yel}t${end}' lalu Enter untuk membatalkan ... <y/t> ?" tanya
                echo
                if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
                then
                        echo "${blu}Mohon tunggu...${end}"
			ufw default deny outgoing > /dev/null 2>&1
			ufw allow out to any port 80 > /dev/null 2>&1
			ufw allow out to any port 443 > /dev/null 2>&1
			ufw allow out to any port 43 > /dev/null 2>&1
			ufw allow out to any port 53 > /dev/null 2>&1
			ufw allow out to any port 22 > /dev/null 2>&1
			ufw allow out to any port 51622 > /dev/null 2>&1
			service ufw restart > /dev/null 2>&1
                        echo
                        password_root_mysql=`cat /root/.pwdmysql`
                        password_wp_config=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`
                        mysql -uroot -p$password_root_mysql -e "CREATE DATABASE $db_name /*\!40100 DEFAULT CHARACTER SET utf8 */;"
                        mysql -uroot -p$password_root_mysql -e "CREATE USER $u_name@localhost IDENTIFIED BY '$password_wp_config';"
                        mysql -uroot -p$password_root_mysql -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$u_name'@'localhost';"
                        mysql -uroot -p$password_root_mysql -e "FLUSH PRIVILEGES;"
                        php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1 > versi-php.txt
                        awk '{ print $4 }' versi-php.txt > versi-php1.txt
                        cut -c -3 versi-php1.txt > suryphp.txt
                        suryphp=`cat suryphp.txt`
                        rm -f versi-php.txt versi-php1.txt suryphp.txt
                        wget -q --no-check-certificate $apache2_event_conf -O master2.vhost
                        sed -i "s/xDOMAINx/$domain/g" master2.vhost
                        sed -i "s/xGANTIx/$suryphp/g" master2.vhost
                        mv master2.vhost /etc/apache2/sites-available/$domain.conf
                        dos2unix /etc/apache2/sites-available/$domain.conf > /dev/null 2>&1
                        wget -q $php_sury_apache -O /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        sed -i "s/xDOMAINx/$domain/g" /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        sed -i "s/xGANTIx/$suryphp/g" /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        echo "" >> /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        dos2unix /etc/php/$suryphp/fpm/pool.d/$domain.conf > /dev/null 2>&1
                        service php$suryphp-fpm reload
                        touch /root/.rnd
                        mkdir -p /etc/ssl/$domain
                        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/C=ID/ST=DKI/L=Jakarta/O=Tech/CN=$domain" -keyout /etc/ssl/$domain/$domain.key -out /etc/ssl/$domain/$domain.crt > /dev/null 2>&1
                        curl -L -# -k --connect-timeout 5 --retry 1 $wordpress_dl -o latest.zip
                        unzip -qq latest.zip
                        rm -f latest.zip
                        mv wordpress /var/www/html/$domain
                        mv /var/www/html/$domain/wp-config-sample.php /var/www/html/$domain/wp-config.php
                        sed -i "s/database_name_here/$db_name/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/username_here/$u_name/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/password_here/$password_wp_config/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/( '/('/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/' )/')/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/table_prefix =/table_prefix  =/g" /var/www/html/$domain/wp-config.php
                        salts=$(curl -s $salt_url)
                        while read -r salt; do
                        cari="define('$(echo "$salt" | cut -d "'" -f 2)"
                        ganti=$(echo "$salt" | cut -d "'" -f 4)
                        sed -i "/^$cari/s/put your unique phrase here/$(echo $ganti | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" /var/www/html/$domain/wp-config.php
                        done <<< "$salts"
                        dos2unix /var/www/html/$domain/wp-config.php > /dev/null 2>&1
                        chown -R www-data:www-data /var/www/html/$domain
                        a2ensite $domain > /dev/null 2>&1
                        service apache2 reload
                        clear
                        echo "_________________"
                        echo
                        echo "Selamat, domain ${blu}$domain${end} baru saja ditambahkan ke server ini"
                        echo "Silahkan daftarkan dan ganti NS ke NS Cloudflare, lalu tunggu +/- 30 menit supaya domain bisa diakses."
                        echo "_________________"
                        echo
                        echo "Setelah menunggu 30 menit-an, silahkan kunjungi:"
                        echo
                        echo "http://$domain"
                        echo
                        echo "Atau kalo domainnya ingin pake ${red}www${end} kunjungi"
                        echo
                        echo "http://www.$domain"
                        echo
                        echo "Anda nanti akan dibawa ke proses instalasi Wordpress"
                        echo "_________________"
                        echo
                        echo "Oia, Jika Anda perlu rincian database, silahkan gunakan rincian di bawah ini"
                        echo
                        echo "${yel}DATABASE${end}: $db_name"
                        echo "${yel}USERNAME${end}: $u_name"
                        echo "${yel}PASSWORD${end}: $password_wp_config"
                        echo
                else
                        rm -f db_name1.txt  db_name.txt  domain-tanpa-titik.txt  domain.txt  u_name1.txt  u_name.txt info.php
                        exit 0
                fi
        fi
}


reconfig_apache_event() {
        echo -e "\e[33m##### PERHATIAN: Ada Update #####${end}"
        echo "Konfigurasi Apache pada server Anda masih pake settingan lama"
        echo "Mau diperbaharui ngga?"
        echo
        echo "Kalo mau, tekan '${yel}y${end}' lalu Enter untuk melanjutkan (tunggu beberapa menit)"
        echo "Atau '${yel}t${end}' lalu Enter untuk tetap menggunakan settingan jadul."
        echo 
        echo "${blu}WARNING:${end}"
        echo "${red}Kalo salah satu web Anda ada yang pake format HTTPS${end}"
        echo "${red}yang SSL nya itu dapat beli, konsultasikan dulu ke saya${end}"
        echo "${red}Karena akan merusak settingan${end}"
        echo 
        read -p "Jawab <y/t> (Kalo ragu t aja, nanti kabari saya)?" tanya
        echo
        if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
        then
                echo "${blu}Siaap, sebentar ya...${end}"
                echo
                sleep 2
                echo -e "##### TAHAP 1 (dari 2) #####"
                echo
                ls -I 000-default.conf -I default-ssl.conf -I phpmyadmin.conf -I file-manager.conf -1 /etc/apache2/sites-enabled/ > list.txt
                sed -i 's/.conf//g' list.txt
                for domain in $(cat list.txt); do
                        unlink /etc/apache2/sites-enabled/$domain.conf
                        rm -f /etc/apache2/sites-available/$domain.conf
                        echo "Konfigurasi ulang domain ${blu}$domain${end} tahap 1 (dari 2)"
                done
                echo
                echo -e "##### TAHAP 2 (dari 2) #####"
                echo
                sleep 3
                php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1 > versi-php.txt
                awk '{ print $4 }' versi-php.txt > versi-php1.txt
                cut -c -3 versi-php1.txt > suryphp.txt
                suryphp=`cat suryphp.txt`
                rm -f versi-php.txt versi-php1.txt suryphp.txt
                for domain in $(cat list.txt); do
                        wget -q --no-check-certificate $apache2_event_conf -O master2.vhost
                        sed -i "s/xDOMAINx/$domain/g" master2.vhost
                        sed -i "s/xGANTIx/$suryphp/g" master2.vhost
                        mv master2.vhost /etc/apache2/sites-available/$domain.conf
                        dos2unix /etc/apache2/sites-available/$domain.conf > /dev/null 2>&1
                        wget -q $php_sury_apache -O /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        sed -i "s/xDOMAINx/$domain/g" /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        sed -i "s/xGANTIx/$suryphp/g" /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        echo "" >> /etc/php/$suryphp/fpm/pool.d/$domain.conf
                        dos2unix /etc/php/$suryphp/fpm/pool.d/$domain.conf > /dev/null 2>&1
                        service php$suryphp-fpm reload
                        touch /root/.rnd
                        echo "Konfigurasi ulang domain ${blu}$domain${end} tahap 2 (dari 2)"
                        mkdir -p /etc/ssl/$domain
                        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/C=ID/ST=DKI/L=Jakarta/O=Tech/CN=$domain" -keyout /etc/ssl/$domain/$domain.key -out /etc/ssl/$domain/$domain.crt > /dev/null 2>&1
                        a2ensite $domain > /dev/null 2>&1
                done
                echo
                service apache2 reload
                echo "dh20180617" > /.dhversion
                rm -f list.txt
                echo "Mantaap, dalam ${red}5${end} detik, Anda akan dilanjutkan ke proses add domain seperti biasa"
                sleep 5
        else
                echo "Ya sudah kalo ga mau,"
                echo "Dalam ${red}5${end} detik Anda akan dilanjutkan ke proses add domain seperti biasa"
                sleep 5
                echo
        fi
        clear
        tambah_domain_apache_event
}




tambah_domain_nginx() {
        clear
        echo -e "##### Skrip add domain by Kaito Saikyo #####"
        echo -e "Telegram: \e[32mhttps://t.me/kaitosaikyo/${end}"
        echo -e "Email: \e[kaitosaikyotl@gmail.com{end}"
        echo "_________________"
        rm -fr wordpress latest.zip domain.txt domain-tanpa-titik.txt db_name.txt db_name1.txt u_name.txt u_name1.txt versi{1..4}.txt versi.txt /var/www/html/info.php
        echo
        echo "Mau tambah domain? Ga usah bingung lagi"
        echo "Yang perlu Anda masukkan hanya nama domain"
        echo
        echo "Skrip ini juga bisa digunakan untuk menginstall sub domain."
        echo "Yang perlu diinput nanti bukan nama domain, melainkan sub domainnya"
        echo "Misal domainnya bernama example.com, maka kalo mau install subdomain,"
        echo "input full URL sub domainnya, misalnya ${yel}sub.example.com${end}"
        echo
        echo "Silahkan ketik nama domain, misal ${blu}example.com${end}, tanpa www dan tanpa http"
        echo "(Kalo salah input hapus dengan CTRL + Backspace)"
        echo
        while true
        do
                read -p $'\e[34m'"Domain${end}: " domain
                read -p $'\e[34m'"Masukan nama domain (sekali lagi)${end}: " domain2
                echo
                [ "$domain" = "$domain2" ] && break
                echo "Nama domain ga cocok, ulang lagi ya!"
        done
        periksa="/etc/nginx/sites-available/$domain"
        if [ -f "$periksa" ]
        then
                echo -e "\e[33mDomain tidak bisa diinstall karena sudah terpasang di server ini${end}"
                echo -e "\e[33mSilahkan jalankan kembali skrip ini, masukkan domain lain.${end}"
                echo ""
        else
                echo 'limit_req_zone $binary_remote_addr zone=limit:10m rate=20r/m;' > /etc/nginx/conf.d/limit.conf
                echo $domain >> domain.txt
                clean_domain_1=`sed 's/[^a-zA-Z0-9]//g'  domain.txt > domain-tanpa-titik.txt`
                untuk_db=`cat domain-tanpa-titik.txt`
                echo $untuk_db >> db_name1.txt
                echo $untuk_db >> u_name1.txt
                sed 's/^/db_/' db_name1.txt > db_name.txt
                sed 's/^/u_/' u_name1.txt > u_name.txt
                db_name=`cat db_name.txt`
                u_name=`cat u_name.txt`
                rm -f domain.txt domain-tanpa-titik.txt db_name.txt db_name1.txt u_name.txt u_name1.txt
                file="/root/.pwdmysql"
                if [ -f "$file" ]
                then
                        echo
                else
                        echo "Sorry, skrip ini hanya bekerja di server yang di setting Kaito Saikyo"
                        echo "Info lanjut silahkan chat Telegram https://t.me/kaitosaikyo "
                        exit 1
                fi
                echo "Sip, udah semua.."
                echo "Tekan '${yel}y${end}' lalu Enter untuk melanjutkan (tunggu maks. 1 menit)"
                read -p "Atau '${yel}t${end}' lalu Enter untuk membatalkan ... <y/t> ?" tanya
                echo
                if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
                then
                        echo "${blu}Mohon tunggu...${end}"
			ufw default deny outgoing > /dev/null 2>&1
			ufw allow out to any port 80 > /dev/null 2>&1
			ufw allow out to any port 443 > /dev/null 2>&1
			ufw allow out to any port 43 > /dev/null 2>&1
			ufw allow out to any port 53 > /dev/null 2>&1
			ufw allow out to any port 22 > /dev/null 2>&1
			ufw allow out to any port 51622 > /dev/null 2>&1
			service ufw restart > /dev/null 2>&1
                        echo
                        password_root_mysql=`cat /root/.pwdmysql`
                        password_wp_config=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1`
                        mysql -uroot -p$password_root_mysql -e "CREATE DATABASE $db_name /*\!40100 DEFAULT CHARACTER SET utf8 */;"
                        mysql -uroot -p$password_root_mysql -e "CREATE USER $u_name@localhost IDENTIFIED BY '$password_wp_config';"
                        mysql -uroot -p$password_root_mysql -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$u_name'@'localhost';"
                        mysql -uroot -p$password_root_mysql -e "FLUSH PRIVILEGES;"
                        php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1 > versi-php.txt
                        awk '{ print $4 }' versi-php.txt > versi-php1.txt
                        cut -c -1 versi-php1.txt > jessie_php.txt
                        jessie_php=`cat jessie_php.txt`
                        cut -c -3 versi-php1.txt > stretch_php.txt
                        stretch_php=`cat stretch_php.txt`
                        rm -f versi-php.txt versi-php1.txt jessie_php.txt stretch_php.txt
                        wget -q --no-check-certificate $nginx_conf -O master.vhost
                        debversion=`lsb_release -sc`
                        if [ "$debversion" = "jessie" ]; then
                                if [ $jessie_php = 5 ]
                                then
                                        sed -i 's/xGANTIx/unix:\/var\/run\/php5-'$domain'-fpm.sock/g' master.vhost
                                        echo "" >>  master.vhost
                                        wget -q $php5_dotdeb -O /etc/php5/fpm/pool.d/$domain.conf
                                        sed -i "s/xDOMAINx/$domain/g" /etc/php5/fpm/pool.d/$domain.conf
                                        echo "" >> /etc/php5/fpm/pool.d/$domain.conf
                                        dos2unix /etc/php5/fpm/pool.d/$domain.conf > /dev/null 2>&1
                                        service php5-fpm reload
                                else
                                        sed -i 's/xGANTIx/unix:\/run\/php\/php7.0-'$domain'-fpm.sock/g' master.vhost
                                        echo "" >>  master.vhost
                                        wget -q $php7_dotdeb -O /etc/php/7.0/fpm/pool.d/$domain.conf
                                        sed -i "s/xDOMAINx/$domain/g" /etc/php/7.0/fpm/pool.d/$domain.conf
                                        echo "" >> /etc/php/7.0/fpm/pool.d/$domain.conf
                                        dos2unix /etc/php/7.0/fpm/pool.d/$domain.conf > /dev/null 2>&1
                                        service php7.0-fpm reload
                                fi
                        elif [ "$debversion" = "stretch" ] || [ "$debversion" = "buster" ] || [ "$debversion" = "bullseye" ]; then
                                sed -i 's/xGANTIx/unix:\/run\/php\/php'$stretch_php'-'$domain'-fpm.sock/g' master.vhost
                                echo "" >>  master.vhost
                                wget -q $php_sury -O /etc/php/$stretch_php/fpm/pool.d/$domain.conf
                                sed -i "s/xDOMAINx/$domain/g" /etc/php/$stretch_php/fpm/pool.d/$domain.conf
                                sed -i 's/xGANTIx/'$stretch_php'/g' /etc/php/$stretch_php/fpm/pool.d/$domain.conf
                                echo "" >> /etc/php/$stretch_php/fpm/pool.d/$domain.conf
                                dos2unix /etc/php/$stretch_php/fpm/pool.d/$domain.conf > /dev/null 2>&1
                                service php$stretch_php-fpm reload
                        else
                                sed -i 's/xGANTIx/unix:\/var\/run\/php5-'$domain'-fpm.sock/g' master.vhost
                                echo "" >>  master.vhost
                                wget -q $php5_dotdeb -O /etc/php5/fpm/pool.d/$domain.conf
                                sed -i "s/xDOMAINx/$domain/g" /etc/php5/fpm/pool.d/$domain.conf
                                echo "" >> /etc/php5/fpm/pool.d/$domain.conf
                                dos2unix /etc/php5/fpm/pool.d/$domain.conf > /dev/null 2>&1
                                service php5-fpm reload
                        fi
                        sed -i "s/xDOMAINx/$domain/g" master.vhost
                        mv master.vhost /etc/nginx/sites-available/$domain
                        dos2unix /etc/nginx/sites-available/$domain > /dev/null 2>&1
                        sed -i '/robots.txt {/a \\t        try_files $uri $uri/ /index.php?$args;' /etc/nginx/sites-available/$domain
			sed -i '/fastcgi_split_path_info/a \\t        fastcgi_param PHP_VALUE open_basedir="/tmp/:/usr/share/php/:/dev/urandom:/dev/shm:/var/lib/php/sessions/:$document_root";' /etc/nginx/sites-available/$domain
                        ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
                        curl -L -# -k --connect-timeout 5 --retry 1 $wordpress_dl -o latest.zip
                        unzip -qq latest.zip
                        rm -f latest.zip
                        mv wordpress /var/www/html/$domain
                        mv /var/www/html/$domain/wp-config-sample.php /var/www/html/$domain/wp-config.php
                        sed -i "s/database_name_here/$db_name/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/username_here/$u_name/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/password_here/$password_wp_config/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/( '/('/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/' )/')/g" /var/www/html/$domain/wp-config.php
                        sed -i "s/table_prefix =/table_prefix  =/g" /var/www/html/$domain/wp-config.php
                        salts=$(curl -s $salt_url)
                        while read -r salt; do
                        cari="define('$(echo "$salt" | cut -d "'" -f 2)"
                        ganti=$(echo "$salt" | cut -d "'" -f 4)
                        sed -i "/^$cari/s/put your unique phrase here/$(echo $ganti | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" /var/www/html/$domain/wp-config.php
                        done <<< "$salts"
                        dos2unix /var/www/html/$domain/wp-config.php > /dev/null 2>&1
                        chown -R www-data:www-data /var/www/html/$domain
                        rm -f latest.zip
                        mkdir -p /etc/ssl/$domain/
                        touch /root/.rnd
                        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -subj "/C=ID/ST=DKI/L=Jakarta/O=Tech/CN=$domain" -keyout /etc/ssl/$domain/$domain.key -out /etc/ssl/$domain/$domain.crt > /dev/null 2>&1
                        service nginx reload
                        clear
                        echo "_________________"
                        echo
                        echo "Selamat, domain ${blu}$domain${end} baru saja ditambahkan ke server ini"
                        echo "Silahkan daftarkan dan ganti NS ke NS Cloudflare, lalu tunggu +/- 30 menit supaya domain bisa diakses."
                        echo "_________________"
                        echo
                        echo "Setelah menunggu 30 menit-an, silahkan kunjungi:"
                        echo
                        echo "http://$domain"
                        echo
                        echo "Atau kalo domainnya ingin pake ${red}www${end} kunjungi"
                        echo
                        echo "http://www.$domain"
                        echo
                        echo "Anda nanti akan dibawa ke proses instalasi Wordpress"
                        echo "_________________"
                        echo
                        echo "Oia, Jika Anda perlu rincian database, silahkan gunakan rincian di bawah ini"
                        echo
                        echo "${yel}DATABASE${end}: $db_name"
                        echo "${yel}USERNAME${end}: $u_name"
                        echo "${yel}PASSWORD${end}: $password_wp_config"
                        echo
                else
                        rm -f db_name1.txt  db_name.txt  domain-tanpa-titik.txt  domain.txt  u_name1.txt  u_name.txt info.php
                        exit 0
                fi
        fi
}


reconfig_nginx() {
	clear
        echo -e "\e[33m##### PERHATIAN: Ada Update NGINX #####${end}"
        echo "Konfigurasi Nginx pada server Anda masih pake settingan lama"
        echo "Silahkan, tekan '${yel}y${end}' lalu Enter untuk melanjutkan (tunggu beberapa menit)"
        echo "Atau '${yel}t${end}' lalu Enter untuk tetap menggunakan settingan jadul."
        echo 
        read -p "Jawab <y/t> (Rekomendasi saya "y" tapi kalo ragu "t" aja, nanti kabari saya via WA / email)?" tanya
        echo
        if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
        then
                echo "${blu}Siaap, sebentar ya...${end}"
                echo
                sleep 2
                echo -e "##### TAHAP UPDATE #####"
                echo
                ls -I default -I phpmyadmin -I filemanager -1 /etc/nginx/sites-enabled/ > list.txt
                for domain in $(cat list.txt); do
		if grep -q wp-login.php /etc/nginx/sites-available/$domain; then
			sed -i '/fastcgi_split_path_info/a \\t        fastcgi_param PHP_VALUE open_basedir="/tmp/:/usr/share/php/:/dev/urandom:/dev/shm:/var/lib/php/sessions/:$document_root";' /etc/nginx/sites-available/$domain
			else
			sleep 1
		fi
		echo "Update konfigurasi domain ${blu}$domain${end}"
		done
	        echo
		sed -i '/fastcgi_split_path_info/a \\t        fastcgi_param PHP_VALUE open_basedir="/tmp/:/usr/share/php/:/dev/urandom:/dev/shm:/var/lib/php/sessions/:$document_root";' /etc/nginx/sites-available/default
		sed -i '/fastcgi_split_path_info/a \\t        fastcgi_param PHP_VALUE open_basedir="/tmp/:/usr/share/php/:/dev/urandom:/dev/shm:/var/lib/php/sessions/:/var/www/html:$document_root";' /etc/nginx/sites-available/phpmyadmin
                nginx -t > /dev/null 2>&1 && service nginx reload
                echo "dh20221013" > /.dhversion
                rm -f list.txt
                echo "Mantaap, dalam ${red}3${end} detik, Anda akan dilanjutkan ke proses add domain seperti biasa"
                sleep 3
        else
                echo "Ya sudah kalo ga mau."
		echo
                echo "Dalam ${red}3${end} detik Anda akan dilanjutkan ke proses add domain seperti biasa"
                sleep 3
                echo
        fi
        clear
        tambah_domain_nginx
}


ganti_fm_nginx() {
        echo -e "\e[33m##### PERHATIAN: Ada Update FILE MANAGER #####${end}"
        echo 
        echo "1. Saya dapat email dari developer FileRun (File Manager)"
        echo "   bahwa versi file manager yang terpasang di server Anda"
	echo "   adalah versi yang tidak aman (ngga tau bener apa ngga)."
	echo
        echo "2. Saya juga dilarang untuk nginstall FileRun"
        echo "   versi lama di server."
        echo 
        echo "Karena 2 alasan itu, saya akan ganti file manager nya"
        echo "menggunakan skrip lain."
        echo 
        read -p "Jawab <y/t> (jawab "y" tapi kalo ragu "t" aja, nanti kabari saya via WA / email)?" tanya
        echo
        if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
        then
                echo "${blu}Siaap, sebentar ya...${end}"
                echo
                sleep 1
                echo -e "##### TAHAP GANTI #####"
                echo
		sleep 1
		wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - > /dev/null 2>&1
		apt update -y
		apt install apache2-utils -y > /dev/null 2>&1
		cd /etc/nginx/sites-available/
		wget https://prk.hardinal.com/cihuy/filemanager74.txt -O filemanager > /dev/null 2>&1
		sed -i '/fastcgi_split_path_info/a \\t        fastcgi_param PHP_VALUE open_basedir="/tmp/:/usr/share/php/:/dev/urandom:/dev/shm:/var/lib/php/sessions/:/var/www/html:$document_root";' /etc/nginx/sites-available/filemanager
		dos2unix filemanager > /dev/null 2>&1
		cd ~/
		ln -sf /etc/nginx/sites-available/filemanager /etc/nginx/sites-enabled/
		rm -fr /var/www/filemanager
		mkdir -p /var/www/filemanager
		curl -L -# -k --connect-timeout 5 --retry 1 'https://prk.hardinal.com/cihuy/401fm.txt' -o /usr/share/nginx/html/401fm.html
		curl -L -# -k --connect-timeout 5 --retry 1 'https://prk.hardinal.com/filemanager74.zip' -o /var/www/filemanager/fm.zip
		unzip -q /var/www/filemanager/fm.zip -d /var/www/filemanager/
		chown -R www-data: /var/www/filemanager/.trash/
		rm -f  /var/www/filemanager/fm.zip
		passfm=$(cat /root/.pwdmysql)
		/usr/bin/htpasswd -b -c /etc/nginx/.htpasswd root $passfm > /dev/null 2>&1
	        php -r \@phpinfo\(\)\; | grep 'PHP Version' -m 1 > versi-php.txt
	        awk '{ print $4 }' versi-php.txt > versi-php1.txt
	        cut -c -1 versi-php1.txt > jessie_php.txt
	        jessie_php=`cat jessie_php.txt`
	        cut -c -3 versi-php1.txt > stretch_php.txt
	        stretch_php=`cat stretch_php.txt`
	        rm -f versi-php.txt versi-php1.txt jessie_php.txt stretch_php.txt
	        debversion=`lsb_release -sc`
	        if [ "$debversion" = "jessie" ]; then
	                if [ $jessie_php = 5 ]
	                then
				sed -i 's/php7.4/php5/g' /etc/nginx/sites-available/filemanager
	                        service php5-fpm reload
	                else
				sed -i 's/php7.4/php7.0/g' /etc/nginx/sites-available/filemanager
	                        service php7.0-fpm reload
	                fi
	        elif [ "$debversion" = "stretch" ] || [ "$debversion" = "buster" ] || [ "$debversion" = "bullseye" ]; then
			sed -i 's/php7.4/php'$stretch_php'/g' /etc/nginx/sites-available/filemanager
	                service php$stretch_php-fpm reload
	        else
			sed -i 's/php7.4/php5/g' /etc/nginx/sites-available/filemanager
	                service php5-fpm reload
	        fi
		service nginx reload
		rm -fr /var/www/html/.filerun.trash
                ls -I default -I phpmyadmin -I filemanager -1 /etc/nginx/sites-enabled/ > ~/list.txt
                for domain in $(cat list.txt); do
			rm -fr /var/www/html/$domain/.filerun.versioning
		done
		rm -f ~/list.txt
		cekipv4=`/bin/hostname -I | awk '{ print $1 }'`
		clear
		echo "Mantaap, File Manager sudah berganti."
		echo "Anda bisa login ke File Manager menggunakan rincian berikut,"
		echo
		echo "${cyn}http://${grn}$cekipv4${end}${mag}:51624${end}${cyn}/${end}"
		echo "Username: ${yel}root${end}"
		echo "Password: ${blu}$passfm${end}"
		echo
		echo "Tapi jika Anda mau catat ulang, silahkan."
		echo
		read -t 120 -n 1 -s -r -p "Pencet Enter di keyboard untuk lanjut ke proses add domain..."
		echo
        else
		clear
                echo "Ya sudah kalo ga mau."
		echo
                echo "Silahkan Anda ulang skrip ini jika File Manager ingin diganti"
                echo
		sleep 3
        fi
}



ganti_fm_apache() {
        echo -e "\e[33m##### PERHATIAN: Ada Update FILE MANAGER #####${end}"
        echo 
        echo "1. Saya dapat email dari developer FileRun (File Manager)"
        echo "   bahwa versi file manager yang terpasang di server Anda"
	echo "   adalah versi yang tidak aman (ngga tau bener apa ngga)."
	echo
        echo "2. Saya juga dilarang untuk nginstall FileRun"
        echo "   versi lama di server."
        echo 
        echo "Karena 2 alasan itu, saya akan ganti file manager nya"
        echo "menggunakan skrip lain."
        echo 
        read -p "Jawab <y/t> (jawab "y" tapi kalo ragu "t" aja, nanti kabari saya via WA / email)?" tanya
        echo
        if [[ $tanya == "y" || $tanya == "Y" || $tanya == "yes" || $tanya == "Yes" || $tanya == "Ya" || $tanya == "ya" ]]
        then
                echo "${blu}Siaap, sebentar ya...${end}"
                echo
                sleep 1
                echo -e "##### TAHAP GANTI #####"
                echo
		sleep 1
		wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - > /dev/null 2>&1
		apt update -y
		apt install apache2-utils -y > /dev/null 2>&1
		wget prk.hardinal.com/apache/file-manager.conf -O /etc/apache2/sites-available/file-manager.conf  > /dev/null 2>&1
		rm -fr /var/www/filemanager
		mkdir -p /var/www/filemanager
		curl -L -# -k --connect-timeout 5 --retry 1 'https://prk.hardinal.com/filemanager74.zip' -o /var/www/filemanager/fm.zip
		unzip -q /var/www/filemanager/fm.zip -d /var/www/filemanager/
		chown -R www-data: /var/www/filemanager/.trash/
		rm -f  /var/www/filemanager/fm.zip
		passfm=$(cat /root/.pwdmysql)
		/usr/bin/htpasswd -b -c /etc/apache2/.htpasswd root $passfm > /dev/null 2>&1
		service apache2 reload > /dev/null 2>&1
		cekipv4=`/bin/hostname -I | awk '{ print $1 }'`
		clear
		echo "Mantaap, File Manager sudah berganti."
		echo "Anda bisa login ke File Manager menggunakan rincian yang pernah saya email:"
		echo
		echo "${cyn}http://${grn}$cekipv4${end}${mag}:51624${end}${cyn}/${end}"
		echo "Username: ${yel}root${end}"
		echo "Password: ${blu}$passfm${end}"
		echo
		echo "Rincian di atas, ada di email."
		echo "Tapi jika Anda mau catat ulang, silahkan."
		echo
		read -t 120 -n 1 -s -r -p "Pencet Enter di keyboard untuk lanjut ke proses add domain..."
		echo
        else
		clear
                echo "Ya sudah kalo ga mau."
		echo
                echo "Silahkan Anda ulang skrip ini jika File Manager ingin diganti"
                echo
		sleep 3
        fi
}




clear


file_filerun="/var/www/filemanager/system/data/autoconfig.php"
if [ -f "$file_filerun" ]
then
        if [[ `ps acx|grep apache|wc -l` > 0 ]] && [[ `a2query -M` == 'prefork' ]]; then
                echo
        fi
        if [[ `ps acx|grep apache|wc -l` > 0 ]] && [[ `a2query -M` == 'event' ]]; then
                ganti_fm_apache
        fi
        if [[ `ps acx|grep nginx|wc -l` > 0 ]]; then
                ganti_fm_nginx
        fi
else
	echo
fi



dh_version="/.dhversion"
if [ -f "$dh_version" ] && grep "dh20221013" $dh_version
then
        if [[ `ps acx|grep apache|wc -l` > 0 ]] && [[ `a2query -M` == 'prefork' ]]; then
                tambah_domain_apache
        fi
        if [[ `ps acx|grep apache|wc -l` > 0 ]] && [[ `a2query -M` == 'event' ]]; then
                tambah_domain_apache_event
        fi
        if [[ `ps acx|grep nginx|wc -l` > 0 ]]; then
                tambah_domain_nginx
        fi
else
        if [[ `ps acx|grep apache|wc -l` > 0 ]] && [[ `a2query -M` == 'prefork' ]]; then
                echo "dh20221013" > /.dhversion
		tambah_domain_apache
        fi
        if [[ `ps acx|grep apache|wc -l` > 0 ]] && [[ `a2query -M` == 'event' ]]; then
                echo "dh20221013" > /.dhversion
		tambah_domain_apache
        fi
        if [[ `ps acx|grep nginx|wc -l` > 0 ]]; then
                reconfig_nginx
        fi
fi
