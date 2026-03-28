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
    w: i32,
    h: i32,
};

pub const DesktopManager = struct {
    allocator: std.mem.Allocator,
    icons: std.ArrayListUnmanaged(ToolIcon) = .{},
    window: *c.SDL_Window,
    renderer: *c.SDL_Renderer,
    
    // Main Program Manager Window State
    pm_x: i32 = 50,
    pm_y: i32 = 50,
    pm_w: i32 = 540,
    pm_h: i32 = 380,
    pm_minimized: bool = false,
    
    selected_index: ?usize = null,
    drag_active: bool = false,
    drag_offset_x: i32 = 0,
    drag_offset_y: i32 = 0,
    
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
    
    pub fn addTool(self: *DesktopManager, name: []const u8, path: []const u8, icon_path: []const u8) !void {
        const file = try std.fs.cwd().readFileAlloc(self.allocator, icon_path, 1024 * 1024);
        defer self.allocator.free(file);
        
        const image = try qoi.decode(self.allocator, file);
        defer image.deinit();
        
        const texture = c.SDL_CreateTexture(
            self.renderer,
            c.SDL_PIXELFORMAT_ABGR8888,
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
            .w = @intCast(image.width),
            .h = @intCast(image.height),
        });
    }
    
    pub fn handleEvent(self: *DesktopManager, event: c.SDL_Event) !bool {
        if (event.type == c.SDL_QUIT) return true;
        
        if (event.type == c.SDL_MOUSEBUTTONDOWN) {
            const mx = event.button.x;
            const my = event.button.y;
            
            // Program Manager Title Bar Interaction
            if (mx >= self.pm_x and mx <= self.pm_x + self.pm_w and my >= self.pm_y and my <= self.pm_y + 20) {
                // Minimize Button
                if (mx >= self.pm_x + self.pm_w - 20) {
                    self.pm_minimized = !self.pm_minimized;
                } else {
                    self.drag_active = true;
                    self.drag_offset_x = mx - self.pm_x;
                    self.drag_offset_y = my - self.pm_y;
                }
                return false;
            }
            
            // Grid Icon Interaction
            if (!self.pm_minimized) {
                const start_x = self.pm_x + 20;
                const start_y = self.pm_y + 40;
                
                for (self.icons.items, 0..) |icon, i| {
                    const col: i32 = @intCast(i % 5);
                    const row: i32 = @intCast(i / 5);
                    const icon_x = start_x + col * 100;
                    const icon_y = start_y + row * 100;
                    
                    if (mx >= icon_x and mx <= icon_x + 64 and my >= icon_y and my <= icon_y + 64) {
                        self.selected_index = i;
                        if (event.button.clicks == 2) {
                            std.debug.print("Launching: {s}\n", .{icon.exec_path});
                            var child = std.process.Child.init(&[_][]const u8{icon.exec_path}, self.allocator);
                            try child.spawn();
                        }
                        return false;
                    }
                }
            }
            self.selected_index = null;
        } else if (event.type == c.SDL_MOUSEBUTTONUP) {
            self.drag_active = false;
        } else if (event.type == c.SDL_MOUSEMOTION) {
            if (self.drag_active) {
                self.pm_x = event.motion.x - self.drag_offset_x;
                self.pm_y = event.motion.y - self.drag_offset_y;
            }
        }
        return false;
    }
    
    pub fn draw(self: *DesktopManager) void {
        const r = self.renderer;
        // Desktop Blue
        _ = c.SDL_SetRenderDrawColor(r, 0, 128, 128, 255);
        _ = c.SDL_RenderClear(r);
        
        // Program Manager Window
        const win_h = if (self.pm_minimized) 20 else self.pm_h;
        const win_rect = c.SDL_Rect{ .x = self.pm_x, .y = self.pm_y, .w = self.pm_w, .h = win_h };
        
        _ = c.SDL_SetRenderDrawColor(r, 192, 192, 192, 255);
        _ = c.SDL_RenderFillRect(r, &win_rect);
        
        // Title Bar
        _ = c.SDL_SetRenderDrawColor(r, 0, 0, 128, 255);
        const title_rect = c.SDL_Rect{ .x = self.pm_x, .y = self.pm_y, .w = self.pm_w, .h = 20 };
        _ = c.SDL_RenderFillRect(r, &title_rect);
        
        // Minimize Button
        _ = c.SDL_SetRenderDrawColor(r, 192, 192, 192, 255);
        const min_btn = c.SDL_Rect{ .x = self.pm_x + self.pm_w - 18, .y = self.pm_y + 2, .w = 16, .h = 16 };
        _ = c.SDL_RenderFillRect(r, &min_btn);
        
        // Grid Icons
        if (!self.pm_minimized) {
            const start_x = self.pm_x + 20;
            const start_y = self.pm_y + 40;
            
            for (self.icons.items, 0..) |icon, i| {
                const col: i32 = @intCast(i % 5);
                const row: i32 = @intCast(i / 5);
                const icon_x = start_x + col * 100;
                const icon_y = start_y + row * 100;
                
                const dst = c.SDL_Rect{ .x = icon_x + 16, .y = icon_y, .w = 32, .h = 32 };
                _ = c.SDL_RenderCopy(r, icon.texture, null, &dst);
                
                if (self.selected_index == i) {
                    _ = c.SDL_SetRenderDrawColor(r, 255, 255, 255, 255);
                    const border = c.SDL_Rect{ .x = icon_x, .y = icon_y - 4, .w = 64, .h = 64 };
                    _ = c.SDL_RenderDrawRect(r, &border);
                }
                
                // Label background (black area for "text")
                _ = c.SDL_SetRenderDrawColor(r, 0, 0, 0, 255);
                const label_rect = c.SDL_Rect{ .x = icon_x, .y = icon_y + 35, .w = 64, .h = 10 };
                _ = c.SDL_RenderFillRect(r, &label_rect);
            }
        }
        
        // Outer Border
        _ = c.SDL_SetRenderDrawColor(r, 0, 0, 0, 255);
        _ = c.SDL_RenderDrawRect(r, &win_rect);
        
        c.SDL_RenderPresent(r);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var desktop = try DesktopManager.init(allocator);
    defer desktop.deinit();
    
    // Grid Setup
    try desktop.addTool("Voxel", "./zig-out/bin/tlc_voxel", "assets/wall.qoi");
    try desktop.addTool("Editor", "./zig-out/bin/tlc_editor", "assets/server.qoi");
    try desktop.addTool("Game", "./zig-out/bin/tlc_at_doom", "assets/weapon.qoi");
    
    var event: c.SDL_Event = undefined;
    while (true) {
        while (c.SDL_PollEvent(&event) != 0) {
            if (try desktop.handleEvent(event)) return;
        }
        desktop.draw();
        c.SDL_Delay(16);
    }
}
