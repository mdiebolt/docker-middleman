init() {
  cmd-export deploy
}

deploy() {
  for ip in $(digitalocean-ips); do
    scp "$BUILT_SITE.tar.gz" "root@$ip:$BUILT_SITE.tar.gz"
    ssh root@$ip "docker load -i $BUILT_SITE.tar.gz"
    ssh root@$ip "docker rm -f $BUILT_SITE || true"
    ssh root@$ip "docker run -d --name $BUILT_SITE -p 80:8000 $BUILT_SITE"
  done
}
