FROM centos:7 

RUN yum update -y && \
    yum install -y httpd mod_ssl && \
    rm -rf /etc/httpd/conf/* /etc/httpd/conf.d/* /etc/httpd/conf.modules.d/* /usr/share/httpd/error/* /var/www/html/* 

ADD conf/ /

# hmda-platform-ui
EXPOSE 2000

# keycloak
EXPOSE 3000

# hmda-platform public api
EXPOSE 4000

# auth-proxy
EXPOSE 5000

CMD httpd -D FOREGROUND
