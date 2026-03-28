const std = @import("std");

pub const EntityState = enum {
    normal,
    possessed, // Precisa de porrada (exorcismo)
    glitched,  // Afeta o renderizador (Gremlings)
    unconscious, // Pós-exorcismo, pronto para Gaslight
};

pub const Slayer = struct {
    age: u8 = 42,
    stamina: f32 = 100.0,
    caffeine_level: f32 = 0.0,
    cringe_factor: f32 = 100.0, // Eficácia do Gaslight em millennials
    is_hired_slayer: bool = true,
};

pub const Intern = struct {
    name: []const u8,
    innocence: f32 = 100.0, // Se chegar a 0, Game Over por escândalo
    current_task: []const u8 = "Refactoring Java",
};

pub const PossessionStatus = struct {
    level: f32, // 0.0 a 100.0
    threshold: f32 = 50.0,
    
    pub fn applyHit(self: *PossessionStatus, impact: f32) void {
        self.level -= impact; // Reduz a entidade no corpo
        if (self.level <= 0) {
            // triggerGaslightEvent();
        }
    }
};

pub const Gremlin = struct {
    health: f32 = 100.0,
    state: EntityState = .glitched,
    glitch_power: f32 = 0.5,
};

test "Slayer initialization" {
    const slayer = Slayer{};
    try std.testing.expectEqual(@as(u8, 42), slayer.age);
    try std.testing.expectEqual(@as(f32, 100.0), slayer.stamina);
}
