const std = @import("std");
const qoi = @import("qoi.zig");
const font = @import("font.zig");
const gif = @import("gif.zig");
const c = @cImport({ @cInclude("SDL2/SDL.h"); });

// ─── Constants ────────────────────────────────────────────────────────────────
const GRID = 16;
const TILE_W = 96;
const TILE_H = 96;
const PREVIEW_W = 96;
const PREVIEW_H = 96;
const PALETTE_COUNT = 8;

// Window size
const WIN_W = 1280;
const WIN_H = 760;

// Layout rectangles
const TOOLBAR_H   = 36;
const VIEWPORT_W  = 580;
const VIEWPORT_H  = 380;
const SLICE_W     = 580;
const SLICE_H     = 380;
const SLICE_PANEL_W = 130; // layer panel inside 2D viewer
const SLICER_H    = 56;
const TILE_AREA_H = 130;

const VIEWPORT_RECT = c.SDL_Rect{ .x = 0,         .y = TOOLBAR_H,    .w = VIEWPORT_W, .h = VIEWPORT_H };
const SLICE_RECT    = c.SDL_Rect{ .x = VIEWPORT_W, .y = TOOLBAR_H,    .w = SLICE_W,    .h = SLICE_H };
const SLICER_RECT   = c.SDL_Rect{ .x = 0,          .y = TOOLBAR_H + VIEWPORT_H, .w = WIN_W, .h = SLICER_H };
const TILES_RECT    = c.SDL_Rect{ .x = 0,          .y = TOOLBAR_H + VIEWPORT_H + SLICER_H, .w = WIN_W, .h = TILE_AREA_H };

// Canvas area inside the 2D Slice Viewer (leaves room for layer panel)
const CANVAS_X: i32 = VIEWPORT_W + SLICE_PANEL_W;
const CANVAS_W: i32 = SLICE_W - SLICE_PANEL_W;
const CANVAS_H: i32 = SLICE_H;
const CELL: i32      = @divTrunc(CANVAS_W, GRID);

// ─── Palette ──────────────────────────────────────────────────────────────────
const PALETTE = [PALETTE_COUNT]u32{
    0x00000000,
    0x333333FF, 0x666666FF, 0xAAAAAAFF,
    0xBB2222FF, 0x22BB22FF, 0x2222BBFF, 0xCCAA22FF,
};

// ─── Types ────────────────────────────────────────────────────────────────────
const Axis  = enum { X, Y, Z };
const Tool  = enum { Pencil, Eraser, Fill, Line, Circle, Select };

const LayerKind = enum { Voxel, Occlusion, Illumination, Texture, Geometry };
const Layer = struct {
    kind:    LayerKind = .Voxel,
    visible: bool = true,
    data:    [GRID][GRID]u8 = [_][GRID]u8{[_]u8{0} ** GRID} ** GRID,
};

// ─── Tiny GUI Helpers ─────────────────────────────────────────────────────────
fn inR(r: c.SDL_Rect, x: i32, y: i32) bool {
    return x >= r.x and x < r.x + r.w and y >= r.y and y < r.y + r.h;
}

fn setColor(rnd: *c.SDL_Renderer, rgba: u32) void {
    _ = c.SDL_SetRenderDrawColor(rnd,
        @intCast((rgba >> 24) & 0xFF),
        @intCast((rgba >> 16) & 0xFF),
        @intCast((rgba >>  8) & 0xFF),
        @intCast(rgba & 0xFF));
}

fn fillRect(rnd: *c.SDL_Renderer, r: c.SDL_Rect) void {
    _ = c.SDL_RenderFillRect(rnd, &r);
}

fn drawRect(rnd: *c.SDL_Renderer, r: c.SDL_Rect) void {
    _ = c.SDL_RenderDrawRect(rnd, &r);
}

/// Returns true if button was just clicked this frame.
fn button(rnd: *c.SDL_Renderer, r: c.SDL_Rect, fill: u32, outline: u32,
          mx: i32, my: i32, clicked: bool) bool {
    const hover = inR(r, mx, my);
    setColor(rnd, if (hover) outline else fill);
    fillRect(rnd, r);
    setColor(rnd, outline);
    drawRect(rnd, r);
    return hover and clicked;
}

fn slider(rnd: *c.SDL_Renderer, r: c.SDL_Rect, min: i32, max: i32,
          val: *i32, mx: i32, my: i32, held: bool) void {
    setColor(rnd, 0x1A1A2EFF);
    fillRect(rnd, r);
    setColor(rnd, 0x444466FF);
    drawRect(rnd, r);
    if (inR(r, mx, my) and held) {
        const ratio = @as(f32, @floatFromInt(mx - r.x)) / @as(f32, @floatFromInt(@max(r.w - 1, 1)));
        val.* = @max(min, @min(max, @as(i32, @intFromFloat(ratio * @as(f32, @floatFromInt(max - min)))) + min));
    }
    const rng: f32 = @floatFromInt(@max(max - min, 1));
    const ratio: f32 = @as(f32, @floatFromInt(val.* - min)) / rng;
    const hx = r.x + @as(i32, @intFromFloat(ratio * @as(f32, @floatFromInt(r.w - 10))));
    setColor(rnd, 0x8888CCFF);
    fillRect(rnd, c.SDL_Rect{ .x = hx, .y = r.y - 2, .w = 10, .h = r.h + 4 });
}

