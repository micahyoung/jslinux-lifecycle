#!/bin/sh
set -o errexit -o pipefail -o nounset

# create run-image (contains only an empty layer)
touch layer.tar
layerTarSHA=$(sha256sum layer.tar | awk '{print $1}')

cat > config.json <<EOF
{
  "rootfs": {
    "type": "layers",
    "diff_ids": [
      "sha256:$layerTarSHA"
    ]
  }
}
EOF

configSHA=$(sha256sum config.json | awk '{print $1}')
mv config.json "sha256:$configSHA"

gzip -c layer.tar > layer.tar.gz
layerTgzSHA=$(sha256sum layer.tar.gz | awk '{print $1}' )
mv layer.tar.gz "$layerTgzSHA.tar.gz"

cat > manifest.json <<EOF
[{"Config":"sha256:$configSHA","Layers":["$layerTgzSHA.tar.gz"]}]
EOF

tar -c -f run-image.tar "sha256:$configSHA" "$layerTgzSHA.tar.gz" manifest.json

# start in-memory registry in background
mv ./registry /registry
chmod +x /registry

/registry -port 5000 2>/dev/null &
sleep 1

# crane push the run image to the registry
mv ./crane /crane
chmod +x /crane

/crane push run-image.tar localhost:5000/run-image

# create minimal always-detect buildpack
mkdir -p /cnb/buildpacks/hello-world/0.0.1/bin

cat > /cnb/stack.toml <<EOF
[run-image]
  image = "localhost:5000/run-image"
EOF

cat > /cnb/order.toml <<EOF
[[order]]
  [[order.group]]
    id = "hello-world"
    version = "0.0.1"
EOF

cat > /cnb/buildpacks/hello-world/0.0.1/buildpack.toml <<EOF
api = "0.2"

[buildpack]
id = "hello-world"
version = "0.0.1"

[[stacks]]
id = "io.buildpacks.samples.stacks.jslinux"
EOF

cat > /cnb/buildpacks/hello-world/0.0.1/bin/detect <<EOF
#!/bin/true
EOF

cat > /cnb/buildpacks/hello-world/0.0.1/bin/build <<EOF
#!/bin/sh
echo Hello world
EOF

chmod a+x /cnb/buildpacks/hello-world/0.0.1/bin/*

# run lifecycle (empty launcher)
mkdir -p /cnb/lifecycle /layers /platform /workspace /cache
touch /cnb/lifecycle/launcher

mv lifecycle /cnb/lifecycle/creator
chmod +x /cnb/lifecycle/creator

APP_IMAGE=localhost:5000/my-app:latest
RUN_IMAGE=localhost:5000/run-image:latest

/cnb/lifecycle/creator  -app=/workspace -layers=/layers -report=/layers/report.toml -cache-dir=/cache -log-level=debug $APP_IMAGE
