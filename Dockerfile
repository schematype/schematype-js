FROM node

COPY ./stp /stp

RUN \
    cd /stp && \
    npm install && \
    npm install -g coffee-script
