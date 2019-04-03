FROM alpine:3.8

ENV ALPINE_VERSION=3.8

#### packages from https://pkgs.alpinelinux.org/packages
# These are always installed. Notes:
#   * dumb-init: a proper init system for containers, to reap zombie children
#   * bash: For entrypoint, and debugging
#   * ca-certificates: for SSL verification during Pip and easy_install
#   * python: the binaries themselves
#   * openblas: required for numpy.
#   * libstdc++: for pandas
#   * libjpeg: for pyecharts
#   * libnsl: for cx_Oracle's libclntsh.so
#   * libaio: for cx_Oracle
#   * expat: for python install pip
#   * mysql-dev: for install mysqlclient
ENV PACKAGES="\
  dumb-init \
  bash vim tini \
  python3 \
  openblas \
  libstdc++ \
#  libjpeg \
  libnsl \
  libaio \
#  expat==2.2.5-r0 \
#  libcrypto1.1==1.1.1-r4 \
  mysql-dev \
"

# These packages are not installed immediately, but are added at runtime or ONBUILD to shrink the image as much as possible. Notes:
#   * build-base: used so we include the basic development packages (gcc)
#   * linux-headers: commonly needed, and an unusual package name from Alpine.
#   * python-dev: are used for gevent e.g.
#   * zlib-dev*: for install pyecharts
#   * openblas-dev: for install scipy
#   * libpng-dev*: for install fbprophet
ENV BUILD_PACKAGES="\
  build-base \
  linux-headers \
  python3-dev \
#  zlib-dev jpeg-dev \
  openblas-dev \
  libpng-dev freetype-dev \
"

## for install oracle instant client
## https://oracle.github.io/odpi/doc/installation.html#linux
ENV TNS_ADMIN=/oracle_client/instantclient_11_2
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_11_2

RUN echo "Begin" \
  && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
  && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
  && apk add --no-cache $PACKAGES || \
    (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && apk add --no-cache $PACKAGES) \
  && sed -i -e 's:mouse=a:mouse-=a:g' /usr/share/vim/vim81/defaults.vim \
  && python3 -m pip install --upgrade --no-cache-dir pip \
  && cd /usr/bin \
  && ls -l python* pip* \
  && { [[ -e python ]] || ln -sf python3.6 python; } \
  && ls -l python* pip* \
  && pip install --no-cache-dir wheel \
  && pip install numpy==1.16.2 \
  && pip install Cython==0.29.6 \
  && mkdir /whl && cd /whl \
  && wget -O pystan-2.18.1.0-cp36-cp36m-manylinux1_x86_64.whl "https://files.pythonhosted.org/packages/17/77/dd86797a7e7fccca117233c6d50cc171e0c2b2f5a0cd2a8d9753ee09b7be/pystan-2.18.1.0-cp36-cp36m-manylinux1_x86_64.whl" \
  && pip wheel fbprophet \
  && echo "End"

## RUN echo "Begin" \
##   && wget -O Dockerfile "https://raw.githubusercontent.com/tianxiawuzhe/alpine37-py365-django21-ai/master/Dockerfile" \
##   
##   # install oracle client and create soft link
## #  && mkdir /oracle_client && cd /oracle_client \
## #  && wget -O client.zip "https://raw.githubusercontent.com/tianxiawuzhe/alpine37-py365-django21-ai/master/instantclient-basic-linux.x64-11.2.0.4.0.zip" \
## #  && unzip client.zip && rm client.zip \
## #  && cd /oracle_client/instantclient_11_2 \
## #  && ln -s libclntsh.so.11.1  libclntsh.so \
##   && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
## 
##   # replacing default repositories with edge ones
## #  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
## #  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
## #  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
## 
##   # Add the build packages, and then will be deleted
##   && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
## 
##   # Add the packages, with a CDN-breakage fallback if needed
##   && apk add --no-cache $PACKAGES || \
##     (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && apk add --no-cache $PACKAGES) \
##   && sed -i -e 's:mouse=a:mouse-=a:g' /usr/share/vim/vim81/defaults.vim \
##   
##   # turn back the clock -- so hacky!
## #  && echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/main/" > /etc/apk/repositories \
##   
##   # make some useful symlinks that are expected to exist
##   && python3 -m pip install --upgrade --no-cache-dir pip \
##   && cd /usr/bin \
##   && ls -l python* pip* \
## #  && { [[ -e idle ]] || ln -s idle3 idle; } \
## #  && { [[ -e pydoc ]] || ln -s pydoc3 pydoc; } \
##   && { [[ -e python ]] || ln -sf python3.6 python; } \
## #  && { [[ -e python-config ]] || ln -sf python3-config python-config; } \
## #  && { [[ -e pip ]] || ln -sf pip3 pip; } \
##   && ls -l python* pip* \
## #  && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
## #  && python get-pip.py \
## #  && rm get-pip.py \
##   
##   # install my app software
##   #&& pip install --no-cache-dir supervisor \
## #  && pip install --no-cache-dir Django==2.1 \
## #  && pip install --no-cache-dir influxdb==5.2.1 \
## #  && pip install --no-cache-dir pandas==0.23.4 \
## #  && pip install --no-cache-dir scipy==1.1.0 \
## #  && pip install --no-cache-dir cx_Oracle==7.0.0 \
## #  && pip install --no-cache-dir xlrd==1.1.0 \
## #  && pip install --no-cache-dir uwsgi==2.0.17.1 \
## #  && pip install --no-cache-dir uwsgitop==0.10 \
## #  && pip install --no-cache-dir mysqlclient==1.3.14 \
## #  && pip install --no-cache-dir redis==3.2.0 \
## #  && pip install --no-cache-dir celery==4.2.1 \
## #  && pip install --no-cache-dir kafka-python==1.4.4 \
## #  && pip install --no-cache-dir hdfs==2.2.2 \
## #  && pip install --no-cache-dir django-celery-results \
## #  && pip install --no-cache-dir django-celery-beat \
## #  && pip install --no-cache-dir eventlet \
## #  && pip install --no-cache-dir sklearn \
## #  && pip install --no-cache-dir fbprophet \
##   && pip install --no-cache-dir wheel \
##   && mkdir /whl && cd /whl && pip wheel sklearn \
## 
##   # End
## #  && apk del .build-deps \
##   && ls -l python* pip* \
##   && echo "End"
  
# Copy in the entrypoint script -- this installs prerequisites on container start.
#COPY entrypoint.sh /entrypoint.sh

# This script installs APK and Pip prerequisites on container start, or ONBUILD. Notes:
#   * Reads the -a flags and /apk-requirements.txt for install requests
#   * Reads the -b flags and /build-requirements.txt for build packages -- removed when build is complete
#   * Reads the -p flags and /requirements.txt for Pip packages
#   * Reads the -r flag to specify a different file path for /requirements.txt
#ENTRYPOINT ["/usr/bin/dumb-init", "bash", "/entrypoint.sh"]

EXPOSE 8080-8089

ENTRYPOINT tail -f /dev/null
CMD ["/bin/bash"]
