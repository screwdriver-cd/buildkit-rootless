# buildkit-rootless

[![Build Status][build-image]][build-url]
[![Latest Release][version-image]][version-url]
[![Open Issues][issues-image]][issues-url]

This container image launches a rootless BuildKit daemon inside Screwdriver.cd build environments. It is based on the rootless variant of [moby/buildkit](https://github.com/moby/buildkit), with the following modifications:

- Additional TLS-related scripts to enable secure (TLS) communication.
- A default buildkitd.toml configuration file for convenient, out-of-the-box usage.

By running this image, you can take advantage of Docker builds in a rootless context, helping to maintain a more secure and isolated environment.

## Usage

### Docker

```bash
## run buildkitd container
$ docker run -d -p 1234:1234 --name buildkit-container screwdrivercd/buildkit-rootless --addr tcp://0.0.0.0:1234

## create remote builder in buildkitd container
$ docker buildx create --name remote-buildkit --driver remote tcp://localhost:1234

## build image with remote builder
$ docker buildx use remote-buildkit
$ docker buildx build -t <org>/<name>:<tag> --push .
```

## License

This repository is licensed under the same Apache License 2.0 terms as moby/buildkit.  
Please see the [LICENSE](./LICENSE) file for the full text.

[build-image]: https://cd.screwdriver.cd/pipelines/xxxx/badge
[build-url]: https://cd.screwdriver.cd/pipelines/xxxx
[version-image]: https://img.shields.io/github/tag/screwdriver-cd/buildkit-rootless.svg
[version-url]: https://github.com/screwdriver-cd/buildkit-rootless/releases
[issues-image]: https://img.shields.io/github/issues/screwdriver-cd/screwdriver.svg
[issues-url]: https://github.com/screwdriver-cd/screwdriver/issues
