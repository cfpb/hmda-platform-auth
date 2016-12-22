FROM debian:jessie

ENV OIDC_VER 2.1.3 
ENV OIDC_PATCH 1
ENV OIDC_PKG libapache2-mod-auth-openidc_${OIDC_VER}-${OIDC_PATCH}_amd64.deb

# Cisco's cjose lib is _usually_ on the same release as mod_auth_openidc
ENV CJOSE_OIDC_VER 2.1.3
ENV CJOSE_PKG libcjose_0.4.1-1_amd64.deb

ENV DL_SITE https://github.com/pingidentity/mod_auth_openidc/releases/download/

RUN apt-get update && \
    apt-get install -y apache2 curl libhiredis0.10 libjansson4 vim && \
    curl -sL -o /tmp/${CJOSE_PKG} ${DL_SITE}/v${CJOSE_OIDC_VER}/${CJOSE_PKG} && \
    dpkg -i /tmp/${CJOSE_PKG} && \
    curl -sL -o /tmp/${OIDC_PKG} ${DL_SITE}/v${OIDC_VER}/${OIDC_PKG} && \
    dpkg -i /tmp/${OIDC_PKG} && \
    apt-get install -yf && \
    a2disconf charset localized-error-pages other-vhosts-access-log serve-cgi-bin && \
    a2dismod -f access_compat auth_basic authn_file authz_host autoindex deflate negotiation status && \
    a2enmod auth_openidc headers include log_debug proxy proxy_http rewrite ssl && \
    rm -rf /usr/share/apache2/error/* /var/www/html/* /var/log/apache2/* && \
    chown -R www-data /run /etc/ssl 

ADD conf/ /

RUN a2enconf error-pages 

USER www-data 

CMD apache2ctl -D FOREGROUND
