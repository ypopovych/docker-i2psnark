FROM alpine:latest
LABEL maintainer "Yehor Popovych <popovych.yegor@gmail.com>"

# allowed hostnames for web ui
ARG HOSTNAMES=""
ENV HOSTNAMES=${HOSTNAMES}

# GID on the HOST from which i2psnark will work
ARG HOST_GID=1000
ENV HOST_GID=${HOST_GID}

# UID on the HOST from which i2psnark will work
ARG HOST_UID=1000
ENV HOST_UID=${HOST_UID}

# I2CP hostname
ARG I2CP_HOST=""
ENV I2CP_HOST=${I2CP_HOST}

# I2CP port
ARG I2CP_PORT=7654
ENV I2CP_PORT=${I2CP_PORT}

RUN addgroup -g ${HOST_GID} i2psnark \
    && adduser -h /snark -G i2psnark -u ${HOST_UID} -D i2psnark

RUN apk --no-cache add openjdk17-jre su-exec shadow

ADD https://gitlab.com/i2pplus/I2P.Plus/-/jobs/artifacts/master/raw/i2psnark-standalone.zip?job=Java8 /tmp/i2psnark-standalone.zip

RUN unzip -d /snark /tmp/i2psnark-standalone.zip \
    && sed -i 's/<Set name="host">127.0.0.1<\/Set>/<Set name="host">0.0.0.0<\/Set>/' /snark/i2psnark/jetty-i2psnark.xml \
    && echo "i2psnark.dir=/snark/downloads" > /snark/i2psnark.config.default \
    && echo "i2psnark.i2cpHost=${I2CP_HOST}" >> /snark/i2psnark.config.default \
    && echo "i2psnark.i2cpPort=${I2CP_PORT}" >> /snark/i2psnark.config.default \
    && echo "i2psnark.allowedHosts=${HOSTNAMES}" >> /snark/i2psnark/i2psnark-appctx.config \
    && chown -R i2psnark:i2psnark /snark \
    && cd /snark/i2psnark && ln -s ../config i2psnark.config.d \
    && rm -rf /tmp/i2psnark-standalone.zip 


VOLUME /snark/config
VOLUME /snark/downloads

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8002

ENTRYPOINT [ "/entrypoint.sh" ]
