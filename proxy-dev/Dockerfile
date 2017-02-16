FROM centos:7 

RUN yum update -y && \
    yum install -y httpd mod_ssl && \
    rm -rf /etc/httpd/conf/* /etc/httpd/conf.d/* /etc/httpd/conf.modules.d/* /usr/share/httpd/error/* /var/www/html/* 

ADD conf/ /

EXPOSE 2000 # hmda-platform-ui
EXPOSE 3000 # keycloak
EXPOSE 4000 # hmda-platform public api
EXPOSE 5000 # auth-proxy 

CMD httpd -D FOREGROUND
