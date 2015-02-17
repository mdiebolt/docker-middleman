# Docker Middleman

Build self contained static sites for simple high-availability deployment to major hosting providers.

## Configure GliderGun

- `curl https://dl.gliderlabs.com/glidergun/latest/$(uname -sm|tr \  _).tgz \
  | tar -zxC /usr/local/bin`

- `gun init` # creates a .gun directory

- Edit .gun_do with your Digital Ocean access key

## Steps

1. Build site and webserver
  - ⚡ Build Middleman container that will build the static site
  - ⚡ Generate static site artifact
  - ⚡ Build nginx container that will copy static site artifact
1. Configure GliderGun profile
  - One environment: production
  - AWS keys for deployment
  - Digital Ocean keys for deployment
  - Number of hosts to provision
1. Use GliderGun to provision hosts on configured hosting providers
  - ⚡ `gun build` # Build middleman container, export artifact, build nginx container
  - ⚡ `gun do provision` # provisions hosts on Digital Ocean
  - `gun do deploy`
  - ⚡ `gun do list`
  - ⚡ `gun do destroy`
