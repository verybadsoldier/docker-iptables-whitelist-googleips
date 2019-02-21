FROM ubuntu:bionic

RUN apt-get update;apt-get install -y bash dnsutils ipset iptables && rm -rf /etc/apt/cache/*

ENV TCP_PORT=7654
ENV IPSET_NAME="google"
ENV CHAIN_NAME="GOOGLE-WHITELIST"
ENV TARGET_CHAINS="INPUT DOCKER-USER"

ADD google_iprange_update.sh /bin
RUN chmod +x /bin/google_iprange_update.sh

CMD ["/bin/google_iprange_update.sh"]
