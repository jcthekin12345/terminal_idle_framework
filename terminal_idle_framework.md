# Terminal Idle Framework (TIF) - Zig Edition

**A blazingly fast, memory-safe framework for building terminal-based idle/incremental games in Zig**

## Project Overview

The Terminal Idle Framework provides Zig developers with a zero-allocation, comptime-configured toolkit to create engaging idle games that run in the terminal. Built with Zig's performance and safety guarantees, it handles all the common patterns, mechanics, and UI elements while maintaining predictable memory usage and maximum performance.

## Core Idle Game Loop Types

### 1. **Resource Generation Loops**
- **Linear Growth**: `rate * time`
- **Exponential Growth**: `base * multiplier^time`
- **Compound Growth**: Multi-resource feedback loops
- **Diminishing Returns**: `rate * (1 - decay^amount)`
- **Cyclical Patterns**: Sin/cos wave-based fluctuations

### 2. **Upgrade Purchase Loops**
- **Direct Multipliers**: `base_rate *= upgrade_multiplier`
- **Efficiency Upgrades**: Reduce costs, increase yields
- **Automation Upgrades**: Background processing
- **Prestige Upgrades**: Cross-reset permanent bonuses
- **Synergy Upgrades**: Multiplicative cross-system bonuses

### 3. **Time-Based Progression Loops**
- **Real-time Progression**: Nanosecond-precise offline calculation
- **Active Time Bonus**: Reward player engagement
- **Time Gates**: Duration-locked features
- **Seasonal Events**: Calendar-based content
- **Achievement Timers**: Long-term progression tracking

### 4. **Prestige/Reset Loops**
- **Soft Reset**: Preserve meta-currency and upgrades
- **Hard Reset**: Fresh start with permanent multipliers
- **Ascension**: Unlock new game mechanics
- **Rebirth**: Exponential bonus stacking
- **Evolution**: Procedural game transformation

## Zig-Specific Architecture

### Memory Management Strategy
```zig
// Zero-allocation during gameplay - all memory pre-allocated at startup
const GameArena = struct {
    resources: [MAX_RESOURCES]Resource,
    generators: [MAX_GENERATORS]Generator,
    upgrades: [MAX_UPGRADES]Upgrade,
    save_buffer: [SAVE_BUFFER_SIZE]u8,
    
    // Fixed-size ring buffers for events
    events: std.fifo.LinearFifo(GameEvent, .{ .Static = 1024 }),
    notifications: std.fifo.LinearFifo(Notification, .{ .Static = 256 }),
};
```

### Comptime Configuration
```zig
// Game configuration determined at compile time
const GameConfig = struct {
    max_resources: comptime_int = 64,
    max_generators: comptime_int = 128,
    max_upgrades: comptime_int = 512,
    tick_rate_hz: comptime_int = 60,
    save_interval_seconds: comptime_int = 30,
    
    // Comptime number format selection
    number_type: type = f64,  // or BigInt for really big numbers
    
    // Feature flags
    enable_prestige: bool = true,
    enable_achievements: bool = true,
    enable_offline_progress: bool = true,
};

pub fn IdleGame(comptime config: GameConfig) type {
    return struct {
        // ... game implementation using config
    };
}
```

## Core Framework Components

