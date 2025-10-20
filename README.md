# [mbedtls](https://tls.mbed.org)@v3.6.5 [![Build and test library](https://github.com/zig-devel/mbedtls/actions/workflows/library.yml/badge.svg)](https://github.com/zig-devel/mbedtls/actions/workflows/library.yml)

An open source, portable, easy to use, readable and flexible TLS library

## Usage

Install library:

```sh
zig fetch --save https://github.com/zig-devel/mbedtls/archive/refs/tags/3.6.5-0.tar.gz
```

Statically link with `mod` module:

```zig
const mbedtls = b.dependency("mbedtls", .{
    .target = target,
    .optimize = optimize,
});

mod.linkLibrary(mbedtls.artifact("mbedtls"));
```

## License

All code in this repo is double-licensed under [0BSD](./LICENSES/0BSD.txt) OR [Apache-2.0](./LICENSES/Apache-2.0.txt).
