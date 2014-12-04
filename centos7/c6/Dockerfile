FROM debian:jessie
#busybox

COPY fileserve /

VOLUME ["/data"]

EXPOSE 8080

CMD ["/fileserve", "-d=/data", "-http=:8080"]
