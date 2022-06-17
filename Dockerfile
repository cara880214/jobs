FROM  registry.cn-hangzhou.aliyuncs.com/itoms_niu/znyw_chgcheck:20220427_001

ENV TIMEZONE=Asia/Shanghai
ENV TNS_ADMIN=/oracle_client/instantclient_11_2
ENV NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
ENV LD_LIBRARY_PATH=/oracle_client/instantclient_11_2

COPY ./instantclient-basic-linux.x64-11.2.0.4.0.zip ./entrypoint.sh   /


## running
RUN echo "Begin" \
  && echo "********** 安装oracle驱动********************" \
  && mkdir /oracle_client \
  && mv /instantclient-basic-linux.x64-11.2.0.4.0.zip /oracle_client \
  && cd /oracle_client \
  && unzip instantclient-basic-linux.x64-11.2.0.4.0.zip && rm -rf instantclient-basic-linux.x64-11.2.0.4.0.zip \
  && echo "End"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
