FROM debian:jessie

ENV OIDC_VER 2.1.2 
ENV OIDC_PATCH 1
ENV OIDC_PKG libapache2-mod-auth-openidc_${OIDC_VER}-${OIDC_PATCH}_amd64.deb

# Cisco's cjose lib is available on mod_auth_openidc download site, but older version.
ENV CJOSE_OIDC_VER 2.1.0
ENV CJOSE_PKG libcjose_0.4.1-1_amd64.deb

ENV DL_SITE https://github.com/pingidentity/mod_auth_openidc/releases/download/


RUN apt-get update && \
    apt-get install -y apache2 curl libhiredis0.10 libjansson4 vim && \
    curl -vfL -o /tmp/${CJOSE_PKG} ${DL_SITE}/v${CJOSE_OIDC_VER}/${CJOSE_PKG} && \
    dpkg -i /tmp/${CJOSE_PKG} && \
    curl -vfL -o /tmp/${OIDC_PKG} ${DL_SITE}/v${OIDC_VER}/${OIDC_PKG} && \
    dpkg -i /tmp/${OIDC_PKG} && \
    apt-get install -yf && \
    a2enmod auth_openidc log_debug headers proxy proxy_http rewrite ssl

ADD ports.conf /etc/apache2/
ADD 000-default.conf /etc/apache2/sites-available/

CMD apache2ctl -D FOREGROUND
