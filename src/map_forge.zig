const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

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

    var quit = false;
    var event: sdl.SDL_Event = undefined;

    while (!quit) {
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                quit = true;
            }
        }

        // Render basic 4-Quadrant UI Layout
        _ = sdl.SDL_SetRenderDrawColor(renderer, 30, 30, 40, 255); // Background
        _ = sdl.SDL_RenderClear(renderer);

        // Utility Strip (Top)
        var rect = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 1280, .h = 40 };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 50, 50, 60, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &rect);

        // Sidebar Workspace (Right)
        rect = sdl.SDL_Rect{ .x = 1000, .y = 40, .w = 280, .h = 680 };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &rect);

        // HUD (Bottom)
        rect = sdl.SDL_Rect{ .x = 0, .y = 680, .w = 1000, .h = 40 };
        _ = sdl.SDL_SetRenderDrawColor(renderer, 20, 20, 30, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &rect);

        // The Viewport (Left/Middle) is inherently drawing over the background color in the remainder

        sdl.SDL_RenderPresent(renderer);
    }
}
