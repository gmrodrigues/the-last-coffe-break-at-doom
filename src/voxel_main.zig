const std = @import("std");
const qoi = @import("qoi.zig");
const c = @cImport({ @cInclude("SDL2/SDL.h"); });

const GRID = 16;
const BUFFER_W = 64;
const BUFFER_H = 64;
const CELL_SIZE = 512 / GRID; // 32 px per slot on canvas

const PALETTE = [_]u32{
    0x00000000, 0x333333FF, 0x666666FF, 0xAAAAAAFF, 
    0xBB2222FF, 0x22BB22FF, 0x2222BBFF, 0xCCAA22FF,
};

fn adjustColor(color: u32, amt: i32) u32 {
    var r: i32 = @intCast((color >> 24) & 0xFF);
    var g: i32 = @intCast((color >> 16) & 0xFF);
    var b: i32 = @intCast((color >> 8) & 0xFF);
    r = @max(0, @min(255, r + amt)); g = @max(0, @min(255, g + amt)); b = @max(0, @min(255, b + amt));
    return (@as(u32, @intCast(r)) << 24) | (@as(u32, @intCast(g)) << 16) | (@as(u32, @intCast(b)) << 8) | 0xFF;
}

fn putPixel(buffer: []u32, x: i32, y: i32, color: u32) void {
    if (x >= 0 and x < BUFFER_W and y >= 0 and y < BUFFER_H) {
        if (color & 0xFF > 0) buffer[@as(usize, @intCast(y * BUFFER_W + x))] = color;
    }
}

fn drawCubeStr(buffer: []u32, px: i32, py: i32, c_hex: u32) void {
    const c1 = adjustColor(c_hex, 20); const c2 = c_hex; const c3 = adjustColor(c_hex, -40);
    for (0..4) |dy| {
        for (0..2) |dx| {
            putPixel(buffer, px - 2 + @as(i32, @intCast(dx)), py - 2 + @as(i32, @intCast(dy)), c2);
            putPixel(buffer, px + @as(i32, @intCast(dx)), py - 2 + @as(i32, @intCast(dy)), c3);
        }
    }
    putPixel(buffer, px - 1, py - 3, c1); putPixel(buffer, px, py - 3, c1);
    putPixel(buffer, px - 1, py - 4, c1); putPixel(buffer, px, py - 4, c1);
}

const RenderVoxel = struct { x: i32, y: i32, depth: f32, color: u32 };
fn renderFrame(buffer: []u32, grid: *const [GRID][GRID][GRID]u8, cam_angle: u32) !void {
    @memset(buffer, 0); 
    var vx_array = try std.heap.page_allocator.alloc(RenderVoxel, GRID * GRID * GRID + 1);
    defer std.heap.page_allocator.free(vx_array);
    var vx_len: usize = 0;
    const angle_rad = @as(f32, @floatFromInt(cam_angle)) * std.math.pi / 4.0;
    const cos_a = @cos(angle_rad); const sin_a = @sin(angle_rad);

    for (0..GRID) |z| {
        for (0..GRID) |y| {
            for (0..GRID) |x| {
                const color_idx = grid[z][y][x];
                if (color_idx > 0) {
                    const cx = @as(f32, @floatFromInt(x)) - GRID / 2.0;
                    const cy = @as(f32, @floatFromInt(y)) - GRID / 2.0;
                    const nx = cx * cos_a - cy * sin_a;
                    const ny = cx * sin_a + cy * cos_a;
                    const px = 32 + @as(i32, @intFromFloat(nx * 3.0));
                    const py = 48 + @as(i32, @intFromFloat(ny * 1.5)) - @as(i32, @intFromFloat(@as(f32, @floatFromInt(z)) * 3.0));
                    const depth = ny * 10.0 - @as(f32, @floatFromInt(z));
                    vx_array[vx_len] = .{ .x = px, .y = py, .depth = depth, .color = PALETTE[color_idx] };
                    vx_len += 1;
                }
            }
        }
    }
    const sort_fn = struct { fn cmp(_: void, a: RenderVoxel, b: RenderVoxel) bool { return a.depth > b.depth; } }.cmp;
    std.mem.sort(RenderVoxel, vx_array[0..vx_len], {}, sort_fn);
    for (vx_array[0..vx_len]) |v| drawCubeStr(buffer, v.x, v.y, v.color);
}