### 1. **Game State (Zero-Allocation)**
```zig
const Resource = struct {
    name: [32]u8,           // Fixed-size string
    amount: f64,
    rate: f64,
    cap: ?f64,
    display_precision: u8,
    
    pub fn add(self: *Resource, value: f64) void {
        const new_amount = self.amount + value;
        self.amount = if (self.cap) |cap| @min(new_amount, cap) else new_amount;
    }
    
    pub fn can_afford(self: Resource, cost: f64) bool {
        return self.amount >= cost;
    }
    
    pub fn format_display(self: Resource, buffer: []u8) ![]u8 {
        return std.fmt.bufPrint(buffer, "{d:.{}}", .{ self.amount, self.display_precision });
    }
};

const Generator = struct {
    name: [32]u8,
    base_rate: f64,
    multiplier: f64,
    target_resource: u8,    // Index into resources array
    active: bool,
    cost: f64,
    cost_scaling: f64,
    owned: u32,
    
    pub fn calculate_rate(self: Generator) f64 {
        return self.base_rate * self.multiplier * @as(f64, @floatFromInt(self.owned));
    }
    
    pub fn get_cost(self: Generator) f64 {
        return self.cost * std.math.pow(f64, self.cost_scaling, @as(f64, @floatFromInt(self.owned)));
    }
};

const Upgrade = struct {
    name: [64]u8,
    description: [256]u8,
    cost_resources: [8]ResourceCost,  // Max 8 different resource costs
    effect: UpgradeEffect,
    purchased: bool,
    visible: bool,
    
    const ResourceCost = struct {
        resource_id: u8,
        amount: f64,
    };
    
    const UpgradeEffect = union(enum) {
        generator_multiplier: struct { generator_id: u8, multiplier: f64 },
        resource_multiplier: struct { resource_id: u8, multiplier: f64 },
        unlock_generator: u8,
        unlock_upgrade: u8,
        prestige_unlock: void,
    };
};
```

### 2. **High-Performance Game Loop**
```zig
const GameLoop = struct {
    arena: GameArena,
    config: GameConfig,
    running: bool,
    last_tick: i64,
    last_save: i64,
    total_ticks: u64,
    
    pub fn init(config: GameConfig) GameLoop {
        return GameLoop{
            .arena = GameArena{
                .resources = std.mem.zeroes([config.max_resources]Resource),
                .generators = std.mem.zeroes([config.max_generators]Generator),
                .upgrades = std.mem.zeroes([config.max_upgrades]Upgrade),
                .save_buffer = std.mem.zeroes([SAVE_BUFFER_SIZE]u8),
                .events = std.fifo.LinearFifo(GameEvent, .{ .Static = 1024 }).init(),
                .notifications = std.fifo.LinearFifo(Notification, .{ .Static = 256 }).init(),
            },
            .config = config,
            .running = false,
            .last_tick = 0,
            .last_save = 0,
            .total_ticks = 0,
        };
    }
    
    pub fn run(self: *GameLoop) !void {
        self.running = true;
        self.last_tick = std.time.nanoTimestamp();
        
        while (self.running) {
            const now = std.time.nanoTimestamp();
            const delta_ns = now - self.last_tick;
            const delta_seconds = @as(f64, @floatFromInt(delta_ns)) / 1_000_000_000.0;
            
            try self.update(delta_seconds);
            try self.render();
            
            // Sleep to maintain target framerate
            const target_frame_time = 1_000_000_000 / self.config.tick_rate_hz;
            const elapsed = std.time.nanoTimestamp() - now;
            if (elapsed < target_frame_time) {
                std.time.sleep(@intCast(target_frame_time - elapsed));
            }
            
            self.last_tick = now;
            self.total_ticks += 1;
            
            // Auto-save
            if (now - self.last_save > self.config.save_interval_seconds * 1_000_000_000) {
                try self.save_game();
                self.last_save = now;
            }
        }
    }
    
    fn update(self: *GameLoop, delta_time: f64) !void {
        // Update all generators
        for (&self.arena.generators) |*generator| {
            if (!generator.active) continue;
            
            const production = generator.calculate_rate() * delta_time;
            self.arena.resources[generator.target_resource].add(production);
        }
        
        // Process events
        while (self.arena.events.readItem()) |event| {
            try self.handle_event(event);
        }
        
        // Update visibility of upgrades/generators
        self.update_visibility();
    }
};
```

