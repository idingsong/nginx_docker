# DOCKER-VERSION 1.0.0

FROM    centos:centos6

MAINTAINER szmoto, szmoto@vip.qq.com

 
#RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm 

# Install supervisor
#RUN yum install -y python-meld3
# Install Nginx repo
RUN yum install -y http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

VOLUME ["/var/www/"]

# Create folder for server and add index.php file to for nginx
RUN mkdir -p /var/www/html && chmod a+r /var/www/html


#ADD ThinkPHP && SSHD
RUN mkdir -p /var/www/{ThinkPHP,Apps,html/Public} && mkdir -p /root/.ssh && mkdir -p /var/run/sshd

#install nginx, php, mysql, php-fpm
RUN ["yum", "-y", "install", "nginx", "php","php-fpm", "php-mysql", "php-devel", "php-gd", "php-pecl-memcache", "php-pspell", "php-snmp", "php-xmlrpc", "php-xml","openssh-server"]


#Add index.php
ADD index.php /var/www/html/index.php

COPY MyThinkPHP/ThinkPHP /var/www/ThinkPHP

RUN chown -R nginx:nginx /var/www/{ThinkPHP,Apps,html/Public}

# ADD Php-fpm config
ADD www.conf /etc/php-fpm.d/www.conf

# ADD Nginx config
ADD nginx.conf /etc/nginx/conf.d/default.conf

#  ADD ssh Key
ADD authorized_keys /root/.ssh/authorized_keys

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ed25519_key

RUN yum install -y python-setuptools && yum clean all

RUN easy_install supervisor

# ADD supervisord config with hhvm setup
ADD supervisord.conf /etc/supervisord.conf
RUN mkdir /var/log/supervisor && touch /var/log/supervisor/supervisord.log

#set to start automatically - supervisord, nginx and mysql
#RUN chkconfig nginx on
#RUN chkconfig supervisord on



ADD scripts/run.sh /run.sh

RUN chmod a+x /run.sh 


EXPOSE 22 80
#Start supervisord (which will start hhvm), nginx, mysql 
ENTRYPOINT ["/run.sh"]
