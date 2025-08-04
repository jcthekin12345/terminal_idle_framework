const ResourceCost = struct {
    name: []const u8,
    amount: f64,
};


const Action = struct {
    name: []const u8,
    description: ?[]const u8,
    cost: ResourceCost,
    cooldown: f64, // in seconds
    duration: f64, // in seconds
    is_available: bool, // whether the action can be performed
}