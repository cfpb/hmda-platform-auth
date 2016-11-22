#!/bin/bash

# Generate SSL key and cert
openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=DC/L=Washington/O=CFPB/CN=localhost" \
    -keyout ssl.key \
    -out ssl.crt && \
gunicorn -c conf/gunicorn.py -b 0.0.0.0:5000 app:app
