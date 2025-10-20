const std = @import("std");

const sources_crypto = [_][]const u8{
    "aes.c",
    "aesce.c",
    "aesni.c",
    "aria.c",
    "asn1parse.c",
    "asn1write.c",
    "base64.c",
    "bignum.c",
    "bignum_core.c",
    "bignum_mod.c",
    "bignum_mod_raw.c",
    "block_cipher.c",
    "camellia.c",
    "ccm.c",
    "chacha20.c",
    "chachapoly.c",
    "cipher.c",
    "cipher_wrap.c",
    "cmac.c",
    "constant_time.c",
    "ctr_drbg.c",
    "des.c",
    "dhm.c",
    "ecdh.c",
    "ecdsa.c",
    "ecjpake.c",
    "ecp.c",
    "ecp_curves.c",
    "ecp_curves_new.c",
    "entropy.c",
    "entropy_poll.c",
    "error.c",
    "gcm.c",
    "hkdf.c",
    "hmac_drbg.c",
    "lmots.c",
    "lms.c",
    "md.c",
    "md5.c",
    "memory_buffer_alloc.c",
    "nist_kw.c",
    "oid.c",
    "padlock.c",
    "pem.c",
    "pk.c",
    "pk_ecc.c",
    "pk_wrap.c",
    "pkcs12.c",
    "pkcs5.c",
    "pkparse.c",
    "pkwrite.c",
    "platform.c",
    "platform_util.c",
    "poly1305.c",
    "psa_crypto.c",
    "psa_crypto_aead.c",
    "psa_crypto_cipher.c",
    "psa_crypto_client.c",
    "psa_crypto_driver_wrappers_no_static.c",
    "psa_crypto_ecp.c",
    "psa_crypto_ffdh.c",
    "psa_crypto_hash.c",
    "psa_crypto_mac.c",
    "psa_crypto_pake.c",
    "psa_crypto_rsa.c",
    "psa_crypto_se.c",
    "psa_crypto_slot_management.c",
    "psa_crypto_storage.c",
    "psa_its_file.c",
    "psa_util.c",
    "ripemd160.c",
    "rsa.c",
    "rsa_alt_helpers.c",
    "sha1.c",
    "sha256.c",
    "sha3.c",
    "sha512.c",
    "threading.c",
    "timing.c",
    "version.c",
    "version_features.c",
};

const sources_x509 = [_][]const u8{
    "pkcs7.c",
    "x509.c",
    "x509_create.c",
    "x509_crl.c",
    "x509_crt.c",
    "x509_csr.c",
    "x509write.c",
    "x509write_crt.c",
    "x509write_csr.c",
};

const sources_tls = [_][]const u8{
    "debug.c",
    "mps_reader.c",
    "mps_trace.c",
    "net_sockets.c",
    "ssl_cache.c",
    "ssl_ciphersuites.c",
    "ssl_client.c",
    "ssl_cookie.c",
    "ssl_debug_helpers_generated.c",
    "ssl_msg.c",
    "ssl_ticket.c",
    "ssl_tls.c",
    "ssl_tls12_client.c",
    "ssl_tls12_server.c",
    "ssl_tls13_client.c",
    "ssl_tls13_generic.c",
    "ssl_tls13_keys.c",
    "ssl_tls13_server.c",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("mbedtls", .{});

    const lib = b.addLibrary(.{
        .name = "mbedtls",
        .linkage = .static,
        .root_module = b.createModule(.{
            .link_libc = true,
            .target = target,
            .optimize = optimize,
        }),
    });
    lib.addIncludePath(upstream.path("include/"));
    lib.installHeadersDirectory(upstream.path("include/psa"), "psa", .{});
    lib.installHeadersDirectory(upstream.path("include/mbedtls"), "mbedtls", .{});

    // The original mbedtls build builds three separate libraries that you can link separately,
    // but for the sake of simplicity we're making one.
    lib.addCSourceFiles(.{ .root = upstream.path("library"), .files = &sources_crypto });
    lib.addCSourceFiles(.{ .root = upstream.path("library"), .files = &sources_x509 });
    lib.addCSourceFiles(.{ .root = upstream.path("library"), .files = &sources_tls });

    switch (target.result.os.tag) {
        .windows => {
            lib.root_module.linkSystemLibrary("bcrypt", .{});
        },
        .freebsd => {
            // mbedtls contains a bug: it explicitly defines _POSIX_C_SOURCE
            // despite using the explicit_bzero function, which is only defined as a GNU extension.
            // On Linux, _GNU_SOURCE explicitly makes it available, while on FreeBSD
            // this results in an `implicit-function-declaration` warning, which zig always converts to an error.
            // We explicitly expose all BSD* functions to make this available.
            lib.root_module.addCMacro("__BSD_VISIBLE", "1");
        },
        else => {},
    }

    b.installArtifact(lib);

    // Smoke unit test
    const test_mod = b.addModule("test", .{
        .root_source_file = b.path("tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_mod.linkLibrary(lib);

    const run_mod_tests = b.addRunArtifact(b.addTest(.{ .root_module = test_mod }));

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
