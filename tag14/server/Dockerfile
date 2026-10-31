# syntax=docker/dockerfile:1
# notes-server – zweiter Docker-Host mit SSH, nur für das Lab (Tag 14)
FROM docker:29.9-dind
# deploy: Login nur per Schlüssel ("*" statt "!" – Alpine sperrt sonst das Konto)
RUN apk add --no-cache openssh-server=~10.3 \
 && adduser -D -s /bin/sh deploy \
 && addgroup deploy docker \
 && sed -i 's/^deploy:!/deploy:*/' /etc/shadow \
 && printf '%s\n' 'PasswordAuthentication no' 'PermitRootLogin no' \
      'AllowUsers deploy' 'AllowTcpForwarding local' > /etc/ssh/sshd_config.d/lab.conf \
 && ssh-keygen -A
COPY --chmod=755 start.sh /usr/local/bin/start.sh
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/start.sh"]
