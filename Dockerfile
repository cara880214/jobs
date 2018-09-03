FROM alpine:3.7

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.6.5
ENV INSTALL_PATH /software/python

# install cron
#RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs \
#    && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
#RUN touch cron.sh && cp cron.sh /var/spool/cron/crontabs/root

#instal busybox
#RUN apk add -u --no-cache busybox && apk add --no-cache busybox-extras

RUN set -ex && touch /keep_me_running.log \
    && apk add --no-cache vim bash tini ca-certificates \
    && apk add --no-cache --virtual=.fetch-deps gnupg libressl xz dcron procps vsftpd lftp expat-dev \
#    && apk add --no-cache --virtual=.build-deps  bzip2-dev coreutils dpkg-dev dpkg expat-dev gcc gdbm-dev \
#        libc-dev libffi-dev libnsl-dev libtirpc-dev make linux-headers ncurses-dev libressl libressl-dev pax-utils \
#        readline-dev sqlite-dev tcl-dev tk tk-dev xz-dev zlib-dev g++ openblas-dev \
    && apk add --no-cache --virtual=.build-deps  bzip2-dev coreutils dpkg-dev dpkg  gdbm-dev \
        libffi-dev libnsl-dev libtirpc-dev linux-headers ncurses-dev libressl libressl-dev pax-utils \
        readline-dev sqlite-dev tcl-dev tk tk-dev xz-dev zlib-dev openblas-dev python-dev openldap-dev \
        libxml2-dev libaio libxslt-dev python3-dev py-lxml build-base \
        jpeg-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev \
    \
    && mkdir -p ${INSTALL_PATH} \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    && tar -xJC ${INSTALL_PATH} --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    \
#    && apk del .fetch-deps \
#    \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && cd ${INSTALL_PATH} && ./configure \
        --build="$gnuArch" \
        --enable-loadable-sqlite-extensions \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
#        --without-ensurepip \
    && make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" \
# set thread stack size to 1MB so we don't segfault before we hit sys.getrecursionlimit()
# https://github.com/alpinelinux/aports/commit/2026e1259422d4e0cf92391ca2d3844356c649d0
    && make install \
    \
##     && runDeps="$( \
##         scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
##             | tr ',' '\n' \
##             | sort -u \
##             | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
##     )" \
##     && apk add --virtual .python-rundeps $runDeps \
##     && apk del .build-deps \
##     \
    && find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' + \
    && rm -rf ${INSTALL_PATH} \
    && cd /usr/local/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s pip3 pip \
    && ln -s python3-config python-config \
    && python -m pip install --upgrade pip \
    && pip install Django==2.1 \
#    && pip install Cython \
    && pip install requests \
#    && pip install jieba \
#    && pip install fasttext \
#    && pip install gensim \
#    && pip install pyLDAvis \
    && pip install pyecharts \
    && pip install influxdb \
    && pip install pandas \
    && pip install scipy \
    && pip install cx_Oracle \
    && apk del .build-deps

## # make some useful symlinks that are expected to exist

## 
## # if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
## # ENV PYTHON_PIP_VERSION 10.0.1
## # RUN set -ex; \
## #     \
## #     apk add --no-cache --virtual .fetch-deps libressl; \
## #     \
## #     wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
## #     \
## #     apk del .fetch-deps; \
## #     \
## #     python get-pip.py \
## #         --disable-pip-version-check \
## #         --no-cache-dir \
## #         "pip==$PYTHON_PIP_VERSION" \
## #     ; \
## #     pip --version; \
## #     \
## #     find /usr/local -depth \
## #         \( \
## #             \( -type d -a \( -name test -o -name tests \) \) \
## #             -o \
## #             \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
## #         \) -exec rm -rf '{}' +; \
## #     rm -f get-pip.py
## 
## 
## ## clean temp packages
## RUN apk del .build-deps

EXPOSE 8080-8089

ENTRYPOINT tail -f /keep_me_running.log
CMD ["/bin/bash"]
