FROM alpine:3.12

ENV ALPINE_VERSION=3.12

#### packages from https://pkgs.alpinelinux.org/packages
# These are always installed. Notes:
#   * dumb-init: a proper init system for containers, to reap zombie children
#   * bash: For entrypoint, and debugging
#   * tzdata: For timezone
#   * python3: the binaries themselves
#   * libnsl: for cx_Oracle's libclntsh.so
#   * libaio: for cx_Oracle
#   * mysql-dev: for using mysqlclient/MySQLdb
ENV PACKAGES="\
  dumb-init tzdata bash vim tini ncftp busybox-extras \
  python3 \
  libnsl \
  libaio \
  mysql-dev \
"

# These packages are not installed immediately, but are added at runtime or ONBUILD to shrink the image as much as possible. Notes:
#   * build-base: used so we include the basic development packages (gcc)
#   * linux-headers: commonly needed, and an unusual package name from Alpine.
#   * python3-dev: are used for gevent e.g.
ENV BUILD_PACKAGES="\
  build-base \
  linux-headers \
  gcc musl-dev g++ \
  python3-dev \
"

## for install oracle instant client
## https://oracle.github.io/odpi/doc/installation.html#linux
ENV TNS_ADMIN=/oracle_client/instantclient_11_2
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_11_2

## running
RUN echo "Begin" && ls -lrt \
  && GITHUB_URL='https://github.com/tianxiawuzhe/dbapi_alpine312_py385_django312/raw/master' \
  && wget -O Dockerfile "${GITHUB_URL}/Dockerfile" \
  && wget -O /entrypoint.sh "${GITHUB_URL}/entrypoint.sh" \
  && echo "********** 安装oracle驱动" \
  && mkdir /oracle_client && cd /oracle_client \
  && wget -O client.zip "${GITHUB_URL}/instantclient-basic-linux.x64-11.2.0.4.0.zip" \
  && unzip client.zip && rm client.zip \
  && cd /oracle_client/instantclient_11_2 \
  && ln -s libclntsh.so.11.1  libclntsh.so \
  && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 \
  && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && echo "********** 安装临时依赖" \
  && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
  && echo "********** 安装永久依赖" \
  && apk add --no-cache $PACKAGES \
  && echo "********** 更新python信息" \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && sed -i 's:mouse=a:mouse-=a:g' /usr/share/vim/vim82/defaults.vim \
  && { [[ -e /usr/bin/python ]] || ln -sf /usr/bin/python3.8 /usr/bin/python; } \
  && python -m ensurepip \
  && python -m pip install --upgrade --no-cache-dir pip \
  && cd /usr/bin \
  && ls -l python* pip* \
  && echo "********** 安装python包" \
  && pip install --no-cache-dir wheel \
  && pip install --no-cache-dir Django==3.1.2 \
  && pip install --no-cache-dir uwsgi==2.0.19.1 \
  && pip install --no-cache-dir uwsgitop==0.11 \
  && pip install --no-cache-dir mysqlclient==2.0.1 \
  && pip install --no-cache-dir influxdb==5.3.0 \
  && pip install --no-cache-dir mongo==0.2.0 \
  && pip install --no-cache-dir cx_Oracle==8.0.1 \
  && pip install --no-cache-dir redis3==3.5.2.2 \
  && pip install --no-cache-dir kafka-python==2.0.2 \
  && pip install --no-cache-dir elasticsearch7==7.9.1 \
#  && pip install --no-cache-dir hdfs==2.2.2 \
  && echo "********** 删除依赖包" \
  && apk del .build-deps \
  && ls -l python* pip* \
  && echo "End"

EXPOSE 8080-8089
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
