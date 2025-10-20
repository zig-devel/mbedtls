const std = @import("std");

const mbedtls = @cImport({
    @cInclude("mbedtls/version.h");
});

// Just a smoke test to make sure the library is linked correctly.
test {
    var buffer: [16:0]u8 = undefined;
    mbedtls.mbedtls_version_get_string(&buffer);

    try std.testing.expectEqualStrings(std.mem.sliceTo(&buffer, 0), "3.6.5");
}
