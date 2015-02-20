# TODO: add desc for all functions
# TODO: make digitalocean helper take arbitrary verbs
init() {
  env-import TOKEN
  env-import CLUSTER_NAME
  env-import DIGITALOCEAN_SSH_KEY
  cmd-export "digitalocean-list" "list"
  cmd-export "digitalocean-images" "images"
  cmd-export "digitalocean-ssh-keys" "ssh-keys"
  cmd-export "digitalocean-destroy" "destroy"
  cmd-export "digitalocean-provision" "provision"
}

digitalocean-provision() {
  desc="Spin up cluster of droplets"
  declare count="$1" name="${2:-$CLUSTER_NAME}" ssh_keys="${3:-$DIGITALOCEAN_SSH_KEY}"

  : "${count:?}"

  for i in $(seq 1 $count); do
    digitalocean-create-droplet "$name-$i" "$ssh_keys"
  done
}

digitalocean-destroy() {
  local running_instances
  running_instances="$(digitalocean-list | jq -r ".[] | select(.name | startswith(\"$CLUSTER_NAME\")) | .id")"

  for id in $running_instances; do
    digitalocean-delete-droplet "$id"
  done
}

# TODO: pretty print output
digitalocean-create-droplet() {
  desc="Spin up a new digital ocean host"
  declare name="$1" ssh_keys="$2" image="${3:-docker}"

  : "${name:?}" "${ssh_keys:?}"

  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"name\":\"$name\",\"region\":\"nyc3\",\"size\":\"512mb\",\"image\":\"$image\",\"ssh_keys\":[$ssh_keys],\"backups\":false,\"ipv6\":true,\"user_data\":null,\"private_networking\":null}" "https://api.digitalocean.com/v2/droplets"
}

digitalocean-delete-droplet() {
  declare droplet_id="$1"

  : "${droplet_id:?}"

  curl -X DELETE \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$droplet_id"
}

# TODO: fuzzy matching for droplet names
digitalocean-list() {
  digitalocean-get "droplets" | digitalocean-format-list
}

digitalocean-images() {
  desc="Look up different types of images"
  declare type="${1-distribution}"

  digitalocean-get "images?type=$type" | digitalocean-format-images
}

digitalocean-ips() {
  desc="Look up image IPs"
  digitalocean-list | digitalocean-format-ips
}

digitalocean-ssh-keys() {
  digitalocean-get "account/keys" | digitalocean-format-ssh-keys
}

digitalocean-get() {
  declare action="$1"
  : "${action:?}"

  curl -s \
    -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/$action"
}

digitalocean-format-ips() {
  jq -r '.[] | .ip_address'
}

digitalocean-format-list() {
  jq '[.droplets[] as $droplet | select($droplet.status == "active") | {
    id: $droplet.id,
    name: $droplet.name,
    ip_address: $droplet.networks.v4[] | select(.type == "public") | .ip_address }]'
}

digitalocean-format-images() {
  jq '[.images[] as $image | {
    name: $image.name,
    distribution: $image.distribution,
    slug: $image.slug }]'
}

digitalocean-format-ssh-keys() {
  jq '[.ssh_keys[] as $key | {
    id: $key.id,
    name: $key.name,
    fingerprint: $key.fingerprint }]'
}
