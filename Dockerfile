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
  freetype==2.9.1-r1 \
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
  gcc musl-dev g++ \
"

## for install oracle instant client
## https://oracle.github.io/odpi/doc/installation.html#linux
ENV TNS_ADMIN=/oracle_client/instantclient_11_2
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_11_2

## RUN apk add --no-cache python3 python3-dev \
##   && python3 -m pip install --upgrade --no-cache-dir pip \
##   && { [[ -e python ]] || ln -sf python3.6 python; } \
##   && echo "1 "$(date +"%Y%m%d %H:%M:%S") \
##   && apk --update add --no-cache gcc freetype-dev libpng-dev \
##   && echo "2 "$(date +"%Y%m%d %H:%M:%S") \
##   && apk add --no-cache --virtual .build-deps musl-dev g++ \
##   && echo "3 "$(date +"%Y%m%d %H:%M:%S") \
##   && pip install --no-cache-dir fbprophet==0.4.post2 \
##   && echo "4 "$(date +"%Y%m%d %H:%M:%S") \
##   && echo "END"
    
## RUN echo "Begin" \
##   && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
##   && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
##   && apk add --no-cache $PACKAGES || \
##     (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && apk add --no-cache $PACKAGES) \
##   && sed -i -e 's:mouse=a:mouse-=a:g' /usr/share/vim/vim81/defaults.vim \
##   && python3 -m pip install --upgrade --no-cache-dir pip \
##   && cd /usr/bin \
##   && ls -l python* pip* \
##   && { [[ -e python ]] || ln -sf python3.6 python; } \
##   && ls -l python* pip* \
##   && pip install --no-cache-dir wheel \
##   && pip install numpy==1.16.2 \
##   && pip install Cython==0.29.6 \
##   && mkdir /whl && cd /whl \
##   && pip wheel numpy==1.16.2 \
##   && pip wheel Cython==0.29.6 \
##   && wget -O pystan-2.18.1.0.tar.gz "https://files.pythonhosted.org/packages/96/21/6452aadcbb5807fb8858e8789c74d62f5ebaece0351ff231f44064c44b33/pystan-2.18.1.0.tar.gz" \
##   && echo "End"

# ENV GITHUB_URL=https://raw.githubusercontent.com/tianxiawuzhe/alpine37-py365-django21-ai/master

RUN echo "Begin" \
  && GITHUB_URL='https://raw.githubusercontent.com/tianxiawuzhe/alpine37-py365-django21-ai/master' \
  && wget -O Dockerfile "${GITHUB_URL}/Dockerfile" \
  \
  && mkdir /oracle_client && cd /oracle_client \
  && wget -O client.zip "${GITHUB_URL}/instantclient-basic-linux.x64-11.2.0.4.0.zip" \
  && unzip client.zip && rm client.zip \
  && cd /oracle_client/instantclient_11_2 \
  && ln -s libclntsh.so.11.1  libclntsh.so \
  && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
  && mkdir /whl && cd /whl \
  \
  && numpy=numpy-1.16.2-cp36-cp36m-linux_x86_64.whl \
  && wget -O ${numpy} "${GITHUB_URL}/whl/${numpy}" \
  \
  && scipy=scipy-1.1.0-cp36-cp36m-linux_x86_64.whl \
  && wget -O ${scipy} "${GITHUB_URL}/whl/${scipy}" \
  \
  && scikit_learn=scikit_learn-0.20.3-cp36-cp36m-linux_x86_64.whl \
  && wget -O ${scikit_learn} "${GITHUB_URL}/whl/${scikit_learn}" \
  \
  && Cython=Cython-0.29.6-cp36-cp36m-linux_x86_64.whl \
  && wget -O ${Cython} "${GITHUB_URL}/whl/${Cython}" \
  \
  && pystan=pystan-2.18.1.0-cp36-cp36m-linux_x86_64.whl \
  && wget -O ${pystan} "${GITHUB_URL}/whl/${pystan}" \
  \
  && ls -lrt /whl \
  \
  && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
  \
  && apk add --no-cache $PACKAGES || \
    (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && apk add --no-cache $PACKAGES) \
  && sed -i -e 's:mouse=a:mouse-=a:g' /usr/share/vim/vim81/defaults.vim \
  \
  && python3 -m pip install --upgrade --no-cache-dir pip \
  && cd /usr/bin \
  && ls -l python* pip* \
  && { [[ -e python ]] || ln -sf python3.6 python; } \
  && ls -l python* pip* \
  \
  && pip install --no-cache-dir Django==2.1 \
  && pip install --no-cache-dir influxdb==5.2.1 \
  && pip install --no-cache-dir /whl/${numpy} \
  && pip install --no-cache-dir pandas==0.23.4 \
  && pip install --no-cache-dir /whl/${scipy} \
  && pip install --no-cache-dir cx_Oracle==7.0.0 \
  && pip install --no-cache-dir xlrd==1.1.0 \
  && pip install --no-cache-dir uwsgi==2.0.17.1 \
  && pip install --no-cache-dir uwsgitop==0.10 \
  && pip install --no-cache-dir mysqlclient==1.3.14 \
  && pip install --no-cache-dir redis==3.2.0 \
  && pip install --no-cache-dir celery==4.2.1 \
  && pip install --no-cache-dir kafka-python==1.4.4 \
  && pip install --no-cache-dir hdfs==2.2.2 \
  && pip install --no-cache-dir django-celery-results \
  && pip install --no-cache-dir django-celery-beat \
  && pip install --no-cache-dir eventlet \
  && pip install --no-cache-dir /whl/${scikit_learn} \
  && pip install --no-cache-dir sklearn \
  && pip install --no-cache-dir /whl/${Cython} \
  && pip install --no-cache-dir /whl/${pystan} \
  && pip install --no-cache-dir fbprophet \
  && pip install --no-cache-dir suds-jurko==0.6 \
  \
  && apk del .build-deps \
  && ls -l python* pip* \
  && echo "End"
  
#&& pip install --no-cache-dir supervisor \
#  && pip install --no-cache-dir fbprophet \
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
