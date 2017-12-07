FROM centos:7 

ENV OIDC_VER 2.3.3
ENV OIDC_PATCH 1
ENV OIDC_PKG mod_auth_openidc-${OIDC_VER}-${OIDC_PATCH}.el7.centos.x86_64.rpm

# Cisco's cjose lib is available w/ mod_auth_openidc releases,
# but frequently doesn't get pushed up for patch releases.  There
# is generally a note in each release as to which one to use.
ENV CJOSE_OIDC_VER 2.3.0
ENV CJOSE_PKG cjose-0.5.1-1.el7.centos.x86_64.rpm

ENV DL_SITE https://github.com/pingidentity/mod_auth_openidc/releases/download/

ENV HTTPD_USER apache

RUN yum install -y epel-release && \
    yum-config-manager --enable cr && \
    yum update -y && \
    yum install -y hiredis httpd jansson && \
    curl -sL -o /tmp/${CJOSE_PKG} ${DL_SITE}/v${CJOSE_OIDC_VER}/${CJOSE_PKG} && \
    yum install -y /tmp/${CJOSE_PKG} && \
    curl -sL -o /tmp/${OIDC_PKG} ${DL_SITE}/v${OIDC_VER}/${OIDC_PKG} && \
    yum install -y /tmp/${OIDC_PKG} && \
    rm -rf /etc/httpd/conf/* /etc/httpd/conf.d/* /etc/httpd/conf.modules.d/* /usr/share/httpd/error/* /var/www/html/* 

ADD conf/ /

RUN chown -R $HTTPD_USER /run /var/www/html

USER $HTTPD_USER

EXPOSE 8080

# Updates timestamp for upSince attribute, and starts httpd
CMD touch -m /var/www/html/index.json && httpd -D FOREGROUND
