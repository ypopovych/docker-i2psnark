# docker-i2psnark
I2P Snark standalone Docker image

## Usage

You can start the container like this:

```bash
docker volume create i2psnark_config
docker run --restart=unless-stopped -d --name=i2psnark \
    -v /my/torrents/path:/snark/downloads \
    -v i2psnark_config:/snark/config \
    -e I2CP_HOST="172.17.0.1" \
    ypopovych/i2psnark
```

The container needs a volume to cache some data and save config. In the example above a Docker volume is used for that. You can also map the cache to some host folder.

## Configuration

You can configure the container using the following environment variables:

| Environment Variable  | Description | Default Value |
| ------------- | ------------- | ------------- |
| `I2CP_HOST`   | REQUIRED!. I2P instance host. Can be internal docker ip from bridge netwok or container name. | `""` |
| `I2CP_PORT`   | I2CP interface port on I2P host.  | `7654` |
| `HOSTNAMES`   | Hostnames allowed for Web UI. Comma separated list. | `""` |
| `HOST_UID`    | UID of the host user from which i2psnark will be run. | `1000` |
| `HOST_GID`    | GID of the host group from which i2psnark will be run.  | `1000` |

`i2psnark.conf` file can be found in the configuration volume of the container. Or from the Web UI.

## Supported Architectures

The following Docker architectures are supported: `linux/arm64`, `linux/arm/v7` and `linux/amd64`