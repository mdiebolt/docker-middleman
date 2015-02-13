init() {
  env-import CONTAINER_NAME
  cmd-export build
}

build() {
  docker build -t middleman .
  docker run --name "$CONTAINER_NAME" middleman
  docker cp "$CONTAINER_NAME":/usr/src/app/build.tar.gz .
  docker rm "$CONTAINER_NAME"
}
