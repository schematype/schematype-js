FROM node

COPY npm /npm

RUN apt-get update && \
    apt-get install -y less man-db && \
    cd /npm && \
    npm install -g .

WORKDIR /data

ENTRYPOINT ["stp"]
