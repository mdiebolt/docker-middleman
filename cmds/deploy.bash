SSH_OPTS="${SSH_OPTS:--o PasswordAuthentication=no -o StrictHostKeyChecking=no}"

init() {
  cmd-export deploy
}

deploy() {
  for ip in $(digitalocean-ips); do
    cat "$BUILT_SITE.tar.gz" | ssh -A $SSH_OPTS root@$ip "docker load \
      && ( docker rm -f $BUILT_SITE || true ) \
      && docker run -d --name $BUILT_SITE -p 80:8000 $BUILT_SITE" &
  done
  wait
}