// ─── Isometric Projection (Painter's Algorithm) ───────────────────────────────
fn adjustColor(rgba: u32, amt: i32) u32 {
    var r: i32 = @intCast((rgba >> 24) & 0xFF);
    var g: i32 = @intCast((rgba >> 16) & 0xFF);
    var b: i32 = @intCast((rgba >>  8) & 0xFF);
    r = @max(0, @min(255, r + amt));
    g = @max(0, @min(255, g + amt));
    b = @max(0, @min(255, b + amt));
    return (@as(u32, @intCast(r)) << 24) | (@as(u32, @intCast(g)) << 16) | (@as(u32, @intCast(b)) << 8) | 0xFF;
}

const RVoxel = struct { sx: i32, sy: i32, depth: f32, rgba: u32, ghost: bool };

fn projectGrid(
    buf: []RVoxel,
    grid: *const [GRID][GRID][GRID]u8,
    cam: u32,
    active_axis: Axis,
    active_layer: i32,
    origin_x: i32,
    origin_y: i32,
    flat: bool,   // if true: no ghost, no plane — pure albedo for tiles
) usize {
    var len: usize = 0;
    const angle_rad = @as(f32, @floatFromInt(cam)) * std.math.pi / 4.0;
    const cos_a = @cos(angle_rad);
    const sin_a = @sin(angle_rad);

    for (0..GRID) |zi| {
        for (0..GRID) |yi| {
            for (0..GRID) |xi| {
                const color_idx = grid[zi][yi][xi];
                if (color_idx == 0) continue;

                const cx = @as(f32, @floatFromInt(xi)) - GRID / 2.0;
                const cy = @as(f32, @floatFromInt(yi)) - GRID / 2.0;
                const nx = cx * cos_a - cy * sin_a;
                const ny = cx * sin_a + cy * cos_a;
                const sx = origin_x + @as(i32, @intFromFloat(nx * 4.0));
                const sy = origin_y + @as(i32, @intFromFloat(ny * 2.2)) - @as(i32, @intFromFloat(@as(f32, @floatFromInt(zi)) * 4.0));
                const depth = ny * 10.0 - @as(f32, @floatFromInt(zi));

                var rgba = PALETTE[color_idx];
                var ghost = false;

                if (!flat) {
                    const layer_coord: i32 = switch (active_axis) {
                        .Z => @as(i32, @intCast(zi)),
                        .Y => @as(i32, @intCast(yi)),
                        .X => @as(i32, @intCast(xi)),
                    };
                    if (layer_coord > active_layer) {
                        ghost = true;
                        rgba = (rgba & 0xFFFFFF00) | 0x40; // very transparent
                    }
                }

                buf[len] = .{ .sx = sx, .sy = sy, .depth = depth, .rgba = rgba, .ghost = ghost };
                len += 1;
            }
        }
    }

    const S = struct { fn cmp(_: void, a: RVoxel, b: RVoxel) bool { return a.depth > b.depth; } };
    std.mem.sort(RVoxel, buf[0..len], {}, S.cmp);
    return len;
}

fn splat(rnd: *c.SDL_Renderer, vx: RVoxel) void {
    const rgba = vx.rgba;
    const ax: u8 = @intCast(rgba & 0xFF);
    if (ax < 10) return;
    const c1 = adjustColor(rgba, 25);
    const c2 = rgba;
    const c3 = adjustColor(rgba, -45);
    const px = vx.sx;
    const py = vx.sy;
    // top face
    setColor(rnd, c1); fillRect(rnd, c.SDL_Rect{ .x = px - 2, .y = py - 4, .w = 4, .h = 2 });
    // left face
    setColor(rnd, c2); fillRect(rnd, c.SDL_Rect{ .x = px - 4, .y = py - 3, .w = 4, .h = 4 });
    // right face
    setColor(rnd, c3); fillRect(rnd, c.SDL_Rect{ .x = px,     .y = py - 3, .w = 4, .h = 4 });
}

