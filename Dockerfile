FROM node

COPY npm /npm

WORKDIR /data

ENV PATH /npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENTRYPOINT ["stp"]
