const std = @import("std");
const assets = @import("assets.zig");

pub const SCREEN_WIDTH = 320;
pub const SCREEN_HEIGHT = 200;

pub const Map = struct {
    width: usize,
    height: usize,
    data: []const u8, // 0 = empty, >0 = wall colors
    
    pub fn get(self: Map, x: usize, y: usize) u8 {
        if (x >= self.width or y >= self.height) return 1; // map boundary is wall
        return self.data[y * self.width + x];
    }
};

pub const Camera = struct {
    x: f32,
    y: f32,
    dir_x: f32,
    dir_y: f32,
    plane_x: f32,
    plane_y: f32,
};

pub const Sprite = struct {
    x: f32,
    y: f32,
    textures: [8]*const assets.Texture,
};

pub const Renderer = struct {
    map: Map,
    buffer: [SCREEN_WIDTH * SCREEN_HEIGHT]u32, // RGBA pixels
    z_buffer: [SCREEN_WIDTH]f32,
    wall_texture: *const assets.Texture,

    pub fn renderFrame(self: *@This(), camera: Camera, sprites: []const Sprite) void {
        // Clear buffer
        @memset(&self.buffer, 0x000000FF); // Black background

        // 1. FLOOR / CEILING (Optional)
        
        // 2. WALL CASTING
        for (0..SCREEN_WIDTH) |x| {
            const camera_x = 2.0 * @as(f32, @floatFromInt(x)) / @as(f32, SCREEN_WIDTH) - 1.0; 
            const ray_dir_x = camera.dir_x + camera.plane_x * camera_x;
            const ray_dir_y = camera.dir_y + camera.plane_y * camera_x;

            var map_x: i32 = @intFromFloat(camera.x);
            var map_y: i32 = @intFromFloat(camera.y);

            var side_dist_x: f32 = 0;
            var side_dist_y: f32 = 0;

            const delta_dist_x = if (ray_dir_x == 0) 1e30 else @abs(1.0 / ray_dir_x);
            const delta_dist_y = if (ray_dir_y == 0) 1e30 else @abs(1.0 / ray_dir_y);
            var perp_wall_dist: f32 = 0;

            var step_x: i32 = 0;
            var step_y: i32 = 0;

            var hit: bool = false; 
            var side: u8 = 0; 

            if (ray_dir_x < 0) {
                step_x = -1;
                side_dist_x = (camera.x - @as(f32, @floatFromInt(map_x))) * delta_dist_x;
            } else {
                step_x = 1;
                side_dist_x = (@as(f32, @floatFromInt(map_x)) + 1.0 - camera.x) * delta_dist_x;
            }
            if (ray_dir_y < 0) {
                step_y = -1;
                side_dist_y = (camera.y - @as(f32, @floatFromInt(map_y))) * delta_dist_y;
            } else {
                step_y = 1;
                side_dist_y = (@as(f32, @floatFromInt(map_y)) + 1.0 - camera.y) * delta_dist_y;
            }

            var iter: usize = 0;
            while (!hit and iter < 100) : (iter += 1) { 
                if (side_dist_x < side_dist_y) {
                    side_dist_x += delta_dist_x;
                    map_x += step_x;
                    side = 0;
                } else {
                    side_dist_y += delta_dist_y;
                    map_y += step_y;
                    side = 1;
                }
                if (map_x >= 0 and map_x < self.map.width and map_y >= 0 and map_y < self.map.height) {
                    if (self.map.get(@intCast(map_x), @intCast(map_y)) > 0) {
                        hit = true;
                    }
                }
            }

            if (!hit) continue;

            if (side == 0) {
                perp_wall_dist = (side_dist_x - delta_dist_x);
            } else {
                perp_wall_dist = (side_dist_y - delta_dist_y);
            }

            self.z_buffer[x] = perp_wall_dist;

            var line_height: i32 = 0;
            if (perp_wall_dist > 0) {
                line_height = @as(i32, @intFromFloat(@as(f32, SCREEN_HEIGHT) / perp_wall_dist));
            } else {
                line_height = SCREEN_HEIGHT;
            }

            var draw_start: i32 = -@divTrunc(line_height, 2) + @as(i32, SCREEN_HEIGHT) / 2;
            if (draw_start < 0) draw_start = 0;
            var draw_end: i32 = @divTrunc(line_height, 2) + @as(i32, SCREEN_HEIGHT) / 2;
            if (draw_end >= SCREEN_HEIGHT) draw_end = SCREEN_HEIGHT - 1;

            var wall_x: f32 = 0;
            if (side == 0) {
                wall_x = camera.y + perp_wall_dist * ray_dir_y;
            } else {
                wall_x = camera.x + perp_wall_dist * ray_dir_x;
            }
            wall_x -= @floatFromInt(@as(i32, @intFromFloat(wall_x)));
            
            const tex_w = self.wall_texture.width;
            const tex_h = self.wall_texture.height;

            var tex_x: i32 = @intFromFloat(wall_x * @as(f32, @floatFromInt(tex_w)));
            if (side == 0 and ray_dir_x > 0) tex_x = @as(i32, @intCast(tex_w)) - tex_x - 1;
            if (side == 1 and ray_dir_y < 0) tex_x = @as(i32, @intCast(tex_w)) - tex_x - 1;

            const step = @as(f32, @floatFromInt(tex_h)) / @as(f32, @floatFromInt(line_height));
            var tex_pos = (@as(f32, @floatFromInt(draw_start)) - @as(f32, @floatFromInt(SCREEN_HEIGHT)) / 2.0 + @as(f32, @floatFromInt(line_height)) / 2.0) * step;

            var y: usize = @intCast(draw_start);
            const end_y: usize = @intCast(draw_end);
            while (y < end_y) : (y += 1) {
                var tex_y: i32 = @intFromFloat(tex_pos);
                tex_y = @max(0, @min(@as(i32, @intCast(tex_h)) - 1, tex_y));
                tex_pos += step;
                
                const color = self.wall_texture.get(@intCast(tex_x), @intCast(tex_y));
                const final_color = if (side == 1) 
                    (color & 0xFEFEFEFE) >> 1 
                else color;
                
                self.buffer[y * SCREEN_WIDTH + x] = final_color;
            }
        }
        
        // 3. SPRITE CASTING
        for (sprites) |sprite| {
            const sprite_x = sprite.x - camera.x;
            const sprite_y = sprite.y - camera.y;

            const inv_det = 1.0 / (camera.plane_x * camera.dir_y - camera.dir_x * camera.plane_y);
            
            const transform_x = inv_det * (camera.dir_y * sprite_x - camera.dir_x * sprite_y);
            const transform_y = inv_det * (-camera.plane_y * sprite_x + camera.plane_x * sprite_y); 
            
            if (transform_y <= 0) continue; 
            
            const sprite_screen_x = @as(i32, @intFromFloat((@as(f32, SCREEN_WIDTH) / 2.0) * (1.0 + transform_x / transform_y)));
            
            const sprite_height = @as(i32, @intFromFloat(@as(f32, SCREEN_HEIGHT) / transform_y));
            var draw_start_y = -@divTrunc(sprite_height, 2) + @as(i32, SCREEN_HEIGHT) / 2;
            if (draw_start_y < 0) draw_start_y = 0;
            var draw_end_y = @divTrunc(sprite_height, 2) + @as(i32, SCREEN_HEIGHT) / 2;
            if (draw_end_y >= SCREEN_HEIGHT) draw_end_y = SCREEN_HEIGHT - 1;
            
            const sprite_width = @as(i32, @intFromFloat(@as(f32, SCREEN_HEIGHT) / transform_y));
            var draw_start_x = -@divTrunc(sprite_width, 2) + sprite_screen_x;
            if (draw_start_x < 0) draw_start_x = 0;
            var draw_end_x = @divTrunc(sprite_width, 2) + sprite_screen_x;
            if (draw_end_x >= SCREEN_WIDTH) draw_end_x = SCREEN_WIDTH - 1;
            
            // --- 8-DIRECTION ANGLE SELECTION ---
            // The texture depends on the relative angle between the player's view and the object
            const world_angle = std.math.atan2(sprite_y, sprite_x);
            const player_angle = std.math.atan2(camera.dir_y, camera.dir_x);
            var relative_angle = world_angle - player_angle + std.math.pi + std.math.pi/8.0;
            while (relative_angle < 0) relative_angle += 2 * std.math.pi;
            while (relative_angle >= 2 * std.math.pi) relative_angle -= 2 * std.math.pi;
            
            const tex_index = @as(usize, @intFromFloat(relative_angle / (std.math.pi / 4.0))) % 8;
            const texture = sprite.textures[tex_index];

            var stripe = draw_start_x;
            while (stripe < draw_end_x) : (stripe += 1) {
                const u = @as(usize, @intCast(stripe));
                if (u >= SCREEN_WIDTH) continue;

                if (transform_y < self.z_buffer[u]) {
                    const tex_x_f = (@as(f32, @floatFromInt(stripe)) - (@as(f32, @floatFromInt(sprite_screen_x)) - @as(f32, @floatFromInt(sprite_width)) / 2.0)) * @as(f32, @floatFromInt(texture.width)) / @as(f32, @floatFromInt(sprite_width));
                    const tex_x: i32 = @intFromFloat(tex_x_f);
                    
                    if (tex_x < 0 or tex_x >= texture.width) continue;

                    var y: i32 = draw_start_y;
                    while (y < draw_end_y) : (y += 1) {
                        const tex_y_f = (@as(f32, @floatFromInt(y)) - (@as(f32, @floatFromInt(SCREEN_HEIGHT)) / 2.0 - @as(f32, @floatFromInt(sprite_height)) / 2.0)) * @as(f32, @floatFromInt(texture.height)) / @as(f32, @floatFromInt(sprite_height));
                        const tex_y: i32 = @intFromFloat(tex_y_f);
                        
                        if (tex_y < 0 or tex_y >= texture.height) continue;
                        
                        const color = texture.get(@intCast(tex_x), @intCast(tex_y));
                        if (color != 0) { 
                            self.buffer[@as(usize, @intCast(y)) * SCREEN_WIDTH + u] = color;
                        }
                    }
                }
            }
        }
    }
    
    // 4. UI Rendering Overlay
    pub fn renderWeaponOverlay(self: *@This(), texture: *const assets.Texture, flash_tex: *const assets.Texture, is_firing: bool) void {
        const wep_w: usize = 120; // upscaled size of the 16x16 sprite on the 320x200 canvas
        const wep_h: usize = 120;
        const start_x: usize = SCREEN_WIDTH / 2 - wep_w / 2;
        // Move the weapon down a bit during the firing recoil animation
        const recoil_offset: usize = if (is_firing) 15 else 0;
        const start_y: usize = SCREEN_HEIGHT - wep_h / 2 + recoil_offset; 
        
        for (0..wep_w) |x| {
            for (0..wep_h) |y| {
                const tex_x = (x * texture.width) / wep_w;
                const tex_y = (y * texture.height) / wep_h;
                
                const color = texture.get(tex_x, tex_y);
                if (color != 0) {
                    const buf_x = start_x + x;
                    const buf_y = start_y + y;
                    if (buf_x < SCREEN_WIDTH and buf_y < SCREEN_HEIGHT) {
                        self.buffer[buf_y * SCREEN_WIDTH + buf_x] = color;
                    }
                }
            }
        }
        
        // Draw the flash layer if firing
        if (is_firing) {
            const flash_y: usize = start_y - 20;
            const flash_w = wep_w;
            const flash_h = wep_h;
            for (0..flash_w) |x| {
                for (0..flash_h) |y| {
                    const tex_x = (x * flash_tex.width) / flash_w;
                    const tex_y = (y * flash_tex.height) / flash_h;
                    const color = flash_tex.get(tex_x, tex_y);
                    if (color != 0) {
                        const buf_x = start_x + x;
                        const buf_y = flash_y + y;
                        if (buf_x < SCREEN_WIDTH and buf_y < SCREEN_HEIGHT) {
                            self.buffer[buf_y * SCREEN_WIDTH + buf_x] = color;
                        }
                    }
                }
            }
        }
    }
};

