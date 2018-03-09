FROM apolloauto/apollo:dev-x86_64-20180130_1338

COPY ./snowboy /usr/local/apollo/snowboy

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update -y && \
    apt-get install -y --only-upgrade libstdc++