// ------------------------------
// IMMEDIATE MODE GUI FRAMEWORK
// ------------------------------
const Rect = c.SDL_Rect;
fn inRect(r: Rect, x: i32, y: i32) bool { return x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h; }
fn guiBtnColor(renderer: *c.SDL_Renderer, r: Rect, active: bool, color: u32, mx: i32, my: i32, mclick: bool) bool {
    const hover = inRect(r, mx, my);
    if (active) {
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        const br = Rect{ .x = r.x - 3, .y = r.y - 3, .w = r.w + 6, .h = r.h + 6 }; _ = c.SDL_RenderFillRect(renderer, &br);
    } else if (hover) {
        _ = c.SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
        const br = Rect{ .x = r.x - 2, .y = r.y - 2, .w = r.w + 4, .h = r.h + 4 }; _ = c.SDL_RenderFillRect(renderer, &br);
    }
    _ = c.SDL_SetRenderDrawColor(renderer, @intCast((color >> 24) & 0xFF), @intCast((color >> 16) & 0xFF), @intCast((color >> 8) & 0xFF), 255);
    _ = c.SDL_RenderFillRect(renderer, &r);
    return hover and mclick;
}
fn guiSlider(renderer: *c.SDL_Renderer, r: Rect, min: i32, max: i32, val: *i32, mx: i32, my: i32, mdown: bool) void {
    const hover = inRect(r, mx, my);
    _ = c.SDL_SetRenderDrawColor(renderer, 30, 30, 30, 255); _ = c.SDL_RenderFillRect(renderer, &r);
    if (hover and mdown) {
        const ratio = @as(f32, @floatFromInt(mx - r.x)) / @as(f32, @floatFromInt(r.w));
        const v = @as(i32, @intFromFloat(ratio * @as(f32, @floatFromInt(max - min)))) + min;
        val.* = @max(min, @min(max, v));
    }
    const safe_max = if (max == min) 1 else max - min;
    const ratio2 = @as(f32, @floatFromInt(val.* - min)) / @as(f32, @floatFromInt(safe_max));
    const hx = r.x + @as(i32, @intFromFloat(ratio2 * @as(f32, @floatFromInt(r.w)))) - 5;
    const hrect = Rect{ .x = hx, .y = r.y - 2, .w = 10, .h = r.h + 4 };
    _ = c.SDL_SetRenderDrawColor(renderer, 180, 180, 180, 255); _ = c.SDL_RenderFillRect(renderer, &hrect);
}

// ------------------------------
// GEOMETRY / TOOLS Algorithmns
// ------------------------------
const Plane = enum { XY, XZ, YZ };
const Tool = enum { Pencil, Eraser, Fill, Line, Circle, Select, Extrude };

fn applyFloodFill(grid: *[GRID][GRID][GRID]u8, px: i32, py: i32, pz: i32, plane: Plane, target_color: u8, replace_color: u8) void {
    if (px < 0 or py < 0 or px >= GRID or py >= GRID) return;
    var current: u8 = 0;
    switch (plane) {
        .XY => current = grid[@intCast(pz)][@intCast(py)][@intCast(px)],
        .XZ => current = grid[@intCast(py)][@intCast(pz)][@intCast(px)],
        .YZ => current = grid[@intCast(py)][@intCast(px)][@intCast(pz)],
    }
    if (current != target_color or current == replace_color) return;
    switch (plane) {
        .XY => grid[@intCast(pz)][@intCast(py)][@intCast(px)] = replace_color,
        .XZ => grid[@intCast(py)][@intCast(pz)][@intCast(px)] = replace_color,
        .YZ => grid[@intCast(py)][@intCast(px)][@intCast(pz)] = replace_color,
    }
    applyFloodFill(grid, px + 1, py, pz, plane, target_color, replace_color);
    applyFloodFill(grid, px - 1, py, pz, plane, target_color, replace_color);
    applyFloodFill(grid, px, py + 1, pz, plane, target_color, replace_color);
    applyFloodFill(grid, px, py - 1, pz, plane, target_color, replace_color);
}

