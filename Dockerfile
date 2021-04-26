ARG CALIBRE_VERSION=5.16.1

FROM ubuntu:20.04

ARG CALIBRE_VERSION
LABEL maintainer="me@ethandjeric.com"
LABEL version="1.2-git"
LABEL calibre_version="$CALIBRE_VERSION"
LABEL metadata.db_version="$CALIBRE_VERSION"

ENV IMPORT_TIME=10m UMASK_SET=022 DELETE_IMPORTED=false LIBRARY_UID=1000 LIBRARY_GID=1000 VERBOSE=false

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    # install kcc and deps
        $(apt-cache depends calibre | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ')  \
        python3 \
        python3-wheel \
        python3-dev \
        python3-pip \
        python3-setuptools \
        libpng-dev \
        libjpeg-dev \
        p7zip-full \
        wget && \
    pip3 install \
        pillow \
        python-slugify==2.0.1 \
        psutil \ 
        KindleComicConverter-headless && \
    # multi arch for i386 kindlegen binary support
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install libc6-i386 && \
    # clean up
    apt-get clean && \
    rm -rf \
        /tmp/* \
	    /var/lib/apt/lists/* \
        /var/cache/apt/* \
	    /var/tmp/*

COPY image_root/ /

USER root

RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin version=$CALIBRE_VERSION
RUN calibre-customize --add-plugin /calibre/plugins/DeDRM_7.2.1.zip

ENTRYPOINT ["/entrypoint.sh"]
