FROM alpine:latest AS builder

# GIT TAG FOR BUILD
ARG GIT_TAG=""
ENV GIT_TAG=${GIT_TAG}

RUN apk --no-cache add git gettext apache-ant openjdk8 curl jq zip

RUN git clone https://github.com/i2p/i2p.i2p.git /src 

RUN cd /src \
    && if [ -z "${GIT_TAG}" ]; then export GIT_TAG=$(curl https://api.github.com/repos/i2p/i2p.i2p/releases | jq -r '.[0].tag_name') ; fi \
    && if [ -n "${GIT_TAG}" ]; then git checkout tags/${GIT_TAG}; fi \
    && ant i2psnark \
    && mkdir -p /snark/config \
    && unzip -d /snark /src/apps/i2psnark/java/i2psnark-standalone.zip

FROM alpine:latest
LABEL maintainer="Yehor Popovych <popovych.yegor@gmail.com>"

# GIT TAG FOR BUILD
ARG GIT_TAG=""
ENV GIT_TAG=${GIT_TAG}

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

COPY --from=builder --chown=${HOST_GID}:${HOST_UID} /snark /snark

RUN sed -i 's/<Set name="host">127.0.0.1<\/Set>/<Set name="host">0.0.0.0<\/Set>/' /snark/i2psnark/jetty-i2psnark.xml \
    && echo "i2psnark.dir=/snark/downloads" > /snark/i2psnark.config.default \
    && echo "i2psnark.i2cpHost=${I2CP_HOST}" >> /snark/i2psnark.config.default \
    && echo "i2psnark.i2cpPort=${I2CP_PORT}" >> /snark/i2psnark.config.default \
    && echo "i2psnark.allowedHosts=${HOSTNAMES}" >> /snark/i2psnark/i2psnark-appctx.config \
    && chown -R i2psnark:i2psnark /snark \
    && cd /snark/i2psnark && ln -s ../config i2psnark.config.d \
    && rm -rf /src \
    && apk --no-cache add openjdk8-jre-base su-exec shadow

VOLUME /snark/config
VOLUME /snark/downloads

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8002

ENTRYPOINT [ "/entrypoint.sh" ]