const ResourceCost = struct {
    name: []const u8,
    amount: f64,
};


const Action = struct {
    name: []const u8,
    cost: []const ResourceCost,
    reward: []const ResourceCost,
    cooldown: u32,
    last_tick_used: u64,
};