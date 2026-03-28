const std = @import("std");

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const GremlinBatch = struct {
    positions: []Vec3,
    velocities: []Vec3,
    health: []f32,
    innocence: []f32,
    count: usize,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !GremlinBatch {
        return GremlinBatch{
            .positions = try allocator.alloc(Vec3, capacity),
            .velocities = try allocator.alloc(Vec3, capacity),
            .health = try allocator.alloc(f32, capacity),
            .innocence = try allocator.alloc(f32, capacity),
            .count = 0,
        };
    }

    pub fn deinit(self: *GremlinBatch, allocator: std.mem.Allocator) void {
        allocator.free(self.positions);
        allocator.free(self.velocities);
        allocator.free(self.health);
        allocator.free(self.innocence);
    }

    pub fn updatePhysics(self: *GremlinBatch, dt: f32) void {
        // Optimized loop for cache-friendly access
        for (self.positions, self.velocities) |*p, v| {
            p.x += v.x * dt;
            p.y += v.y * dt;
            p.z += v.z * dt;
        }
    }
};
