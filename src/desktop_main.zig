const std = @import("std");
const qoi = @import("qoi.zig");

// SDL2 Bindings
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const ToolIcon = struct {
    name: []const u8,
    exec_path: []const u8,
    texture: *c.SDL_Texture,
    x: i32,
    y: i32,
    w: i32,
    h: i32,
};

pub const DesktopManager = struct {
    allocator: std.mem.Allocator,
    icons: std.ArrayListUnmanaged(ToolIcon) = .{},
    window: *c.SDL_Window,
    renderer: *c.SDL_Renderer,
    selected_index: ?usize = null,
    
    pub fn init(allocator: std.mem.Allocator) !DesktopManager {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) return error.SDLInitFailed;
        
        const window = c.SDL_CreateWindow(
            "DOOM_OS_311 - Program Manager",
            c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED,
            640, 480,
            c.SDL_WINDOW_SHOWN
        ) orelse return error.SDLWindowFailed;
        
        const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse return error.SDLRendererFailed;
        
        return DesktopManager{
            .allocator = allocator,
            .window = window,
            .renderer = renderer,
        };
    }
    
    pub fn deinit(self: *DesktopManager) void {
        for (self.icons.items) |icon| {
            c.SDL_DestroyTexture(icon.texture);
        }
        self.icons.deinit(self.allocator);
        c.SDL_DestroyRenderer(self.renderer);
        c.SDL_DestroyWindow(self.window);
        c.SDL_Quit();
    }
    
    pub fn addTool(self: *DesktopManager, name: []const u8, path: []const u8, icon_path: []const u8, x: i32, y: i32) !void {
        const file = try std.fs.cwd().readFileAlloc(self.allocator, icon_path, 1024 * 1024);
        defer self.allocator.free(file);
        
        const image = try qoi.decode(self.allocator, file);
        defer image.deinit();
        
        const texture = c.SDL_CreateTexture(
            self.renderer,
            c.SDL_PIXELFORMAT_RGBA8888,
            c.SDL_TEXTUREACCESS_STATIC,
            @intCast(image.width),
            @intCast(image.height)
        ) orelse return error.SDLTextureFailed;
        
        _ = c.SDL_UpdateTexture(texture, null, image.pixels.ptr, @intCast(image.width * 4));
        _ = c.SDL_SetTextureBlendMode(texture, c.SDL_BLENDMODE_BLEND);

        try self.icons.append(self.allocator, .{
            .name = name,
            .exec_path = path,
            .texture = texture,
            .x = x,
            .y = y,
            .w = @intCast(image.width),
            .h = @intCast(image.height),
        });
    }
    
    pub fn handleEvent(self: *DesktopManager, event: c.SDL_Event) !bool {
        if (event.type == c.SDL_QUIT) return true;
        
        if (event.type == c.SDL_MOUSEBUTTONDOWN) {
            const mx = event.button.x - 50; // Window offset
            const my = event.button.y - 70; // Header offset
            
            self.selected_index = null;
            for (self.icons.items, 0..) |icon, i| {
                if (mx >= icon.x and mx <= icon.x + icon.w and my >= icon.y and my <= icon.y + icon.h) {
                    self.selected_index = i;
                    if (event.button.clicks == 2) {
                        std.debug.print("Launching: {s}\n", .{icon.exec_path});
                        var child = std.process.Child.init(&[_][]const u8{icon.exec_path}, self.allocator);
                        try child.spawn();
                    }
                    break;
                }
            }
        }
        return false;
    }
    
    pub fn draw(self: *DesktopManager) void {
        // Desktop Blue
        _ = c.SDL_SetRenderDrawColor(self.renderer, 0, 128, 128, 255);
        _ = c.SDL_RenderClear(self.renderer);
        
        // Program Manager Window
        _ = c.SDL_SetRenderDrawColor(self.renderer, 192, 192, 192, 255);
        const win_rect = c.SDL_Rect{ .x = 50, .y = 50, .w = 540, .h = 380 };
        _ = c.SDL_RenderFillRect(self.renderer, &win_rect);
        
        // Title Bar
        _ = c.SDL_SetRenderDrawColor(self.renderer, 0, 0, 128, 255);
        const title_rect = c.SDL_Rect{ .x = 50, .y = 50, .w = 540, .h = 20 };
        _ = c.SDL_RenderFillRect(self.renderer, &title_rect);
        
        // Icons
        for (self.icons.items, 0..) |icon, i| {
            const dst = c.SDL_Rect{ 
                .x = win_rect.x + icon.x, 
                .y = win_rect.y + 20 + icon.y, 
                .w = icon.w, 
                .h = icon.h 
            };
            
            // Skill enforcement: White border for selection
            if (self.selected_index == i) {
                _ = c.SDL_SetRenderDrawColor(self.renderer, 255, 255, 255, 255);
                const border = c.SDL_Rect{ .x = dst.x - 2, .y = dst.y - 2, .w = dst.w + 4, .h = dst.h + 4 };
                _ = c.SDL_RenderDrawRect(self.renderer, &border);
            }
            
            _ = c.SDL_RenderCopy(self.renderer, icon.texture, null, &dst);
        }
        
        c.SDL_RenderPresent(self.renderer);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var desktop = try DesktopManager.init(allocator);
    defer desktop.deinit();
    
    // Sprint 1: Load essential tools with real sprite icons
    try desktop.addTool("Voxel", "./tlc_voxel", "assets/wall.qoi", 40, 40);
    try desktop.addTool("Editor", "./tlc_editor", "assets/server.qoi", 120, 40);
    try desktop.addTool("Game", "./tlc_at_doom", "assets/weapon.qoi", 200, 40);
    
    var event: c.SDL_Event = undefined;
    while (true) {
        while (c.SDL_PollEvent(&event) != 0) {
            if (try desktop.handleEvent(event)) return;
        }
        desktop.draw();
        c.SDL_Delay(16);
    }
}
