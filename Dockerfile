FROM ubuntu:16.04

LABEL maintainer="Joseph Blackette <jab@onelessbrick.com>"

RUN  apt-get update \
  && apt-get install -y unzip \
  && apt-get install -y xvfb \
  && apt-get install -y libxtst6 \
  && apt-get install -y libxrender1 \
  && apt-get install -y libxi6 \
	&& apt-get install -y x11vnc \
  && apt-get install -y socat \
  && apt-get install -y software-properties-common \
  && apt-get install -y dos2unix \
  && apt-get install -y net-tools \
  && apt-get install -y wget \
  && apt-get install -y telnet 


# Setup IB TWS
RUN mkdir -p /opt/TWS
WORKDIR /opt/TWS
# RUN wget -q http://cdn.quantconnect.com/interactive/ibgateway-latest-standalone-linux-x64-v974.4g.sh
# RUN chmod ag+x ibgateway-latest-standalone-linux-x64-v974.4g.sh
ADD ibgateway-latest-standalone-linux-x64-v974.4g.sh ibgateway-latest-standalone-linux-x64-v974.4g.sh
RUN chmod ag+x ibgateway-latest-standalone-linux-x64-v974.4g.sh

# Setup  IBController
RUN mkdir -p /opt/IBController/ && mkdir -p /opt/IBController/Logs
WORKDIR /opt/IBController/
#RUN wget -q http://cdn.quantconnect.com/interactive/IBController-QuantConnect-3.2.0.5.zip
ADD IBController-QuantConnect-3.2.0.5.zip IBController-QuantConnect-3.2.0.5.zip
RUN unzip ./IBController-QuantConnect-3.2.0.5.zip
RUN chmod -R ug+rx *.sh && chmod -R ug+rx Scripts/*.sh

WORKDIR /

# Install TWS
RUN yes n | /opt/TWS/ibgateway-latest-standalone-linux-x64-v974.4g.sh

ENV DISPLAY :0

ADD runscript.sh runscript.sh
ADD ./vnc/xvfb_init /etc/init.d/xvfb
ADD ./vnc/vnc_init /etc/init.d/vnc
ADD ./vnc/xvfb-daemon-run /usr/bin/xvfb-daemon-run

RUN chmod -R ug+rx runscript.sh \
  && chmod -R 777 /usr/bin/xvfb-daemon-run \
  && chmod 777 /etc/init.d/xvfb \
  && chmod 777 /etc/init.d/vnc

RUN dos2unix /usr/bin/xvfb-daemon-run \
  && dos2unix /etc/init.d/xvfb \
  && dos2unix /etc/init.d/vnc \
  && dos2unix runscript.sh

# Below files copied during build to enable operation without volume mount
COPY ./ib/IBController.ini /root/IBController/IBController.ini
COPY ./ib/jts.ini /root/Jts/jts.ini

RUN mkdir /.vnc
RUN chmod -R g+rwx /opt /root /.vnc /var

CMD bash runscript.sh