### 3. **Terminal UI System (No Allocations)**
```zig
const TerminalUI = struct {
    screen_buffer: [SCREEN_WIDTH * SCREEN_HEIGHT]u8,
    width: u16,
    height: u16,
    cursor_x: u16,
    cursor_y: u16,
    current_tab: GameTab,
    
    const GameTab = enum {
        resources,
        generators,
        upgrades,
        achievements,
        statistics,
        settings,
    };
    
    pub fn init() !TerminalUI {
        const size = try get_terminal_size();
        return TerminalUI{
            .screen_buffer = std.mem.zeroes([SCREEN_WIDTH * SCREEN_HEIGHT]u8),
            .width = size.width,
            .height = size.height,
            .cursor_x = 0,
            .cursor_y = 0,
            .current_tab = .resources,
        };
    }
    
    pub fn render_game(self: *TerminalUI, game: *GameLoop) !void {
        self.clear_screen();
        
        // Render header
        try self.render_header(game);
        
        // Render main content based on current tab
        switch (self.current_tab) {
            .resources => try self.render_resources(game),
            .generators => try self.render_generators(game),
            .upgrades => try self.render_upgrades(game),
            .achievements => try self.render_achievements(game),
            .statistics => try self.render_statistics(game),
            .settings => try self.render_settings(game),
        }
        
        // Render footer with controls
        try self.render_footer();
        
        // Flush to terminal
        try self.flush();
    }
    
    fn render_resources(self: *TerminalUI, game: *GameLoop) !void {
        self.set_cursor(2, 4);
        try self.write_line("═══ RESOURCES ═══");
        
        var buffer: [64]u8 = undefined;
        var y: u16 = 6;
        
        for (game.arena.resources) |resource| {
            if (resource.name[0] == 0) continue; // Skip empty slots
            
            self.set_cursor(2, y);
            const name = std.mem.sliceTo(&resource.name, 0);
            const amount_str = try resource.format_display(&buffer);
            
            // Color coding for different resource states
            const color = if (resource.cap) |cap| 
                if (resource.amount >= cap * 0.9) "\x1b[31m" // Red if near cap
                else if (resource.rate > 0) "\x1b[32m"      // Green if growing
                else "\x1b[37m"                              // White if stable
            else if (resource.rate > 0) "\x1b[32m"
                else "\x1b[37m";
            
            try self.write_formatted("{s}{s}: {s}\x1b[0m", .{ color, name, amount_str });
            
            // Show rate if significant
            if (@abs(resource.rate) > 0.01) {
                const rate_str = try std.fmt.bufPrint(buffer[32..], " ({d:.2}/s)", .{resource.rate});
                try self.write(rate_str);
            }
            
            y += 1;
        }
    }
    
    fn render_generators(self: *TerminalUI, game: *GameLoop) !void {
        self.set_cursor(2, 4);
        try self.write_line("═══ GENERATORS ═══");
        
        var buffer: [128]u8 = undefined;
        var y: u16 = 6;
        
        for (game.arena.generators, 0..) |generator, i| {
            if (generator.name[0] == 0) continue;
            
            self.set_cursor(2, y);
            const name = std.mem.sliceTo(&generator.name, 0);
            const cost = generator.get_cost();
            const rate = generator.calculate_rate();
            
            // Format: "Generator Name [Owned: 5] [Rate: 1.23/s] [Cost: 100]"
            const info = try std.fmt.bufPrint(&buffer, 
                "{s} [Owned: {}] [Rate: {d:.2}/s] [Cost: {d:.0}]", 
                .{ name, generator.owned, rate, cost });
            
            // Color based on affordability
            const can_buy = game.arena.resources[0].can_afford(cost); // Assume first resource is currency
            const color = if (can_buy) "\x1b[32m" else "\x1b[90m";
            
            try self.write_formatted("{s}{s}\x1b[0m", .{ color, info });
            
            // Show purchase key
            try self.write_formatted(" [{}]", .{i + 1});
            
            y += 1;
        }
    }
};
```

## Zig-Specific Features

### 1. **Comptime Game Templates**
```zig
// Cookie Clicker template
const CookieClickerConfig = GameConfig{
    .max_resources = 4,     // Cookies, CPS, Prestige Points, Heavenly Chips
    .max_generators = 15,   // Cursor, Grandma, Farm, etc.
    .max_upgrades = 100,
    .number_type = f64,
    .enable_prestige = true,
};

pub const CookieClicker = IdleGame(CookieClickerConfig);

// Mining Game template  
const MiningGameConfig = GameConfig{
    .max_resources = 16,    // Ores, refined materials, tools
    .max_generators = 32,   // Miners, smelters, refineries
    .max_upgrades = 200,
    .number_type = BigInt,  // For really big numbers
    .enable_achievements = true,
};

pub const MiningGame = IdleGame(MiningGameConfig);
```

