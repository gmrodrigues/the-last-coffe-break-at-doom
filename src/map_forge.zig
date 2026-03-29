const std = @import("std");
const sdl = @cImport({
    @cDefine("NK_INCLUDE_FIXED_TYPES", "1");
    @cDefine("NK_INCLUDE_STANDARD_IO", "1");
    @cDefine("NK_INCLUDE_STANDARD_VARARGS", "1");
    @cDefine("NK_INCLUDE_DEFAULT_ALLOCATOR", "1");
    @cDefine("NK_INCLUDE_VERTEX_BUFFER_OUTPUT", "1");
    @cDefine("NK_INCLUDE_FONT_BAKING", "1");
    @cDefine("NK_INCLUDE_DEFAULT_FONT", "1");
    @cInclude("SDL2/SDL.h");
    @cInclude("nuklear.h");
    @cInclude("nuklear_sdl_renderer.h");
});
const nk = sdl;

// Domain Entities for Sprint 1
pub const Vertex = struct {
    x: f32,
    y: f32,
};

pub const Wall = struct {
    v1: Vertex,
    v2: Vertex,
    thickness: f32 = 0.2,
    height_inner: f32 = 3.0,
    height_outer: f32 = 3.0,
    texture_id: u32 = 0,
};

// Represents a closed loop of vertices
pub const Boundary = struct {
    vertices: std.ArrayListUnmanaged(Vertex),
};

pub const FloorCanvas = struct {
    grid_size: f32 = 1.0,
};

pub const Area = struct {
    canvas: FloorCanvas,
    boundary: Boundary,
    inner_boundaries: std.ArrayListUnmanaged(Boundary),
    walls: std.ArrayListUnmanaged(Wall),

    pub fn init() Area {
        return .{
            .canvas = .{},
            .boundary = .{ .vertices = .empty },
            .inner_boundaries = .empty,
            .walls = .empty,
        };
    }

    pub fn generateWalls(self: *Area, allocator: std.mem.Allocator) !void {
        self.walls.clearRetainingCapacity();
        const verts = self.boundary.vertices.items;
        if (verts.len < 2) return;
        
        for (verts, 0..) |v1, i| {
            const v2 = if (i == verts.len - 1) verts[0] else verts[i + 1];
            try self.walls.append(allocator, Wall{
                .v1 = v1,
                .v2 = v2,
                .thickness = 0.5,
            });
        }
    }

    pub fn deinit(self: *Area, allocator: std.mem.Allocator) void {
        self.boundary.vertices.deinit(allocator);
        for (self.inner_boundaries.items) |*ib| {
            ib.vertices.deinit(allocator);
        }
        self.inner_boundaries.deinit(allocator);
        self.walls.deinit(allocator);
    }
};

pub const Region = struct {
    skybox_id: u32 = 0,
    ambient_light: f32 = 1.0,
    areas: std.ArrayListUnmanaged(Area),

    pub fn init() Region {
        return .{
            .areas = .empty,
        };
    }

    pub fn deinit(self: *Region, allocator: std.mem.Allocator) void {
        for (self.areas.items) |*area| {
            area.deinit(allocator);
        }
        self.areas.deinit(allocator);
    }
};