/// Draw translucent Glowing Plane inside the 3D viewport
fn drawGlowingPlane(rnd: *c.SDL_Renderer, cam: u32, active_axis: Axis, active_layer: i32,
                    origin_x: i32, origin_y: i32, plane_opacity: u8) void {
    _ = c.SDL_SetRenderDrawBlendMode(rnd, c.SDL_BLENDMODE_BLEND);
    _ = c.SDL_SetRenderDrawColor(rnd, 0, 200, 255, plane_opacity);
    const angle_rad = @as(f32, @floatFromInt(cam)) * std.math.pi / 4.0;
    const cos_a = @cos(angle_rad);
    const sin_a = @sin(angle_rad);
    const lf = @as(f32, @floatFromInt(active_layer)) - GRID / 2.0;

    for (0..GRID) |a| {
        for (0..GRID) |b| {
            var cx: f32 = undefined; var cy: f32 = undefined; var cz: f32 = undefined;
            switch (active_axis) {
                .Z => { cx = @as(f32, @floatFromInt(a)) - GRID/2.0; cy = @as(f32, @floatFromInt(b)) - GRID/2.0; cz = lf; },
                .Y => { cx = @as(f32, @floatFromInt(a)) - GRID/2.0; cy = lf; cz = @as(f32, @floatFromInt(b)); },
                .X => { cx = lf; cy = @as(f32, @floatFromInt(a)) - GRID/2.0; cz = @as(f32, @floatFromInt(b)); },
            }
            const nx = cx * cos_a - cy * sin_a;
            const ny = cx * sin_a + cy * cos_a;
            const sx = origin_x + @as(i32, @intFromFloat(nx * 4.0));
            const sy = origin_y + @as(i32, @intFromFloat(ny * 2.2)) - @as(i32, @intFromFloat(cz * 4.0));
            const cell = c.SDL_Rect{ .x = sx - 2, .y = sy - 2, .w = 4, .h = 4 };
            _ = c.SDL_RenderFillRect(rnd, &cell);
        }
    }
    _ = c.SDL_SetRenderDrawBlendMode(rnd, c.SDL_BLENDMODE_NONE);
}

// ─── CAD Tool Algorithms ──────────────────────────────────────────────────────
fn applyFloodFill(data: *[GRID][GRID]u8, px: i32, py: i32, target: u8, fill_color: u8) void {
    if (px < 0 or py < 0 or px >= GRID or py >= GRID) return;
    if (data[@intCast(py)][@intCast(px)] != target) return;
    if (data[@intCast(py)][@intCast(px)] == fill_color) return;
    data[@intCast(py)][@intCast(px)] = fill_color;
    applyFloodFill(data, px+1, py, target, fill_color);
    applyFloodFill(data, px-1, py, target, fill_color);
    applyFloodFill(data, px, py+1, target, fill_color);
    applyFloodFill(data, px, py-1, target, fill_color);
}

fn drawBresenhamLine(data: *[GRID][GRID]u8, x0: i32, y0: i32, x1: i32, y1: i32, color: u8) void {
    var cx = x0; var cy = y0;
    const dx: i32 = @intCast(@abs(x1 - x0));
    const dy: i32 = -@as(i32, @intCast(@abs(y1 - y0)));
    const sx: i32 = if (x0 < x1) 1 else -1;
    const sy: i32 = if (y0 < y1) 1 else -1;
    var err: i32 = dx + dy;
    while (true) {
        if (cx >= 0 and cy >= 0 and cx < GRID and cy < GRID) data[@intCast(cy)][@intCast(cx)] = color;
        if (cx == x1 and cy == y1) break;
        const e2 = 2 * err;
        if (e2 >= dy) { err += dy; cx += sx; }
        if (e2 <= dx) { err += dx; cy += sy; }
    }
}

fn drawBresenhamCircle(data: *[GRID][GRID]u8, xc: i32, yc: i32, r0: i32, color: u8) void {
    var x: i32 = -r0; var y: i32 = 0; var err: i32 = 2 - 2 * r0;
    while (x < 0) {
        const pts = [_][2]i32{ .{xc-x, yc+y}, .{xc-y, yc-x}, .{xc+x, yc-y}, .{xc+y, yc+x} };
        for (pts) |p| {
            if (p[0] >= 0 and p[0] < GRID and p[1] >= 0 and p[1] < GRID)
                data[@intCast(p[1])][@intCast(p[0])] = color;
        }
        const r2 = err;
        if (r2 <= y) { y += 1; err += y * 2 + 1; }
        if (r2 > x or err > y) { x += 1; err += x * 2 + 1; }
    }
}

// ─── Merge layers → master grid ───────────────────────────────────────────────
fn mergeLayers(layers: []const Layer, active_axis: Axis, active_layer: i32) [GRID][GRID][GRID]u8 {
    var grid: [GRID][GRID][GRID]u8 = undefined;
    @memset(&grid, [_][GRID]u8{[_]u8{0} ** GRID} ** GRID);

    for (layers) |layer| {
        if (!layer.visible) continue;
        if (layer.kind != .Voxel) continue; // only Voxel layers write geometry
        for (0..GRID) |r| {
            for (0..GRID) |col| {
                const v = layer.data[r][col];
                if (v == 0) continue;
                switch (active_axis) {
                    .Z => grid[@intCast(active_layer)][r][col] = v,
                    .Y => grid[r][@intCast(active_layer)][col] = v,
                    .X => grid[r][col][@intCast(active_layer)] = v,
                }
            }
        }
    }
    return grid;
}

