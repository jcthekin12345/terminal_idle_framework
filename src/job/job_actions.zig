const std = @import("std");

// TODO: Implement a way to handle work hours for different jobs specifically.
// TODO: Implement a way to track work hours and manage resources.
pub fn go_to_work() !bool {
    var current_hour: u8 = 0; // default start hour
    const end_hour: u8 = 8;

    while (current_hour < end_hour) : (current_hour += 1) {
        try std.io.getStdOut().writer().print("Working hour: {}\n", .{current_hour});
        std.time.sleep(1 * std.time.ns_per_s); // Simulate work
    }
    return true;
}