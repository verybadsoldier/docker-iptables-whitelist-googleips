FROM alpine

ENV TCP_PORT=7654
ENV IPSET_NAME="google"
ENV CHAIN_NAME="iptables-whitelist-google"
ENV TARGET_CHAINS="INPUT DOCKER-USER"

ADD google_iprange_update.sh /bin
RUN chmod +x /bin/google_iprange_update.sh

CMD ["/bin/google_iprange_update.sh"]
