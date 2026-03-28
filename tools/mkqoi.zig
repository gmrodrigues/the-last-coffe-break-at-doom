const std = @import("std");

pub fn encode(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u32) ![]u8 {
    const total_pixels = width * height;
    const out_size = 14 + (total_pixels * 5) + 8;
    var out = try allocator.alloc(u8, out_size);
    @memcpy(out[0..4], "qoif");
    out[4] = @intCast((width >> 24) & 0xFF);
    out[5] = @intCast((width >> 16) & 0xFF);
    out[6] = @intCast((width >> 8) & 0xFF);
    out[7] = @intCast(width & 0xFF);
    out[8] = @intCast((height >> 24) & 0xFF);
    out[9] = @intCast((height >> 16) & 0xFF);
    out[10] = @intCast((height >> 8) & 0xFF);
    out[11] = @intCast(height & 0xFF);
    out[12] = 4; out[13] = 0; 
    
    var p: usize = 14;
    for (pixels) |px| {
        out[p] = 0xff;
        out[p+1] = @intCast((px >> 24) & 0xFF);
        out[p+2] = @intCast((px >> 16) & 0xFF);
        out[p+3] = @intCast((px >> 8) & 0xFF);
        out[p+4] = @intCast(px & 0xFF);
        p += 5;
    }
    @memcpy(out[p..p+8], &[_]u8{0,0,0,0,0,0,0,1});
    return out;
}

const PALETTE = blk: {
    var p: [256]u32 = undefined;
    @memset(&p, 0); 
    p['.'] = 0;
    p['#'] = 0x333333FF;
    p['@'] = 0x666666FF;
    p['B'] = 0x0000FFFF;
    p['R'] = 0xFF0000FF;
    p['W'] = 0xFFFFFFFF;
    p['M'] = 0xAAAAAAFF;
    p['Y'] = 0xFFFF00FF;
    break :blk p;
};

fn genTexFile(allocator: std.mem.Allocator, path: []const u8, w: u32, h: u32, str: []const u8) !void {
    var pixels = try allocator.alloc(u32, w * h);
    defer allocator.free(pixels);
    var i: usize = 0;
    for (str) |c| {
        if (c == '\n' or c == '\r' or c == ' ') continue;
        if (i >= w * h) break;
        pixels[i] = PALETTE[c];
        i += 1;
    }
    const qoi_data = try encode(allocator, w, h, pixels);
    defer allocator.free(qoi_data);
    try std.fs.cwd().writeFile(.{ .sub_path = path, .data = qoi_data });
    std.debug.print("{s} generated\n", .{path});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    std.fs.cwd().makeDir("assets") catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };
    
    const tw = 64; const th = 64;
    var wall_pixels = try allocator.alloc(u32, tw * th);
    defer allocator.free(wall_pixels);
    for (0..th) |y| {
        for (0..tw) |x| {
            const brick_x = (x / 16) % 2;
            const brick_y = (y / 16) % 2;
            const is_mortat = (x % 16 <= 1 or y % 16 <= 1);
            if (is_mortat) { wall_pixels[y * tw + x] = 0x222222FF; }
            else if (brick_x == brick_y) { wall_pixels[y * tw + x] = 0x444499FF; }
            else { wall_pixels[y * tw + x] = 0x333377FF; }
        }
    }
    const wall_qoi = try encode(allocator, tw, th, wall_pixels);
    defer allocator.free(wall_qoi);
    try std.fs.cwd().writeFile(.{ .sub_path = "assets/wall.qoi", .data = wall_qoi });
    std.debug.print("assets/wall.qoi generated\n", .{});

    const SERVER_STR = 
    "................" ++
    ".....######....." ++
    "....#@@@@@@#...." ++
    "...#@@@@@@@@#..." ++
    "...#@B@..@B@#..." ++
    "...#@@@@@@@@#..." ++
    "...#@@@@@@@@#..." ++
    "...##########..." ++
    "...#@@@@@@@@#..." ++
    "...#@R@..@B@#..." ++
    "...#@@@@@@@@#..." ++
    "...#@@@@@@@@#..." ++
    "...##########..." ++
    "...#@@@@@@@@#..." ++
    "...#@B@..@B@#..." ++
    "...##########...";
    try genTexFile(allocator, "assets/server.qoi", 16, 16, SERVER_STR);
    
    const WEAPON_STR = 
    "................" ++
    "................" ++
    "................" ++
    "................" ++
    "................" ++
    "......MMMM......" ++
    ".....MMMMMM....." ++
    ".....MMWWMM....." ++
    "....MMMWWMMM...." ++
    "...MMMMMMMMMM..." ++
    "..MMMWWMMWWMMM.." ++
    ".MMMMWWMMWWMMMM." ++
    ".MMMMMMMMMMMMMM." ++
    "MMMMMWWWWWWMMMMM" ++
    "MMMMMMMMMMMMMMMM" ++
    "MMMMMMMMMMMMMMMM";
    try genTexFile(allocator, "assets/weapon.qoi", 16, 16, WEAPON_STR);
    
    const FLASH_STR = 
    ".......YY......." ++
    "......YYYY......" ++
    ".......YY......." ++
    "...Y........Y..." ++
    "..YYY......YYY.." ++
    "...Y........Y..." ++
    "................" ++
    "YY............YY" ++
    "................" ++
    "...Y........Y..." ++
    "..YYY......YYY.." ++
    "...Y........Y..." ++
    ".......YY......." ++
    "......YYYY......" ++
    ".......YY......." ++
    "................";
    try genTexFile(allocator, "assets/flash.qoi", 16, 16, FLASH_STR);
}
