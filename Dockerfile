FROM debian:buster

RUN apt-get update \
	&& apt-get -y install --no-install-recommends xorriso isolinux \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY init /sbin/

ENTRYPOINT ["/sbin/init"]