// ─── Export QOI ───────────────────────────────────────────────────────────────
fn exportSprites(allocator: std.mem.Allocator, grid: *const [GRID][GRID][GRID]u8) !void {
    var frames_indices = try allocator.alloc([]u8, 8);
    defer {
        for (frames_indices) |f| allocator.free(f);
        allocator.free(frames_indices);
    }

    for (0..8) |a| {
        var buf: [TILE_W * TILE_H]u32 = @splat(0);
        var indices = try allocator.alloc(u8, TILE_W * TILE_H);
        @memset(indices, 0);
        frames_indices[a] = indices;

        var rvox: [GRID * GRID * GRID + 1]RVoxel = undefined;
        const n = projectGrid(&rvox, grid, @intCast(a), .Z, 0,
                              TILE_W / 2, TILE_H / 2 + 10, true);
        
        // Rasterize into both RGBA (for QOI) and Indices (for GIF)
        for (rvox[0..n]) |vx| {
            for (0..4) |oy| {
                for (0..4) |ox| {
                    const px = vx.sx + @as(i32, @intCast(ox)) - 2;
                    const py = vx.sy + @as(i32, @intCast(oy)) - 2;
                    if (px >= 0 and px < TILE_W and py >= 0 and py < TILE_H) {
                        const idx = @as(usize, @intCast(py * TILE_W + px));
                        buf[idx] = vx.rgba;
                        // Find palette index (naive but okay for 8 colors)
                        for (PALETTE, 0..) |pc, pi| {
                            if (pc == (vx.rgba | 0x000000FF)) { // ignore alpha for match
                                indices[idx] = @intCast(pi);
                                break;
                            }
                        }
                    }
                }
            }
        }

        const data = try qoi.encode(allocator, TILE_W, TILE_H, &buf);
        defer allocator.free(data);
        var name: [64]u8 = undefined;
        const path = try std.fmt.bufPrint(&name, "assets/voxel_{}.qoi", .{a});
        try std.fs.cwd().writeFile(.{ .sub_path = path, .data = data });
    }

    // Export Consolidated GIF
    const gif_data = try gif.encode(allocator, TILE_W, TILE_H, @ptrCast(frames_indices), &PALETTE);
    defer allocator.free(gif_data);
    try std.fs.cwd().writeFile(.{ .sub_path = "assets/voxel_anim.gif", .data = gif_data });

    std.debug.print("Exported 8 sprites and voxel_anim.gif to assets/\n", .{});
}

