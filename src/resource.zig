const std = @import("std");

pub const Resource = struct {
    name: []const u8,
    value: f32,

    pub fn init(name: []const u8, value: f32) Resource {
        return Resource{
            .name = name,
            .value = value,
        };
    }

    pub fn print(self: Resource) !void {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("Resource Name: {s}\n", .{self.name});
        try stdout.print("Resource Value: {d}\n", .{self.value});
    }
};
