#!/bin/bash
#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
install_ss_panel_mod_v3(){
	yum -y remove httpd
	yum install -y unzip zip git
	num=$1
	if [ "${num}" != "1" ]; then
  	  wget -c --no-check-certificate https://raw.githubusercontent.com/kentcc88/usefulinfo_02/master/lnmp1.4.zip && unzip lnmp1.4.zip && rm -rf lnmp1.4.zip && cd lnmp1.4 && chmod +x install.sh && ./install.sh lnmp
	fi
	cd /home/wwwroot/
	cp -r default/phpmyadmin/ .
	cd default
	rm -rf index.html
	git clone https://github.com/kentcc88/mymode_02.git tmp && mv tmp/.git . && rm -rf tmp && git reset --hard
	cp config/.config.php.example config/.config.php
	chattr -i .user.ini
	mv .user.ini public
	chown -R root:root *
	chmod -R 777 *
	chown -R www:www storage
	chattr +i public/.user.ini
	wget -N -P  /usr/local/nginx/conf/ --no-check-certificate https://raw.githubusercontent.com/kentcc88/usefulinfo_02/master/nginx.conf
	service nginx restart
	IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	sed -i "s#103.74.192.11#${IPAddress}#" /home/wwwroot/default/sql/sspanel.sql
	mysql -uroot -proot -e"create database sspanel;" 
	mysql -uroot -proot -e"use sspanel;" 
	mysql -uroot -proot sspanel < /home/wwwroot/default/sql/sspanel.sql
	cd /home/wwwroot/default
	php -n xcat initdownload
	php xcat initQQWry
	yum -y install vixie-cron crontabs
	rm -rf /var/spool/cron/root
	echo 'SHELL=/bin/bash' >> /var/spool/cron/root
	echo 'PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> /var/spool/cron/root
	echo '*/20 * * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1' >> /var/spool/cron/root
	echo '30 22 * * * php /home/wwwroot/default/xcat sendDiaryMail' >> /var/spool/cron/root
	echo '0 0 * * * php /home/wwwroot/default/xcat dailyjob' >> /var/spool/cron/root
	echo '*/1 * * * * php /home/wwwroot/default/xcat checkjob' >> /var/spool/cron/root
	/sbin/service crond restart
}
#自动选择下载节点
GIT='raw.githubusercontent.com'
LIB='download.libsodium.org'
GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
LIB_PING=`ping -c 1 -w 1 $LIB|grep time=|awk '{print $7}'|sed "s/time=//"`
echo "$GIT_PING $GIT" > ping.pl
echo "$LIB_PING $LIB" >> ping.pl
libAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
if [ "$libAddr" == "$GIT" ];then
	libAddr='https://raw.githubusercontent.com/kentcc88/usefulinfo_02/master/libsodium-1.0.13.tar.gz'
else
	libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz'