// ─── Main ─────────────────────────────────────────────────────────────────────
pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) return error.SDLInitFailed;
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow(
        "D.O.O.M. Voxel Forge V3",
        c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED,
        WIN_W, WIN_H, c.SDL_WINDOW_RESIZABLE);
    defer c.SDL_DestroyWindow(window);
    const rnd = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse return error.Renderer;
    defer c.SDL_DestroyRenderer(rnd);

    // Pre-allocate the 8 tile textures (small, TILE_W x TILE_H)
    var tile_textures: [8]?*c.SDL_Texture = [_]?*c.SDL_Texture{null} ** 8;
    for (0..8) |i| {
        tile_textures[i] = c.SDL_CreateTexture(rnd, c.SDL_PIXELFORMAT_RGBA8888,
            c.SDL_TEXTUREACCESS_STREAMING, TILE_W, TILE_H);
    }
    defer for (tile_textures) |t| { if (t) |tx| c.SDL_DestroyTexture(tx); };

    // State
    const MAX_LAYERS = 8;
    var layers: [MAX_LAYERS]Layer = undefined;
    for (&layers) |*l| l.* = Layer{};
    layers[0] = .{ .kind = .Voxel, .visible = true };
    var layer_count: usize = 1;
    var active_layer_idx: usize = 0;  // which layer in the stack we edit
    var active_axis: Axis = .Z;
    var active_layer: i32 = GRID / 2; // slice position
    var plane_opacity: i32 = 120;
    var cam_angle: i32 = 1;           // 0..7
    var active_color: u8 = 1;
    var active_tool: Tool = .Pencil;
    var show_grid: bool = true;
    var show_plane: bool = true;
    var play_anim: bool = false;

    var drag_start_x: i32 = -1;
    var drag_start_y: i32 = -1;
    var m_down = false;
    var m_click = false;
    var m_up = false;

    var frame_tick: u32 = 0;

    var event: c.SDL_Event = undefined;

    while (true) {
        m_click = false; m_up = false;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => return,
                c.SDL_KEYDOWN => switch (event.key.keysym.sym) {
                    c.SDLK_ESCAPE => return,
                    c.SDLK_p => exportSprites(std.heap.page_allocator,
                                              &mergeLayers(layers[0..layer_count], active_axis, active_layer)) catch {},
                    else => {},
                },
                c.SDL_MOUSEBUTTONDOWN => if (event.button.button == c.SDL_BUTTON_LEFT) { m_down = true; m_click = true; },
                c.SDL_MOUSEBUTTONUP   => if (event.button.button == c.SDL_BUTTON_LEFT) { m_down = false; m_up = true; },
                else => {},
            }
        }
        var mx: i32 = 0; var my: i32 = 0;
        _ = c.SDL_GetMouseState(&mx, &my);

        frame_tick += 1;
        if (play_anim and frame_tick % 12 == 0) {
            active_layer = @mod(active_layer + 1, GRID);
        }

        // ── Build merged grid ────────────────────────────────────────────────
        const grid = mergeLayers(layers[0..layer_count], active_axis, active_layer);
        var rvox_buf: [GRID * GRID * GRID + 1]RVoxel = undefined;

        // ── Clear ────────────────────────────────────────────────────────────
        setColor(rnd, 0x0D0D1AFF);
        _ = c.SDL_RenderClear(rnd);

        // ═══════════════════════════════════════════════════════════════════
        // 1. TOOLBAR
        // ═══════════════════════════════════════════════════════════════════
        setColor(rnd, 0x14142AFF);
        fillRect(rnd, c.SDL_Rect{ .x = 0, .y = 0, .w = WIN_W, .h = TOOLBAR_H });
        // Grid toggle
        const g_r = c.SDL_Rect{ .x = 8, .y = 6, .w = 60, .h = 24 };
        if (button(rnd, g_r, if (show_grid) 0x224488FF else 0x222222FF, 0x4466AAFF, mx, my, m_click)) show_grid = !show_grid;
        setColor(rnd, 0xDDDDFFFF);
        font.drawTextCentered(c, rnd, "GRID", g_r, 1);
        // Plane toggle
        const p_r = c.SDL_Rect{ .x = 76, .y = 6, .w = 60, .h = 24 };
        if (button(rnd, p_r, if (show_plane) 0x006688FF else 0x222222FF, 0x00AACCFF, mx, my, m_click)) show_plane = !show_plane;
        setColor(rnd, 0xDDFFFFFF);
        font.drawTextCentered(c, rnd, "PLANE", p_r, 1);
        // Tool buttons
        const tool_colors = [_]u32{0x22AA44FF, 0xAA2244FF, 0x2244AAFF, 0x446688FF, 0x557799FF, 0xAA8822FF};
        const tools_list  = [_]Tool{.Pencil, .Eraser, .Fill, .Line, .Circle, .Select};
        const tool_labels = [_][]const u8{"PEN", "ERASE", "FILL", "LINE", "CIRC", "SEL"};
        for (tools_list, 0..) |tool, ti| {
            const tr = c.SDL_Rect{ .x = 160 + @as(i32, @intCast(ti)) * 70, .y = 6, .w = 60, .h = 24 };
            const is_active = (active_tool == tool);
            if (button(rnd, tr, if (is_active) tool_colors[ti] else 0x222233FF, tool_colors[ti], mx, my, m_click))
                active_tool = tool;
            setColor(rnd, 0xFFFFFFFF);
            font.drawTextCentered(c, rnd, tool_labels[ti], tr, 1);
        }
        // Palette swatches
        for (1..PALETTE_COUNT) |pi| {
            const pr = c.SDL_Rect{ .x = 620 + @as(i32, @intCast(pi)) * 44, .y = 5, .w = 36, .h = 26 };
            if (button(rnd, pr, PALETTE[pi], if (active_color == pi) 0xFFFFFFFF else PALETTE[pi], mx, my, m_click))
                active_color = @intCast(pi);
            if (active_color == pi) {
                setColor(rnd, 0xFFFFFFFF);
                drawRect(rnd, c.SDL_Rect{ .x = pr.x-2, .y = pr.y-2, .w = pr.w+4, .h = pr.h+4 });
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // 2. 3D VIEWPORT
        // ═══════════════════════════════════════════════════════════════════
        setColor(rnd, 0x080812FF);
        fillRect(rnd, VIEWPORT_RECT);
        setColor(rnd, 0x2A2A4AFF);
        drawRect(rnd, VIEWPORT_RECT);

        const vox_origin_x = VIEWPORT_RECT.x + VIEWPORT_RECT.w / 2;
        const vox_origin_y = VIEWPORT_RECT.y + @divTrunc(VIEWPORT_RECT.h * 55, 100);

        // Draw voxels
        const vn = projectGrid(&rvox_buf, &grid, @intCast(cam_angle),
                               active_axis, active_layer,
                               vox_origin_x, vox_origin_y, false);
        for (rvox_buf[0..vn]) |v| splat(rnd, v);

        // Glowing Plane
        if (show_plane) drawGlowingPlane(rnd, @intCast(cam_angle), active_axis, active_layer,
                                         vox_origin_x, vox_origin_y, @intCast(plane_opacity));

        // Grid floor
        if (show_grid) {
            _ = c.SDL_SetRenderDrawBlendMode(rnd, c.SDL_BLENDMODE_BLEND);
            _ = c.SDL_SetRenderDrawColor(rnd, 60, 60, 100, 50);
            const gn = 6;
            for (0..gn) |gi| {
                const t: f32 = @as(f32, @floatFromInt(gi)) - gn / 2.0;
                const a_rad = @as(f32, @floatFromInt(cam_angle)) * std.math.pi / 4.0;
                const px1 = vox_origin_x + @as(i32, @intFromFloat((t * @cos(a_rad) - (-4) * @sin(a_rad)) * 4.0));
                const py1 = vox_origin_y + @as(i32, @intFromFloat((t * @sin(a_rad) + (-4) * @cos(a_rad)) * 2.2)) + 40;
                const px2 = vox_origin_x + @as(i32, @intFromFloat((t * @cos(a_rad) - (4) * @sin(a_rad)) * 4.0));
                const py2 = vox_origin_y + @as(i32, @intFromFloat((t * @sin(a_rad) + (4) * @cos(a_rad)) * 2.2)) + 40;
                _ = c.SDL_RenderDrawLine(rnd, px1, py1, px2, py2);
            }
            _ = c.SDL_SetRenderDrawBlendMode(rnd, c.SDL_BLENDMODE_NONE);
        }

        // ═══════════════════════════════════════════════════════════════════
        // 3. LAYER PANEL (inside 2D Slice Viewer, left strip)
        // ═══════════════════════════════════════════════════════════════════
        setColor(rnd, 0x10102AFF);
        fillRect(rnd, c.SDL_Rect{ .x = VIEWPORT_W, .y = TOOLBAR_H, .w = SLICE_PANEL_W, .h = SLICE_H });
        setColor(rnd, 0x223366FF);
        drawRect(rnd, c.SDL_Rect{ .x = VIEWPORT_W, .y = TOOLBAR_H, .w = SLICE_PANEL_W, .h = SLICE_H });

        // Add layer button (+)
        const add_r = c.SDL_Rect{ .x = VIEWPORT_W + 4, .y = TOOLBAR_H + 4, .w = SLICE_PANEL_W - 8, .h = 22 };
        if (layer_count < MAX_LAYERS and button(rnd, add_r, 0x1A3A1AFF, 0x22AA44FF, mx, my, m_click)) {
            layers[layer_count] = .{ .kind = .Voxel, .visible = true };
            layer_count += 1;
        }
        setColor(rnd, 0x22AA44FF);
        _ = c.SDL_RenderDrawLine(rnd, VIEWPORT_W + SLICE_PANEL_W/2 - 5, TOOLBAR_H + 13,
                                 VIEWPORT_W + SLICE_PANEL_W/2 + 5, TOOLBAR_H + 13);
        _ = c.SDL_RenderDrawLine(rnd, VIEWPORT_W + SLICE_PANEL_W/2, TOOLBAR_H + 8,
                                 VIEWPORT_W + SLICE_PANEL_W/2, TOOLBAR_H + 18);

        // Layer list
        const kind_colors = [_]u32{ 0x3355AAFF, 0xFF4444FF, 0xFFAA00FF, 0x00AA88FF, 0xAA44FFFF, 0x8888FFFF };
        const kind_labels = [_][]const u8{ "VOX", "OCC", "LIT", "TEX", "GEO", "?" };
        for (0..layer_count) |li| {
            const ry = TOOLBAR_H + 32 + @as(i32, @intCast(li)) * 50;
            const row = c.SDL_Rect{ .x = VIEWPORT_W + 2, .y = ry, .w = SLICE_PANEL_W - 4, .h = 44 };
            const is_sel = (li == active_layer_idx);
            setColor(rnd, if (is_sel) 0x1A2A4AFF else 0x111122FF);
            fillRect(rnd, row);
            setColor(rnd, if (is_sel) 0x4488CCFF else 0x2A2A4AFF);
            drawRect(rnd, row);
            // Kind color stripe
            const ki = @intFromEnum(layers[li].kind);
            setColor(rnd, kind_colors[ki]);
            fillRect(rnd, c.SDL_Rect{ .x = VIEWPORT_W + 3, .y = ry+2, .w = 6, .h = 40 });
            // Kind label
            setColor(rnd, kind_colors[ki]);
            _ = font.drawText(c, rnd, kind_labels[ki], VIEWPORT_W + 12, ry + 8, 1);
            // Layer number
            var num_buf: [8]u8 = undefined;
            const num_str = std.fmt.bufPrint(&num_buf, "L{}", .{li + 1}) catch "L?";
            setColor(rnd, 0x8888AAFF);
            _ = font.drawText(c, rnd, num_str, VIEWPORT_W + 12, ry + 22, 1);
            // Visibility dot
            const vis_r = c.SDL_Rect{ .x = VIEWPORT_W + SLICE_PANEL_W - 20, .y = ry + 14, .w = 14, .h = 14 };
            if (button(rnd, vis_r, if (layers[li].visible) 0x00AACCFF else 0x222233FF, 0x44AADDFF, mx, my, m_click))
                layers[li].visible = !layers[li].visible;
            setColor(rnd, 0xFFFFFFFF);
            if (layers[li].visible) font.drawTextCentered(c, rnd, "O", vis_r, 1)
            else font.drawTextCentered(c, rnd, "-", vis_r, 1);
            // Select layer
            if (m_click and inR(row, mx, my) and !inR(vis_r, mx, my))
                active_layer_idx = li;
        }

        // ═══════════════════════════════════════════════════════════════════
        // 4. 2D SLICE VIEWER (canvas area)
        // ═══════════════════════════════════════════════════════════════════
        const canvas_r = c.SDL_Rect{ .x = CANVAS_X, .y = TOOLBAR_H, .w = CANVAS_W, .h = CANVAS_H };
        setColor(rnd, 0x0A0A18FF);
        fillRect(rnd, canvas_r);

        // Active slice data from current layer
        const active_data = &layers[active_layer_idx].data;

        // Draw cells
        for (0..GRID) |ci| {
            for (0..GRID) |ri| {
                const color_idx = active_data[ri][ci];
                const cx = CANVAS_X + @as(i32, @intCast(ci)) * CELL;
                const cy = TOOLBAR_H + @as(i32, @intCast(ri)) * CELL;
                if (color_idx > 0) {
                    setColor(rnd, PALETTE[color_idx]);
                    fillRect(rnd, c.SDL_Rect{ .x = cx, .y = cy, .w = CELL-1, .h = CELL-1 });
                }
                // grid lines
                setColor(rnd, 0x1A1A33FF);
                _ = c.SDL_RenderDrawLine(rnd, cx, TOOLBAR_H, cx, TOOLBAR_H + CANVAS_H);
                _ = c.SDL_RenderDrawLine(rnd, CANVAS_X, cy, CANVAS_X + CANVAS_W, cy);
            }
        }
        setColor(rnd, 0x2A2A5AFF);
        drawRect(rnd, canvas_r);

        // === Canvas tool interaction ===
        if (m_click and inR(canvas_r, mx, my)) {
            drag_start_x = @divTrunc(mx - CANVAS_X, CELL);
            drag_start_y = @divTrunc(my - TOOLBAR_H, CELL);
        }
        if (m_up and (active_tool == .Line or active_tool == .Circle) and drag_start_x >= 0) {
            const ux = @divTrunc(mx - CANVAS_X, CELL);
            const uy = @divTrunc(my - TOOLBAR_H, CELL);
            if (active_tool == .Line)
                drawBresenhamLine(active_data, drag_start_x, drag_start_y, ux, uy, active_color)
            else {
                const dx = ux - drag_start_x; const dy = uy - drag_start_y;
                const r0 = @as(i32, @intFromFloat(@sqrt(@as(f32, @floatFromInt(dx*dx+dy*dy)))));
                drawBresenhamCircle(active_data, drag_start_x, drag_start_y, r0, active_color);
            }
        }
        if (m_click and active_tool == .Fill and inR(canvas_r, mx, my)) {
            const fx = @divTrunc(mx - CANVAS_X, CELL);
            const fy = @divTrunc(my - TOOLBAR_H, CELL);
            if (fx >= 0 and fx < GRID and fy >= 0 and fy < GRID) {
                const target = active_data[@intCast(fy)][@intCast(fx)];
                applyFloodFill(active_data, fx, fy, target, active_color);
            }
        }
        if (m_down and inR(canvas_r, mx, my) and (active_tool == .Pencil or active_tool == .Eraser)) {
            const ci = @divTrunc(mx - CANVAS_X, CELL);
            const ri = @divTrunc(my - TOOLBAR_H, CELL);
            if (ci >= 0 and ci < GRID and ri >= 0 and ri < GRID) {
                if (active_tool == .Pencil) active_data[@intCast(ri)][@intCast(ci)] = active_color
                else active_data[@intCast(ri)][@intCast(ci)] = 0;
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // 5. SLICING CONTROLS
        // ═══════════════════════════════════════════════════════════════════
        setColor(rnd, 0x10102AFF);
        fillRect(rnd, SLICER_RECT);
        setColor(rnd, 0x222244FF);
        drawRect(rnd, SLICER_RECT);

        // Axis buttons
        const axis_list  = [_]Axis{.X, .Y, .Z};
        const axis_cols  = [_]u32{0xCC3333FF, 0x33CC33FF, 0x3333CCFF};
        const axis_labels = [_][]const u8{"X", "Y", "Z"};
        for (axis_list, 0..) |ax, ai| {
            const ar = c.SDL_Rect{ .x = 8 + @as(i32, @intCast(ai)) * 56, .y = SLICER_RECT.y + 14, .w = 48, .h = 28 };
            if (button(rnd, ar, if (active_axis == ax) axis_cols[ai] else 0x1A1A33FF, axis_cols[ai], mx, my, m_click))
                active_axis = ax;
            setColor(rnd, 0xFFFFFFFF);
            font.drawTextCentered(c, rnd, axis_labels[ai], ar, 2);
        }
        // Layer indicator text
        var linfo_buf: [16]u8 = undefined;
        const linfo = std.fmt.bufPrint(&linfo_buf, "LAYER {}/{}", .{ active_layer, GRID - 1 }) catch "L?";
        setColor(rnd, 0x8899CCFF);
        _ = font.drawText(c, rnd, linfo, 185, SLICER_RECT.y + 6, 1);

        // Layer slider (big one)
        var layer_slider_val = active_layer;
        slider(rnd, c.SDL_Rect{ .x = 185, .y = SLICER_RECT.y + 18, .w = 500, .h = 20 }, 0, GRID - 1, &layer_slider_val, mx, my, m_down);
        active_layer = layer_slider_val;

        // Play button
        const play_r = c.SDL_Rect{ .x = 695, .y = SLICER_RECT.y + 14, .w = 40, .h = 28 };
        if (button(rnd, play_r, if (play_anim) 0x226622FF else 0x1A1A33FF, 0x44CC44FF, mx, my, m_click))
            play_anim = !play_anim;
        setColor(rnd, 0x44CC44FF);
        _ = c.SDL_RenderDrawLine(rnd, 703, SLICER_RECT.y + 20, 703, SLICER_RECT.y + 35);
        _ = c.SDL_RenderDrawLine(rnd, 703, SLICER_RECT.y + 20, 725, SLICER_RECT.y + 27);
        _ = c.SDL_RenderDrawLine(rnd, 703, SLICER_RECT.y + 35, 725, SLICER_RECT.y + 27);

        // Plane opacity slider
        var po = plane_opacity;
        slider(rnd, c.SDL_Rect{ .x = 760, .y = SLICER_RECT.y + 18, .w = 200, .h = 20 }, 20, 220, &po, mx, my, m_down);
        plane_opacity = po;

        // Export button
        const exp_r = c.SDL_Rect{ .x = WIN_W - 100, .y = SLICER_RECT.y + 12, .w = 90, .h = 32 };
        if (button(rnd, exp_r, 0x331155FF, 0x9944FFFF, mx, my, m_click)) {
            const merged = mergeLayers(layers[0..layer_count], active_axis, active_layer);
            exportSprites(std.heap.page_allocator, &merged) catch {};
        }
        setColor(rnd, 0xFFFFFFFF);
        font.drawTextCentered(c, rnd, "EXPORT", exp_r, 1);
        // Opacity label
        setColor(rnd, 0x6688AAFF);
        _ = font.drawText(c, rnd, "OPACITY", 765, SLICER_RECT.y + 5, 1);

        // ═══════════════════════════════════════════════════════════════════
        // 6. 8-DIRECTION TILES (bottom strip — flat shadowless render)
        // ═══════════════════════════════════════════════════════════════════
        setColor(rnd, 0x080814FF);
        fillRect(rnd, TILES_RECT);
        setColor(rnd, 0x1A1A3AFF);
        drawRect(rnd, TILES_RECT);

        const tile_spacing = @divTrunc(WIN_W, 8);
        for (0..8) |ti| {
            const tx = @as(i32, @intCast(ti)) * tile_spacing + @divTrunc(tile_spacing - TILE_W, 2);
            const ty = TILES_RECT.y + @divTrunc(TILES_RECT.h - TILE_H, 2);
            const tile_rect = c.SDL_Rect{ .x = tx, .y = ty, .w = TILE_W, .h = TILE_H };

            // Dark background
            setColor(rnd, 0x0A0A18FF);
            fillRect(rnd, tile_rect);

            // Draw flat mini-render directly (no texture upload for simplicity)
            const ox = tx + TILE_W / 2;
            const oy = ty + TILE_H / 2 + 8;
            const tn = projectGrid(&rvox_buf, &grid, @intCast(ti), .Z, 0, ox, oy, true);
            for (rvox_buf[0..tn]) |v| {
                // Clip to tile
                if (v.sx < tx or v.sx >= tx + TILE_W or v.sy < ty or v.sy >= ty + TILE_H) continue;
                const rgba = v.rgba;
                setColor(rnd, rgba);
                _ = c.SDL_RenderFillRect(rnd, &c.SDL_Rect{ .x = v.sx - 2, .y = v.sy - 2, .w = 4, .h = 4 });
            }

            // Active cam highlight
            setColor(rnd, if (ti == @as(usize, @intCast(cam_angle))) 0x00BBFFFF else 0x2A2A4AFF);
            drawRect(rnd, tile_rect);

            // Angle label below the tile
            const angle_degs = [_][]const u8{"0","45","90","135","180","225","270","315"};
            setColor(rnd, if (ti == @as(usize, @intCast(cam_angle))) 0x00BBFFFF else 0x5555AAFF);
            _ = font.drawText(c, rnd, angle_degs[ti], tx + @divTrunc(TILE_W, 2) - 4, ty + TILE_H + 2, 1);

            // Click to set camera angle
            if (m_click and inR(tile_rect, mx, my)) cam_angle = @intCast(ti);
        }

        c.SDL_RenderPresent(rnd);
        c.SDL_Delay(16);
    }
}
