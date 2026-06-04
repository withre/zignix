const std = @import("std");
const builtin = @import("builtin");

const pinned_zig_version = "0.17.0-dev.607+456b2ec07";

pub fn main() void {
    const actual_zig_version = builtin.zig_version_string;
    const matches_pin = std.mem.eql(u8, actual_zig_version, pinned_zig_version);

    std.debug.print("  ✅ zignix example is running\n", .{});
    std.debug.print("\n", .{});
    std.debug.print("  🧰 compiler in use : {s}\n", .{actual_zig_version});
    std.debug.print("  📌 zignix pin      : {s}\n", .{pinned_zig_version});
    std.debug.print("  🔧 pin defined in  : nix/packages/zig/default.nix\n", .{});
    std.debug.print("\n", .{});

    if (matches_pin) {
        std.debug.print("  🎯 you are building with the pinned Zig.\n", .{});
    } else {
        std.debug.print("  ℹ️  this Zig differs from the pin — fine for a demo.\n", .{});
        std.debug.print("      build with the pinned Zig from this flake to match it.\n", .{});
    }
}