test "Map boundary and collision" {
    const map_data = [_]u8{
        1, 1, 1,
        1, 0, 1,
        1, 1, 1,
    };
    const map = Map{
        .width = 3,
        .height = 3,
        .data = &map_data,
    };

    try std.testing.expectEqual(@as(u8, 1), map.get(0, 0));
    try std.testing.expectEqual(@as(u8, 0), map.get(1, 1));
    try std.testing.expectEqual(@as(u8, 1), map.get(3, 3)); // boundary
}

test "Basic Raycasting Render" {
    // Mock texture pixels
    var pixels = [_]u32{0xFFFFFFFF} ** (16 * 16);
    
    const mock_qoi = assets.qoi.QoiImage{
        .width = 16,
        .height = 16,
        .pixels = &pixels,
        .allocator = std.testing.allocator,
    };
    
    const tex = assets.Texture{
        .width = 16,
        .height = 16,
        .pixels = &pixels,
        .qoi_image = mock_qoi,
    };

    const map_data = [_]u8{
        1, 1, 1,
        1, 0, 1,
        1, 1, 1,
    };
    const map = Map{
        .width = 3,
        .height = 3,
        .data = &map_data,
    };

    var renderer = Renderer{
        .map = map,
        .buffer = undefined,
        .z_buffer = undefined,
        .wall_texture = &tex,
    };

    const camera = Camera{
        .x = 1.5,
        .y = 1.5,
        .dir_x = 1.0,
        .dir_y = 0.0,
        .plane_x = 0.0,
        .plane_y = 0.66,
    };

    const sprites = [_]Sprite{};
    renderer.renderFrame(camera, &sprites);

    // Verify buffer is no longer all black (at least some wall should be rendered)
    var hit_wall = false;
    for (renderer.buffer) |pixel| {
        if (pixel != 0x000000FF) {
            hit_wall = true;
            break;
        }
    }
    try std.testing.expect(hit_wall);
}
