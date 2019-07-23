FROM debian:10

RUN apt-get update && apt-get -y install taskwarrior uuid-dev gnutls-bin libgnutls28-dev cmake g++ curl net-tools
RUN curl -o /taskd.tar.gz https://taskwarrior.org/download/taskd-1.1.0.tar.gz \
    && tar -xzf /taskd.tar.gz \
    && cd /taskd-1.1.0/ \
    && cmake -DCMAKE_BUILD_TYPE=release . \
    && make \
    && make install \
    && cp -R pki /pki \
    && rm -Rf /taskd-1.1.0/
    

RUN useradd taskd --uid 1000

ENV TASKDDATA=/data
RUN mkdir -p $TASKDDATA && chown -R taskd /data /pki
COPY init.sh /init.sh

USER taskd
VOLUME /data

ENTRYPOINT /init.sh