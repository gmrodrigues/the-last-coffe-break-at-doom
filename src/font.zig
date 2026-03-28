// 5×7 bitmap font — uppercase A-Z, 0-9 and basic punctuation.
// Each char = 7 rows × 5 bits (MSB = leftmost pixel).
// Uses SDL2 passed in as a comptime namespace to avoid dual-cimport conflicts.

const FONT_W = 5;
const FONT_H = 7;

const font_data: [128][FONT_H]u8 = blk: {
    var d: [128][FONT_H]u8 = [_][FONT_H]u8{[_]u8{0} ** FONT_H} ** 128;

    d['0'] = .{ 0b01110, 0b10001, 0b10011, 0b10101, 0b11001, 0b10001, 0b01110 };
    d['1'] = .{ 0b00100, 0b01100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110 };
    d['2'] = .{ 0b01110, 0b10001, 0b00001, 0b00110, 0b01000, 0b10000, 0b11111 };
    d['3'] = .{ 0b11111, 0b00010, 0b00100, 0b00110, 0b00001, 0b10001, 0b01110 };
    d['4'] = .{ 0b00010, 0b00110, 0b01010, 0b10010, 0b11111, 0b00010, 0b00010 };
    d['5'] = .{ 0b11111, 0b10000, 0b11110, 0b00001, 0b00001, 0b10001, 0b01110 };
    d['6'] = .{ 0b01110, 0b10000, 0b10000, 0b11110, 0b10001, 0b10001, 0b01110 };
    d['7'] = .{ 0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b01000, 0b01000 };
    d['8'] = .{ 0b01110, 0b10001, 0b10001, 0b01110, 0b10001, 0b10001, 0b01110 };
    d['9'] = .{ 0b01110, 0b10001, 0b10001, 0b01111, 0b00001, 0b00001, 0b01110 };

    d['A'] = .{ 0b01110, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001 };
    d['B'] = .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10001, 0b10001, 0b11110 };
    d['C'] = .{ 0b01110, 0b10001, 0b10000, 0b10000, 0b10000, 0b10001, 0b01110 };
    d['D'] = .{ 0b11110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b11110 };
    d['E'] = .{ 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b11111 };
    d['F'] = .{ 0b11111, 0b10000, 0b10000, 0b11110, 0b10000, 0b10000, 0b10000 };
    d['G'] = .{ 0b01110, 0b10001, 0b10000, 0b10111, 0b10001, 0b10001, 0b01111 };
    d['H'] = .{ 0b10001, 0b10001, 0b10001, 0b11111, 0b10001, 0b10001, 0b10001 };
    d['I'] = .{ 0b01110, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b01110 };
    d['J'] = .{ 0b00111, 0b00010, 0b00010, 0b00010, 0b00010, 0b10010, 0b01100 };
    d['K'] = .{ 0b10001, 0b10010, 0b10100, 0b11000, 0b10100, 0b10010, 0b10001 };
    d['L'] = .{ 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b10000, 0b11111 };
    d['M'] = .{ 0b10001, 0b11011, 0b10101, 0b10001, 0b10001, 0b10001, 0b10001 };
    d['N'] = .{ 0b10001, 0b11001, 0b10101, 0b10011, 0b10001, 0b10001, 0b10001 };
    d['O'] = .{ 0b01110, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110 };
    d['P'] = .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10000, 0b10000, 0b10000 };
    d['Q'] = .{ 0b01110, 0b10001, 0b10001, 0b10001, 0b10101, 0b10010, 0b01101 };
    d['R'] = .{ 0b11110, 0b10001, 0b10001, 0b11110, 0b10100, 0b10010, 0b10001 };
    d['S'] = .{ 0b01111, 0b10000, 0b10000, 0b01110, 0b00001, 0b00001, 0b11110 };
    d['T'] = .{ 0b11111, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100, 0b00100 };
    d['U'] = .{ 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01110 };
    d['V'] = .{ 0b10001, 0b10001, 0b10001, 0b10001, 0b10001, 0b01010, 0b00100 };
    d['W'] = .{ 0b10001, 0b10001, 0b10001, 0b10101, 0b10101, 0b11011, 0b10001 };
    d['X'] = .{ 0b10001, 0b10001, 0b01010, 0b00100, 0b01010, 0b10001, 0b10001 };
    d['Y'] = .{ 0b10001, 0b10001, 0b01010, 0b00100, 0b00100, 0b00100, 0b00100 };
    d['Z'] = .{ 0b11111, 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b11111 };

    d['/'] = .{ 0b00001, 0b00010, 0b00100, 0b01000, 0b10000, 0b00000, 0b00000 };
    d['+'] = .{ 0b00000, 0b00100, 0b00100, 0b11111, 0b00100, 0b00100, 0b00000 };
    d['-'] = .{ 0b00000, 0b00000, 0b00000, 0b11111, 0b00000, 0b00000, 0b00000 };
    d[':'] = .{ 0b00000, 0b00100, 0b00000, 0b00000, 0b00000, 0b00100, 0b00000 };
    d[' '] = .{ 0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b00000 };
    d['.'] = .{ 0b00000, 0b00000, 0b00000, 0b00000, 0b00000, 0b01100, 0b01100 };

    break :blk d;
};

/// Renderer is passed as anyopaque to avoid dual-cimport type conflict.
/// The SDL namespace from the caller is used via comptime `sdl` parameter.
pub fn drawChar(comptime sdl: type, rnd: *sdl.SDL_Renderer, ch: u8, x: i32, y: i32, scale: i32) void {
    if (ch >= 128) return;
    const rows = font_data[ch];
    for (rows, 0..) |row, ry| {
        var bit: u3 = 4;
        for (0..FONT_W) |bx| {
            if ((row >> bit) & 1 == 1) {
                const px = x + @as(i32, @intCast(bx)) * scale;
                const py = y + @as(i32, @intCast(ry)) * scale;
                _ = sdl.SDL_RenderFillRect(rnd, &sdl.SDL_Rect{ .x = px, .y = py, .w = scale, .h = scale });
            }
            if (bit > 0) bit -= 1 else bit = 0;
        }
    }
}

pub fn drawText(comptime sdl: type, rnd: *sdl.SDL_Renderer, text: []const u8, x: i32, y: i32, scale: i32) i32 {
    var cx = x;
    for (text) |ch| {
        drawChar(sdl, rnd, ch, cx, y, scale);
        cx += (FONT_W + 1) * scale;
    }
    return cx;
}

pub fn drawTextCentered(comptime sdl: type, rnd: *sdl.SDL_Renderer, text: []const u8, r: sdl.SDL_Rect, scale: i32) void {
    const tw = @as(i32, @intCast(text.len)) * (FONT_W + 1) * scale;
    const th = FONT_H * scale;
    const x = r.x + @divTrunc(r.w - tw, 2);
    const y = r.y + @divTrunc(r.h - th, 2);
    _ = drawText(sdl, rnd, text, x, y, scale);
}