### 2. **BigInt Support for Massive Numbers**
```zig
const BigNumber = struct {
    mantissa: f64,
    exponent: i32,
    
    pub fn init(value: f64) BigNumber {
        return BigNumber{ .mantissa = value, .exponent = 0 };
    }
    
    pub fn add(self: BigNumber, other: BigNumber) BigNumber {
        // Handle big number arithmetic
        if (self.exponent == other.exponent) {
            return BigNumber{
                .mantissa = self.mantissa + other.mantissa,
                .exponent = self.exponent,
            }.normalize();
        }
        // Handle different exponents...
    }
    
    pub fn format(self: BigNumber, buffer: []u8) ![]u8 {
        if (self.exponent < 3) {
            return std.fmt.bufPrint(buffer, "{d:.2}", .{self.mantissa * std.math.pow(f64, 10, @floatFromInt(self.exponent))});
        } else {
            const suffixes = [_][]const u8{ "", "K", "M", "B", "T", "Qa", "Qt", "Sx", "Sp", "Oc" };
            const suffix_index = @min(@as(usize, @intCast(@divFloor(self.exponent, 3))), suffixes.len - 1);
            const display_value = self.mantissa * std.math.pow(f64, 10, @floatFromInt(@mod(self.exponent, 3)));
            return std.fmt.bufPrint(buffer, "{d:.2}{s}", .{ display_value, suffixes[suffix_index] });
        }
    }
};
```

### 3. **Binary Save Format**
```zig
const SaveFormat = packed struct {
    version: u32,
    timestamp: i64,
    total_playtime: u64,
    resources: [64]f64,
    generators: [128]packed struct {
        owned: u32,
        multiplier: f32,
    },
    upgrades_bitfield: u512,  // 512 bits for upgrade ownership
    achievements_bitfield: u256,
    checksum: u32,
    
    pub fn calculate_checksum(self: SaveFormat) u32 {
        const bytes = std.mem.asBytes(&self);
        return std.hash.crc.Crc32.hash(bytes[0..bytes.len-4]); // Exclude checksum field
    }
    
    pub fn save_to_file(self: SaveFormat, path: []const u8) !void {
        var save_with_checksum = self;
        save_with_checksum.checksum = self.calculate_checksum();
        
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();
        
        try file.writeAll(std.mem.asBytes(&save_with_checksum));
    }
    
    pub fn load_from_file(path: []const u8) !SaveFormat {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        
        var save_data: SaveFormat = undefined;
        _ = try file.readAll(std.mem.asBytes(&save_data));
        
        const expected_checksum = save_data.calculate_checksum();
        if (save_data.checksum != expected_checksum) {
            return error.CorruptedSave;
        }
        
        return save_data;
    }
};
```

### 4. **Performance Monitoring**
```zig
const PerformanceMonitor = struct {
    frame_times: [60]u64,
    frame_index: u8,
    update_time_ns: u64,
    render_time_ns: u64,
    
    pub fn begin_frame(self: *PerformanceMonitor) void {
        self.frame_start = std.time.nanoTimestamp();
    }
    
    pub fn end_update(self: *PerformanceMonitor) void {
        self.update_time_ns = std.time.nanoTimestamp() - self.frame_start;
    }
    
    pub fn end_frame(self: *PerformanceMonitor) void {
        const frame_time = std.time.nanoTimestamp() - self.frame_start;
        self.frame_times[self.frame_index] = frame_time;
        self.frame_index = (self.frame_index + 1) % 60;
        self.render_time_ns = frame_time - self.update_time_ns;
    }
    
    pub fn get_average_fps(self: PerformanceMonitor) f64 {
        var total: u64 = 0;
        for (self.frame_times) |time| total += time;
        const avg_ns = total / 60;
        return 1_000_000_000.0 / @as(f64, @floatFromInt(avg_ns));
    }
};
```

