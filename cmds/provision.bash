init() {
  cmd-export provision
}

provision() {
  $PROVISION_HOOK "$@"
}
