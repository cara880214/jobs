#FROM alpine:3.7
FROM daocloud.io/tianxiawuzhe/aiitoms:master-48cb69c

ENV ALPINE_VERSION=3.7

#### packages from https://pkgs.alpinelinux.org/packages
# These are always installed. Notes:
#   * dumb-init: a proper init system for containers, to reap zombie children
#   * bash: For entrypoint, and debugging
#   * ca-certificates: for SSL verification during Pip and easy_install
#   * python: the binaries themselves
#   * py-setuptools: required only in major version 2, installs easy_install so we can install Pip.
ENV PACKAGES="\
  dumb-init \
  bash vim tini \
  ca-certificates \
  python3==3.6.5-r0 \
"

# These packages are not installed immediately, but are added at runtime or ONBUILD to shrink the image as much as possible. Notes:
#   * build-base: used so we include the basic development packages (gcc)
#   * linux-headers: commonly needed, and an unusual package name from Alpine.
#   * python-dev: are used for gevent e.g.
#   * zlib-dev*: for install pyecharts
#   * openblas-dev: for install scipy
ENV BUILD_PACKAGES="\
  build-base \
  linux-headers \
  python3-dev==3.6.5-r0 \
  zlib-dev jpeg-dev \
  openblas-dev \
"
#  python2-dev \

## /etc/apk/repositories
# http://dl-cdn.alpinelinux.org/alpine/v3.7/main
# http://dl-cdn.alpinelinux.org/alpine/v3.7/community
RUN echo \
  # replacing default repositories with edge ones
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \

  # Add the build packages, and then will be deleted
  && apk add --no-cache --virtual=.build-deps $BUILD_PACKAGES \
  
  # Add the packages, with a CDN-breakage fallback if needed
#  && apk add --no-cache $PACKAGES || \
#    (sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories && apk add --no-cache $PACKAGES) \

  # turn back the clock -- so hacky!
#  && echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/main/" > /etc/apk/repositories \

  # make some useful symlinks that are expected to exist
#  && cd /usr/bin \
#  && { [[ -e idle ]] || ln -s idle3 idle; } \
#  && { [[ -e pydoc ]] || ln -s pydoc3 pydoc; } \
#  && { [[ -e python ]] || ln -sf python3.6 python; } \
#  && { [[ -e python-config ]] || ln -sf python3-config python-config; } \
#  && { [[ -e pip ]] || ln -sf pip3 pip; } \
#  && ls -l idle pydoc python* pip* \
  
  # install my app software
#  && python -m pip install --upgrade pip \
#  && pip install Django==2.1 \
#  && pip install influxdb \
  && pip install pandas \
  && pip install pyecharts \
#  && pip install scipy \
#  && pip install cx_Oracle \
  
  # End
#  && apk del .build-deps \
  && echo

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