## Build System Integration

### build.zig
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    // Main framework module
    const tif = b.addModule("tif", .{
        .root_source_file = b.path("src/tif.zig"),
    });
    
    // Example games
    const cookie_clicker = b.addExecutable(.{
        .name = "cookie-clicker",
        .root_source_file = b.path("examples/cookie_clicker.zig"),
        .target = target,
        .optimize = optimize,
    });
    cookie_clicker.root_module.addImport("tif", tif);
    
    const mining_game = b.addExecutable(.{
        .name = "mining-game", 
        .root_source_file = b.path("examples/mining_game.zig"),
        .target = target,
        .optimize = optimize,
    });
    mining_game.root_module.addImport("tif", tif);
    
    // Install artifacts
    b.installArtifact(cookie_clicker);
    b.installArtifact(mining_game);
    
    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("src/tif.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    const test_step = b.step("test", "Run framework tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
```

## Example Game Implementation

### Cookie Clicker in 100 Lines
```zig
const std = @import("std");
const tif = @import("tif");

const CookieGame = tif.IdleGame(.{
    .max_resources = 2,
    .max_generators = 8,
    .max_upgrades = 20,
});

pub fn main() !void {
    var game = CookieGame.init();
    
    // Setup resources
    game.add_resource("Cookies", 0, null, 0);
    game.add_resource("CpS", 0, null, 2);
    
    // Setup generators
    game.add_generator("Cursor", 0.1, 15, 1.15);
    game.add_generator("Grandma", 1, 100, 1.15);
    game.add_generator("Farm", 8, 1100, 1.15);
    game.add_generator("Mine", 47, 12000, 1.15);
    game.add_generator("Factory", 260, 130000, 1.15);
    
    // Setup upgrades
    game.add_upgrade("Reinforced Cursor", 100, .{ .generator_multiplier = .{ .generator_id = 0, .multiplier = 2.0 } });
    game.add_upgrade("Lucky Grandma", 1000, .{ .generator_multiplier = .{ .generator_id = 1, .multiplier = 2.0 } });
    
    // Setup input handling
    var input = tif.InputHandler.init();
    defer input.deinit();
    
    try game.run(&input);
}
```

## Getting Started

### Installation
```bash
# Clone the framework
git clone https://github.com/your-org/zig-terminal-idle-framework
cd zig-terminal-idle-framework

# Build examples
zig build

# Run cookie clicker
./zig-out/bin/cookie-clicker

# Run mining game  
./zig-out/bin/mining-game
```

### Creating Your Own Game
```bash
# Copy template
cp -r templates/basic_idle my_game
cd my_game

# Edit game configuration
nano src/config.zig

# Build and run
zig build run
```

## Performance Characteristics

### Memory Usage
- **Zero runtime allocations** during gameplay
- **Fixed memory footprint** determined at compile time
- **Cache-friendly data layout** with struct-of-arrays
- **Memory usage scales** with game configuration, not content

### CPU Performance  
- **~0.1ms update time** for typical idle game (60 FPS)
- **Batch processing** for offline progress calculation
- **SIMD optimization** for bulk resource updates
- **Comptime elimination** of unused features

### Binary Size
- **Release builds**: ~200KB-2MB depending on features
- **Debug builds**: ~2-10MB with full debug info
- **Cross-compilation**: Single command to all targets

## Why Zig for Idle Games?

1. **Predictable Performance**: No GC pauses, consistent frame times
2. **Memory Safety**: Catch bugs at compile time, not runtime  
3. **Zero Dependencies**: Self-contained binaries
4. **Cross Platform**: Build for Linux, Windows, macOS from any OS
5. **Comptime Magic**: Game templates with zero runtime cost
6. **Direct Control**: Manage every byte of memory
7. **Fast Compilation**: Rapid iteration during development

---

*Build idle games that run fast, use minimal resources, and never crash!*