pub fn main() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "TLC_at_DOOM: Map Forge Playground",
        sdl.SDL_WINDOWPOS_CENTERED,
        sdl.SDL_WINDOWPOS_CENTERED,
        1280,
        720,
        sdl.SDL_WINDOW_SHOWN,
    ) orelse {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
        return error.SDLWindowCreationFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC) orelse {
        std.debug.print("SDL_CreateRenderer Error: {s}\n", .{sdl.SDL_GetError()});
        return error.SDLRendererCreationFailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var region = Region.init();
    defer region.deinit(allocator);

    // Create a default area to act as our workspace
    try region.areas.append(allocator, Area.init());

    const ctx = nk.nk_sdl_init(window, renderer);
    defer nk.nk_sdl_shutdown();

    // Default Font Baking
    var atlas: [*c]nk.struct_nk_font_atlas = undefined;
    nk.nk_sdl_font_stash_begin(&atlas);
    const font = nk.nk_font_atlas_add_default(atlas, 13.0, null);
    nk.nk_sdl_font_stash_end();

    if (font != null) {
        nk.nk_style_set_font(ctx, &font.*.handle);
    }

    var quit = false;
    var event: sdl.SDL_Event = undefined;

    while (!quit) {
        nk.nk_input_begin(ctx);
        while (sdl.SDL_PollEvent(&event) != 0) {
            _ = nk.nk_sdl_handle_event(&event);
            
            if (event.type == sdl.SDL_QUIT) {
                quit = true;
            } else if (event.type == sdl.SDL_KEYDOWN) {
                if (event.key.keysym.sym == sdl.SDLK_ESCAPE) {
                    quit = true;
                } else if (event.key.keysym.sym == sdl.SDLK_g) {
                    try region.areas.items[0].generateWalls(allocator);
                    std.debug.print("Walls generated for Area 0.\n", .{});
                } else if (event.key.keysym.sym == sdl.SDLK_c) {
                    region.areas.items[0].boundary.vertices.clearRetainingCapacity();
                    region.areas.items[0].walls.clearRetainingCapacity();
                    std.debug.print("Area 0 cleared.\n", .{});
                }
            } else if (event.type == sdl.SDL_MOUSEBUTTONDOWN) {
                // If Nuklear wants the mouse, ignore the viewport click
                if (nk.nk_item_is_any_active(ctx) == 0) {
                    if (event.button.button == sdl.SDL_BUTTON_LEFT) {
                        const mx = @as(f32, @floatFromInt(event.button.x));
                        const my = @as(f32, @floatFromInt(event.button.y));
                        
                        // ZUI coordinate transformation would go here.
                        // Inside Viewport Bounds
                        if (mx >= 0 and mx <= 1000 and my >= 40 and my <= 680) {
                            var target_area = &region.areas.items[0];
                            if (target_area.boundary.vertices.items.len >= 32) {
                                std.debug.print("Drift Alert: Max Area complexity (32 vertices) reached. Enforcing Retro Fidelity.\n", .{});
                            } else {
                                try target_area.boundary.vertices.append(allocator, Vertex{ .x = mx, .y = my });
                            }
                        }
                    }
                }
            }
        }
        nk.nk_input_end(ctx);

        // GUI: Utility Strip (Top)
        if (nk.nk_begin(ctx, "Utility Strip", nk.nk_rect(0, 0, 1280, 40), nk.NK_WINDOW_NO_SCROLLBAR | nk.NK_WINDOW_BACKGROUND) != 0) {
            nk.nk_layout_row_static(ctx, 30, 80, 5);
            if (nk.nk_button_label(ctx, "Clear (C)") != 0) {
                region.areas.items[0].boundary.vertices.clearRetainingCapacity();
                region.areas.items[0].walls.clearRetainingCapacity();
            }
            if (nk.nk_button_label(ctx, "Generate (G)") != 0) {
                try region.areas.items[0].generateWalls(allocator);
            }
        }
        nk.nk_end(ctx);

        // GUI: Sidebar Workspace (Right)
        if (nk.nk_begin(ctx, "Workspace", nk.nk_rect(1000, 40, 280, 680), nk.NK_WINDOW_TITLE | nk.NK_WINDOW_BORDER) != 0) {
            nk.nk_layout_row_dynamic(ctx, 30, 1);
            nk.nk_label(ctx, "Welcome to Map Forge", nk.NK_TEXT_CENTERED);
            nk.nk_layout_row_dynamic(ctx, 20, 1);
            nk.nk_label(ctx, "Vertex Count:", nk.NK_TEXT_LEFT);
            // Format string
            var buf: [32]u8 = undefined;
            const vertex_text = try std.fmt.bufPrintZ(&buf, "{d} / 32", .{region.areas.items[0].boundary.vertices.items.len});
            nk.nk_label(ctx, vertex_text.ptr, nk.NK_TEXT_LEFT);
        }
        nk.nk_end(ctx);

        // GUI: HUD (Bottom)
        if (nk.nk_begin(ctx, "HUD", nk.nk_rect(0, 680, 1000, 40), nk.NK_WINDOW_NO_SCROLLBAR | nk.NK_WINDOW_BACKGROUND) != 0) {
            nk.nk_layout_row_dynamic(ctx, 30, 1);
            nk.nk_label(ctx, "READY. Awaiting Input Data.", nk.NK_TEXT_LEFT);
        }
        nk.nk_end(ctx);

        // Main Rendering Pass
        _ = sdl.SDL_SetRenderDrawColor(renderer, 30, 30, 40, 255); // Background
        _ = sdl.SDL_RenderClear(renderer);

        // The UI Panels defined above will be drawn later.

        // Map Graphics (Viewport)
        const target_area = &region.areas.items[0];
        const verts = target_area.boundary.vertices.items;
        
        // Draw connection lines
        _ = sdl.SDL_SetRenderDrawColor(renderer, 150, 150, 160, 255);
        for (verts, 0..) |v, i| {
            if (i > 0) {
                const prev = verts[i - 1];
                _ = sdl.SDL_RenderDrawLine(renderer, @as(i32, @intFromFloat(prev.x)), @as(i32, @intFromFloat(prev.y)), @as(i32, @intFromFloat(v.x)), @as(i32, @intFromFloat(v.y)));
            }
            var p_rect = sdl.SDL_Rect{ .x = @as(i32, @intFromFloat(v.x)) - 3, .y = @as(i32, @intFromFloat(v.y)) - 3, .w = 6, .h = 6 };
            _ = sdl.SDL_SetRenderDrawColor(renderer, 200, 200, 255, 255);
            _ = sdl.SDL_RenderFillRect(renderer, &p_rect);
            _ = sdl.SDL_SetRenderDrawColor(renderer, 150, 150, 160, 255);
        }

        // Draw Extruded Walls (Thickening logic)
        _ = sdl.SDL_SetRenderDrawColor(renderer, 220, 80, 80, 255); // Corporate Red Highlight
        for (target_area.walls.items) |w| {
            const dx = w.v2.x - w.v1.x;
            const dy = w.v2.y - w.v1.y;
            const len = std.math.sqrt(dx*dx + dy*dy);
            if (len > 0.0001) {
                // Procedural normal calculation for thickness
                const visual_scale = 30.0; // scale up thickness for visual debugging
                const nx = (dy / len) * w.thickness * visual_scale;
                const ny = (-dx / len) * w.thickness * visual_scale;
                
                // Draw Volumetric Quad
                _ = sdl.SDL_RenderDrawLine(renderer, @as(i32, @intFromFloat(w.v1.x)), @as(i32, @intFromFloat(w.v1.y)), @as(i32, @intFromFloat(w.v2.x)), @as(i32, @intFromFloat(w.v2.y)));
                _ = sdl.SDL_RenderDrawLine(renderer, @as(i32, @intFromFloat(w.v1.x + nx)), @as(i32, @intFromFloat(w.v1.y + ny)), @as(i32, @intFromFloat(w.v2.x + nx)), @as(i32, @intFromFloat(w.v2.y + ny)));
                _ = sdl.SDL_RenderDrawLine(renderer, @as(i32, @intFromFloat(w.v1.x)), @as(i32, @intFromFloat(w.v1.y)), @as(i32, @intFromFloat(w.v1.x + nx)), @as(i32, @intFromFloat(w.v1.y + ny)));
                _ = sdl.SDL_RenderDrawLine(renderer, @as(i32, @intFromFloat(w.v2.x)), @as(i32, @intFromFloat(w.v2.y)), @as(i32, @intFromFloat(w.v2.x + nx)), @as(i32, @intFromFloat(w.v2.y + ny)));
            }
        }

        // Nuklear Render Pass
        nk.nk_sdl_render(nk.NK_ANTI_ALIASING_ON);

        sdl.SDL_RenderPresent(renderer);
    }
}
