const std = @import("std");

const mbedtls = @cImport({
    @cInclude("stdio.h");
});

// Just a smoke test to make sure the library is linked correctly.
test {}