fi
rm -f ping.pl	
install_centos_ssr(){
	cd /root
	yum -y update
	yum -y install git gcc
	yum -y install python-setuptools 
	curl https://raw.githubusercontent.com/kentcc88/usefulinfo_02/master/get-pip.py -o get-pip.py
	python get-pip.py
	rm -rf python get-pip.py
	yum -y groupinstall "Development Tools" 
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	mkdir python && cd python
	wget --no-check-certificate https://raw.githubusercontent.com/kentcc88/usefulinfo_02/master/python.zip
	unzip python.zip
	pip install *.whl
	pip install *.tar.gz
	#clone shadowsocks
	cd /root
	rm -rf python
	git clone -b manyuser https://github.com/kentcc88/sinstall.git "/root/shadowsocks"
	#install devel
	cd /root/shadowsocks
	yum -y install lsof lrzsz
	yum -y install python-devel
	yum -y install libffi-devel
	yum -y install openssl-devel
	yum -y install iptables
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	cp apiconfig.py userapiconfig.py
	cp config.json user-config.json
}
install_ubuntu_ssr(){
	apt-get update -y
	apt-get install supervisor lsof -y
	apt-get install build-essential wget -y
	apt-get install iptables git -y
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	apt-get install python-pip git -y
	pip install cymysql
	cd /root
	git clone -b manyuser https://github.com/kentcc88/sinstall.git "/root/shadowsocks"
	cd shadowsocks
	pip install -r requirements.txt
	chmod +x *.sh
	# 配置程序
	cp apiconfig.py userapiconfig.py
	cp config.json user-config.json
}
install_node(){
	clear
	echo
	echo "#############################################################"
	echo "# One click Install Shadowsocks-Python-Manyuser             #"
	echo "# Github: https://github.com/kentcc88/usefulinfo_02         #"
	echo "# Author: 91vps                                             #"
	echo "#############################################################"
	echo
	#Check Root
	[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
	#check OS version
	check_sys(){
		if [[ -f /etc/redhat-release ]]; then
			release="centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			release="debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			release="debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
	    fi
		bit=`uname -m`
	}
	install_ssr_for_each(){
		check_sys
		if [[ ${release} = "centos" ]]; then
			install_centos_ssr
		else
			install_ubuntu_ssr
		fi
	}
	# 取消文件数量限制
	sed -i '$a * hard nofile 512000\n* soft nofile 512000' /etc/security/limits.conf
	read -p "Please input your domain(like:https://ss.feiyang.li or http://114.114.114.114): " Userdomain
	read -p "Please input your muKey(like:mupass): " Usermukey
	read -p "Please input your Node_ID(like:1): " UserNODE_ID
	install_ssr_for_each
	IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	cd /root/shadowsocks
	echo -e "modify Config.py...\n"
	sed -i "s#'zhaoj.in'#'bing.com'#" /root/shadowsocks/userapiconfig.py
	Userdomain=${Userdomain:-"http://${IPAddress}"}
	sed -i "s#https://zhaoj.in#${Userdomain}#" /root/shadowsocks/userapiconfig.py
	Usermukey=${Usermukey:-"mupass"}
	sed -i "s#glzjin#${Usermukey}#" /root/shadowsocks/userapiconfig.py
	UserNODE_ID=${UserNODE_ID:-"3"}
	sed -i '2d' /root/shadowsocks/userapiconfig.py
	sed -i "2a\NODE_ID = ${UserNODE_ID}" /root/shadowsocks/userapiconfig.py
	# 启用supervisord
	echo_supervisord_conf > /etc/supervisord.conf
    	sed -i '$a [program:ssr]\ncommand = python /root/shadowsocks/server.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
	supervisord
	#iptables
	iptables -F
	iptables -X  
	iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
	iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
	iptables-save >/etc/sysconfig/iptables
	iptables-save >/etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
	echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
	chmod +x /etc/rc.d/rc.local
	echo "#############################################################"
	echo "# 安装完成，节点即将重启使配置生效                          #"
	echo "# Github: https://github.com/kentcc88/usefulinfo_02         #"
	echo "# Author: 91vps                                             #"
	echo "#############################################################"
	reboot now
}
install_panel_and_node(){
	install_ss_panel_mod_v3 $1
	# 取消文件数量限制
	sed -i '$a * hard nofile 512000\n* soft nofile 512000' /etc/security/limits.conf
	install_centos_ssr
	wget -N -P  /root/shadowsocks/ --no-check-certificate  https://raw.githubusercontent.com/kentcc88/usefulinfo_02/master/userapiconfig.py
	# 启用supervisord
	echo_supervisord_conf > /etc/supervisord.conf
  	sed -i '$a [program:ssr]\ncommand = python /root/shadowsocks/server.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
	supervisord
	#iptables
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	yum install iptables -y
	iptables -F
	iptables -X  
	iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
	iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
	iptables-save >/etc/sysconfig/iptables
	iptables-save >/etc/sysconfig/iptables
	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
	echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
	chmod +x /etc/rc.d/rc.local
	echo "##############################################################"
	echo "# 安装完成，登录http://${IPAddress}看看吧~                   #"
	echo "# 用户名: 91vps 密码: 91vps                                  #"
	echo "# phpmyadmin：http://${IPAddress}:888  用户名密码均为：root  #"
	echo "# 安装完成，节点即将重启使配置生效                           #"
	echo "# Github: https://github.com/kentcc88/usefulinfo_02          #"
	echo "##############################################################"
	reboot now
}
echo
echo "#############################################################"
echo "# One click Install SS-panel and Shadowsocks-Py-Mu          #"
echo "# Github: https://github.com/kentcc88/usefulinfo_02         #"
echo "# Author: 91vps                                             #"
echo "# Please choose the server you want                         #"
echo "# 1  SS-V3_mod_panel and node One click Install             #"
echo "# 2  SS-node One click Install                              #"
echo "#############################################################"
echo
num=$1
if [ "${num}" == "1" ]; then
    install_panel_and_node 1
else
    stty erase '^H' && read -p " 请输入数字 [1-2]:" num
		case "$num" in
		1)
		install_panel_and_node
		;;
		2)
		install_node
		;;
		*)
		echo "请输入正确数字 [1-2]"
		;;
	esac
fi