fn drawLine(grid: *[GRID][GRID][GRID]u8, x0: i32, y0: i32, x1: i32, y1: i32, pz: i32, plane: Plane, color: u8) void {
    var cx = x0; var cy = y0;
    const dx: i32 = @intCast(@abs(x1 - x0));
    const dy: i32 = -@as(i32, @intCast(@abs(y1 - y0)));
    const sx: i32 = if (x0 < x1) 1 else -1;
    const sy: i32 = if (y0 < y1) 1 else -1;
    var err: i32 = dx + dy;
    while (true) {
        if (cx >= 0 and cy >= 0 and cx < GRID and cy < GRID) {
            switch (plane) {
                .XY => grid[@intCast(pz)][@intCast(cy)][@intCast(cx)] = color,
                .XZ => grid[@intCast(cy)][@intCast(pz)][@intCast(cx)] = color,
                .YZ => grid[@intCast(cy)][@intCast(cx)][@intCast(pz)] = color,
            }
        }
        if (cx == x1 and cy == y1) break;
        const e2 = 2 * err;
        if (e2 >= dy) { err += dy; cx += sx; }
        if (e2 <= dx) { err += dx; cy += sy; }
    }
}

fn drawCircle(grid: *[GRID][GRID][GRID]u8, xc: i32, yc: i32, r_init: i32, pz: i32, plane: Plane, color: u8) void {
    var r = r_init; var x: i32 = -r; var y: i32 = 0; var err: i32 = 2 - 2 * r;
    while (x < 0) {
        const pts = [_][2]i32{ .{xc - x, yc + y}, .{xc - y, yc - x}, .{xc + x, yc - y}, .{xc + y, yc + x} };
        for (pts) |pt| {
            if (pt[0] >= 0 and pt[0] < GRID and pt[1] >= 0 and pt[1] < GRID) {
                switch (plane) {
                    .XY => grid[@intCast(pz)][@intCast(pt[1])][@intCast(pt[0])] = color,
                    .XZ => grid[@intCast(pt[1])][@intCast(pz)][@intCast(pt[0])] = color,
                    .YZ => grid[@intCast(pt[1])][@intCast(pt[0])][@intCast(pz)] = color,
                }
            }
        }
        r = err;
        if (r <= y) { y += 1; err += y * 2 + 1; }
        if (r > x or err > y) { x += 1; err += x * 2 + 1; }
    }
}

fn exportSprites(allocator: std.mem.Allocator, grid: *const [GRID][GRID][GRID]u8) !void {
    var buffer: [BUFFER_W * BUFFER_H]u32 = undefined;
    for (0..8) |a| {
        try renderFrame(&buffer, grid, @intCast(a));
        var name_buf: [64]u8 = undefined;
        const name = try std.fmt.bufPrint(&name_buf, "assets/voxel_{}.qoi", .{a});
        const qoi_data = try qoi.encode(allocator, BUFFER_W, BUFFER_H, &buffer);
        defer allocator.free(qoi_data);
        try std.fs.cwd().writeFile(.{ .sub_path = name, .data = qoi_data });
        std.debug.print("-> Exported: {s}\n", .{name});
    }
}

