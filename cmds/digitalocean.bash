init() {
  env-import TOKEN
  cmd-export "digitalocean-list" "list"
  cmd-export "digitalocean-images" "images"
  cmd-export "digitalocean-ssh-keys" "ssh-keys"
}

digitalocean-provision() {
  desc="Spin up a new digital ocean host"
  declare name="$1" ssh_keys="$2" image="${3:-docker}"

  : "${name:?}" "${ssh_keys:?}"

  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d "{\"name\":\"$name\",\"region\":\"nyc3\",\"size\":\"512mb\",\"image\":\"$image\",\"ssh_keys\":[$ssh_keys],\"backups\":false,\"ipv6\":true,\"user_data\":null,\"private_networking\":null}" "https://api.digitalocean.com/v2/droplets"
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

digitalocean-format-list() {
  jq '[.droplets[] as $droplet | {
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
