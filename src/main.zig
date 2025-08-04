const std = @import("std");


pub fn main() !void {
    const work_functions = @import("job/work_functions.zig");
    
    const result = try work_functions.go_to_work();
    if (result) {
        try std.io.getStdOut().writer().print("Work completed successfully.\n", .{});
    } else {
        try std.io.getStdOut().writer().print("Work was not completed.\n", .{});
    }
}
