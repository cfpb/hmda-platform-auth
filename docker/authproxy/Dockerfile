FROM debian:jessie

ENV VERSION 2.0.0 
ENV PATCHLEVEL 1
ENV PKG libapache2-mod-auth-openidc_${VERSION}-${PATCHLEVEL}_amd64.deb
ENV DL_SITE https://github.com/pingidentity/mod_auth_openidc/releases/download/

# Starting with mod_auth_openidc Cisco's cjose lib is required
ENV CJOSE_PKG libcjose_0.4.1-1_amd64.deb

RUN apt-get update && \
    apt-get install -y apache2 curl libhiredis0.10 libjansson4 vim && \
    curl -s -L -o /tmp/${CJOSE_PKG} ${DL_SITE}/v${VERSION}/${CJOSE_PKG} && \
    dpkg -i /tmp/${CJOSE_PKG} && \
    curl -s -L -o /tmp/${PKG} ${DL_SITE}/v${VERSION}/${PKG} && \
    dpkg -i /tmp/${PKG} && \
    apt-get install -yf && \
    a2enmod auth_openidc headers proxy proxy_http rewrite ssl

ADD ports.conf /etc/apache2/
ADD 000-default.conf /etc/apache2/sites-available/

CMD apache2ctl -D FOREGROUND
