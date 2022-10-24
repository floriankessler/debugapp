# our actual docker image
FROM phusion/baseimage:master
LABEL maintainer="Florian Kessler <florian@msl.solutions>"

# https://wiki.ubuntu.com/DashAsBinSh
# don't link 'sh' to dash but to bash as our code builds on bashisms throughout
RUN set -eux; \
    echo "dash dash/sh boolean false" | debconf-set-selections; \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# install ttyd
RUN set -eux; \
    curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.2/ttyd.x86_64 \
	 -o /usr/local/sbin/ttyd; \
    chmod 0700 /usr/local/sbin/ttyd

# install openresty
RUN set -eux; \
	apt-get update; \
	apt-get -y install --no-install-recommends wget gnupg ca-certificates; \
	wget -O - https://openresty.org/package/pubkey.gpg |  apt-key add - ; \
	echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
	    |  tee /etc/apt/sources.list.d/openresty.list; \
	apt-get update; \
	apt-get -y install \
	    openresty \
	; \
	apt-get purge -y --auto-remove; \
	rm -rf /var/lib/apt/lists/*;

## install pgadmin4
#RUN set -eux; \
	#date; \
	#apt-get update; \
	#apt-get -y install --no-install-recommends \
			#python3-pip \
			#python3-venv \
			#; \
	#apt-get purge -y --auto-remove; \
	#rm -rf /var/lib/apt/lists/*;
#RUN set -eux; \
	#cd / && python3 -m venv pgadmin4 && \
	#source /pgadmin4/bin/activate && \
	#pip3 install --no-cache-dir wheel && \
	#pip3 install --no-cache-dir pgadmin4 && \
	#pip3 install --no-cache-dir gunicorn;

# install varia
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	    gawk \
	    gettext-base \
	    postgresql-client-12 \
	    socat \
	    tmux \
	    unzip \
	; \
	apt-get purge -y --auto-remove; \
	rm -rf /var/lib/apt/lists/*;

CMD ["/usr/local/sbin/my_init"]

# Generate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
#RUN rm -f /etc/service/sshd/down && \
#    /etc/my_init.d/00_regen_ssh_host_keys.sh
#
#RUN echo "Port 2222" >> /etc/ssh/sshd_config && \
#    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
#    echo "root:Docker!" | chpasswd

COPY rootfs/ /