const CANVAS_RECT = Rect{ .x = 50, .y = 50, .w = 512, .h = 512 };

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) return error.SDLInitFailed;
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("D.O.O.M. Voxel Forge Professional", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 1280, 720, c.SDL_WINDOW_RESIZABLE);
    defer c.SDL_DestroyWindow(window);
    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse return error.SDLRendererFailed;
    defer c.SDL_DestroyRenderer(renderer);

    const prev_tex = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_RGBA8888, c.SDL_TEXTUREACCESS_STREAMING, BUFFER_W, BUFFER_H);
    _ = c.SDL_SetTextureBlendMode(prev_tex, c.SDL_BLENDMODE_BLEND);

    var grid: [GRID][GRID][GRID]u8 = undefined;
    @memset(&grid, [_][GRID]u8{[_]u8{0} ** GRID} ** GRID); 
    var buffer: [BUFFER_W * BUFFER_H]u32 = undefined;
    var quit: bool = false;
    var event: c.SDL_Event = undefined;

    // STATE
    var active_color: u8 = 1;
    var active_tool: Tool = .Pencil;
    var active_plane: Plane = .XY;
    var active_depth: i32 = GRID / 2;
    var cam_angle: i32 = 0;
    
    var m_down = false; var m_click = false; var m_up = false;
    var drag_start_x: i32 = -1; var drag_start_y: i32 = -1;
    var sel_active: bool = false;
    var sel_x0: i32 = 0; var sel_y0: i32 = 0;
    var sel_x1: i32 = 0; var sel_y1: i32 = 0;

    while (!quit) {
        m_click = false; m_up = false;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => quit = true,
                c.SDL_KEYDOWN => {
                    if (event.key.keysym.sym == c.SDLK_p) exportSprites(std.heap.page_allocator, &grid) catch {};
                },
                c.SDL_MOUSEBUTTONDOWN => if (event.button.button == c.SDL_BUTTON_LEFT) { m_down = true; m_click = true; },
                c.SDL_MOUSEBUTTONUP => if (event.button.button == c.SDL_BUTTON_LEFT) { m_down = false; m_up = true; },
                else => {}
            }
        }
        var mx: i32 = 0; var my: i32 = 0;
        _ = c.SDL_GetMouseState(&mx, &my);

        _ = c.SDL_SetRenderDrawColor(renderer, 45, 55, 65, 255);
        _ = c.SDL_RenderClear(renderer);

        // 1. Draw 2D Canvas
        _ = c.SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255);
        _ = c.SDL_RenderFillRect(renderer, &CANVAS_RECT);
        for (0..GRID) |i| {
            for (0..GRID) |j| {
                var color_idx: u8 = 0;
                switch (active_plane) {
                    .XY => color_idx = grid[@intCast(active_depth)][j][i],
                    .XZ => color_idx = grid[j][@intCast(active_depth)][i], 
                    .YZ => color_idx = grid[j][i][@intCast(active_depth)], 
                }
                if (color_idx > 0) {
                    const clr = PALETTE[color_idx];
                    _ = c.SDL_SetRenderDrawColor(renderer, @intCast((clr >> 24) & 0xFF), @intCast((clr >> 16) & 0xFF), @intCast((clr >> 8) & 0xFF), 255);
                    const cx = CANVAS_RECT.x + @as(i32, @intCast(i)) * CELL_SIZE;
                    const cy = CANVAS_RECT.y + @as(i32, @intCast(j)) * CELL_SIZE;
                    const c_rect = Rect{ .x = cx, .y = cy, .w = CELL_SIZE - 1, .h = CELL_SIZE - 1 };
                    _ = c.SDL_RenderFillRect(renderer, &c_rect);
                }
            }
        }

        // TOOL EXECUTION LOGIC
        if (m_click and inRect(CANVAS_RECT, mx, my)) {
            drag_start_x = @divTrunc(mx - CANVAS_RECT.x, CELL_SIZE);
            drag_start_y = @divTrunc(my - CANVAS_RECT.y, CELL_SIZE);
            
            if (active_tool == .Fill) {
                if (drag_start_x >= 0 and drag_start_x < GRID and drag_start_y >= 0 and drag_start_y < GRID) {
                    var target: u8 = 0;
                    switch (active_plane) {
                        .XY => target = grid[@intCast(active_depth)][@intCast(drag_start_y)][@intCast(drag_start_x)],
                        .XZ => target = grid[@intCast(drag_start_y)][@intCast(active_depth)][@intCast(drag_start_x)],
                        .YZ => target = grid[@intCast(drag_start_y)][@intCast(drag_start_x)][@intCast(active_depth)],
                    }
                    applyFloodFill(&grid, drag_start_x, drag_start_y, active_depth, active_plane, target, active_color);
                }
            }
            if (active_tool == .Extrude and sel_active) {
                const min_x = @max(0, @min(sel_x0, sel_x1)); const max_x = @min(GRID-1, @max(sel_x0, sel_x1));
                const min_y = @max(0, @min(sel_y0, sel_y1)); const max_y = @min(GRID-1, @max(sel_y0, sel_y1));
                const next_depth = active_depth + 1;
                if (next_depth < GRID) {
                    for (@intCast(min_x)..@as(usize, @intCast(max_x+1))) |x| {
                        for (@intCast(min_y)..@as(usize, @intCast(max_y+1))) |y| {
                            switch (active_plane) {
                                .XY => grid[@intCast(next_depth)][y][x] = grid[@intCast(active_depth)][y][x],
                                .XZ => grid[y][@intCast(next_depth)][x] = grid[@intCast(active_depth)][y][x],
                                .YZ => grid[y][x][@intCast(next_depth)] = grid[@intCast(active_depth)][y][x],
                            }
                        }
                    }
                    active_depth = next_depth;
                }
            }
        }
        
        if (m_down and active_tool == .Select and inRect(CANVAS_RECT, mx, my)) {
            sel_x0 = drag_start_x;
            sel_y0 = drag_start_y;
            sel_x1 = @divTrunc(mx - CANVAS_RECT.x, CELL_SIZE);
            sel_y1 = @divTrunc(my - CANVAS_RECT.y, CELL_SIZE);
            sel_active = true;
        }

        if (m_up and (active_tool == .Line or active_tool == .Circle)) {
            const up_x = @divTrunc(mx - CANVAS_RECT.x, CELL_SIZE);
            const up_y = @divTrunc(my - CANVAS_RECT.y, CELL_SIZE);
            if (active_tool == .Line) {
                drawLine(&grid, drag_start_x, drag_start_y, up_x, up_y, active_depth, active_plane, active_color);
            } else if (active_tool == .Circle) {
                const dx = up_x - drag_start_x;
                const dy = up_y - drag_start_y;
                const r = @as(i32, @intFromFloat(@sqrt(@as(f32, @floatFromInt(dx*dx + dy*dy)))));
                drawCircle(&grid, drag_start_x, drag_start_y, r, active_depth, active_plane, active_color);
            }
        }

        if (inRect(CANVAS_RECT, mx, my) and m_down and (active_tool == .Pencil or active_tool == .Eraser)) {
            const i = @divTrunc(mx - CANVAS_RECT.x, CELL_SIZE);
            const j = @divTrunc(my - CANVAS_RECT.y, CELL_SIZE);
            if (i >= 0 and i < GRID and j >= 0 and j < GRID) {
                var tx: usize = 0; var ty: usize = 0; var tz: usize = 0;
                switch (active_plane) {
                    .XY => { tx = @intCast(i); ty = @intCast(j); tz = @intCast(active_depth); },
                    .XZ => { tx = @intCast(i); ty = @intCast(active_depth); tz = @intCast(j); },
                    .YZ => { tx = @intCast(active_depth); ty = @intCast(i); tz = @intCast(j); },
                }
                if (active_tool == .Pencil) grid[tz][ty][tx] = active_color;
                if (active_tool == .Eraser) grid[tz][ty][tx] = 0;
            }
        }

        // Draw Selection Outline
        if (sel_active) {
            const min_x = @min(sel_x0, sel_x1); const max_x = @max(sel_x0, sel_x1);
            const min_y = @min(sel_y0, sel_y1); const max_y = @max(sel_y0, sel_y1);
            const s_rect = Rect{ .x = CANVAS_RECT.x + min_x * CELL_SIZE, .y = CANVAS_RECT.y + min_y * CELL_SIZE, 
                .w = (max_x - min_x + 1) * CELL_SIZE, .h = (max_y - min_y + 1) * CELL_SIZE };
            _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
            _ = c.SDL_RenderDrawRect(renderer, &s_rect);
        }

        // 2. Draw 3D Preview
        try renderFrame(&buffer, &grid, @intCast(cam_angle));
        _ = c.SDL_UpdateTexture(prev_tex, null, &buffer, BUFFER_W * @sizeOf(u32));
        const prev_rect = Rect{ .x = 700, .y = 50, .w = 400, .h = 400 };
        _ = c.SDL_SetRenderDrawColor(renderer, 15, 20, 25, 255);
        _ = c.SDL_RenderFillRect(renderer, &prev_rect);
        _ = c.SDL_RenderCopy(renderer, prev_tex, null, &prev_rect);

        // 3. UI Controls
        const UI_X = 1130;
        
        if (guiBtnColor(renderer, Rect{.x=UI_X, .y=50, .w=40, .h=40}, active_tool == .Pencil, 0x22BB22FF, mx, my, m_click)) { active_tool = .Pencil; }
        if (guiBtnColor(renderer, Rect{.x=UI_X+50, .y=50, .w=40, .h=40}, active_tool == .Eraser, 0xBB2222FF, mx, my, m_click)) { active_tool = .Eraser; }
        if (guiBtnColor(renderer, Rect{.x=UI_X, .y=100, .w=40, .h=40}, active_tool == .Fill, 0x2222BBFF, mx, my, m_click)) { active_tool = .Fill; }
        if (guiBtnColor(renderer, Rect{.x=UI_X+50, .y=100, .w=40, .h=40}, active_tool == .Line, 0x555555FF, mx, my, m_click)) { active_tool = .Line; }
        if (guiBtnColor(renderer, Rect{.x=UI_X+100, .y=100, .w=40, .h=40}, active_tool == .Circle, 0xAAAAAAFF, mx, my, m_click)) { active_tool = .Circle; }
        
        // Select & Extrude
        if (guiBtnColor(renderer, Rect{.x=UI_X, .y=150, .w=40, .h=40}, active_tool == .Select, 0xEEEE00FF, mx, my, m_click)) { active_tool = .Select; }
        if (guiBtnColor(renderer, Rect{.x=UI_X+50, .y=150, .w=40, .h=40}, active_tool == .Extrude, 0xFF8800FF, mx, my, m_click)) { active_tool = .Extrude; }

        for (1..8) |pt| {
            const px = UI_X + @as(i32, @intCast((pt-1) % 2)) * 60;
            const py = 210 + @as(i32, @intCast((pt-1) / 2)) * 50;
            if (guiBtnColor(renderer, Rect{.x=px, .y=py, .w=50, .h=40}, active_color == pt, PALETTE[pt], mx, my, m_click)) { active_color = @intCast(pt); }
        }

        if (guiBtnColor(renderer, Rect{.x=UI_X-20, .y=450, .w=40, .h=40}, active_plane == .XY, 0x2222BBFF, mx, my, m_click)) { active_plane = .XY; sel_active = false;}
        if (guiBtnColor(renderer, Rect{.x=UI_X+30, .y=450, .w=40, .h=40}, active_plane == .XZ, 0xBB22BBFF, mx, my, m_click)) { active_plane = .XZ; sel_active = false;}
        if (guiBtnColor(renderer, Rect{.x=UI_X+80, .y=450, .w=40, .h=40}, active_plane == .YZ, 0xCCCC22FF, mx, my, m_click)) { active_plane = .YZ; sel_active = false;}

        guiSlider(renderer, Rect{.x=700, .y=500, .w=400, .h=20}, 0, 7, &cam_angle, mx, my, m_down); 
        guiSlider(renderer, Rect{.x=700, .y=550, .w=400, .h=20}, 0, GRID - 1, &active_depth, mx, my, m_down); 

        c.SDL_RenderPresent(renderer);
        c.SDL_Delay(16);
    }
}
