init() {
  cmd-export deploy
}

deploy() {
  for ip in $(digitalocean-ips); do
    cat "$BUILT_SITE.tar.gz" | ssh root@$ip "docker load \
      && ( docker rm -f $BUILT_SITE || true ) \
      && docker run -d --name $BUILT_SITE -p 80:8000 $BUILT_SITE" &
  done
  wait
}
