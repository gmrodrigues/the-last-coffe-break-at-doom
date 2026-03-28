const std = @import("std");
const qoi = @import("qoi.zig");
const AssetProxy = @import("asset_proxy.zig").AssetProxy;
const font = @import("font.zig");

// SDL2 Bindings
const c = @import("sdl.zig").c;

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
    pm_w: i32 = 950,
    pm_h: i32 = 600,
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
            1024, 768,
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
            self.allocator.free(icon.name);
            self.allocator.free(icon.exec_path);
        }
        self.icons.deinit(self.allocator);
        c.SDL_DestroyRenderer(self.renderer);
        c.SDL_DestroyWindow(self.window);
        c.SDL_Quit();
    }
    
    pub fn loadTools(self: *DesktopManager, path: []const u8) !void {
        const file_content = try std.fs.cwd().readFileAlloc(self.allocator, path, 1024 * 1024);
        defer self.allocator.free(file_content);
        
        var iter = std.mem.tokenizeAny(u8, file_content, "\r\n");
        var current_name: ?[]const u8 = null;
        var current_icon: ?[]const u8 = null;
        var current_exec: ?[]const u8 = null;
        
        while (iter.next()) |line| {
            const trimmed = std.mem.trimLeft(u8, line, " -");
            if (std.mem.startsWith(u8, trimmed, "name:")) {
                current_name = std.mem.trim(u8, trimmed[5..], " \"");
            } else if (std.mem.startsWith(u8, trimmed, "icon:")) {
                current_icon = std.mem.trim(u8, trimmed[5..], " \"");
            } else if (std.mem.startsWith(u8, trimmed, "exec:")) {
                current_exec = std.mem.trim(u8, trimmed[5..], " \"");
            }
            
            if (current_name != null and current_icon != null and current_exec != null) {
                try self.addTool(
                    try self.allocator.dupe(u8, current_name.?),
                    try self.allocator.dupe(u8, current_exec.?),
                    current_icon.?
                );
                current_name = null; current_icon = null; current_exec = null;
            }
        }
    }
    
    fn addTool(self: *DesktopManager, name: []const u8, path: []const u8, icon_path: []const u8) !void {
        const proxy = @import("asset_proxy.zig").AssetProxy{ .allocator = self.allocator };
        const image = try proxy.loadOrConvert(icon_path);
        defer image.deinit();
        
        const texture = c.SDL_CreateTexture(
            self.renderer,
            c.SDL_PIXELFORMAT_RGBA8888, // Switched back for high fidelity with 0xRRGGBBAA
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
                const start_x = self.pm_x + 80;
                const start_y = self.pm_y + 40;
                
                for (self.icons.items, 0..) |icon, i| {
                    const col: i32 = @intCast(i % 4);
                    const row: i32 = @intCast(i / 4);
                    const icon_x = start_x + col * 240;
                    const icon_y = start_y + row * 160;
                    
                    if (mx >= icon_x and mx <= icon_x + 96 and my >= icon_y and my <= icon_y + 96) {
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
        
        // Window
        const win_h = if (self.pm_minimized) 20 else self.pm_h;
        const win_rect = c.SDL_Rect{ .x = self.pm_x, .y = self.pm_y, .w = self.pm_w, .h = win_h };
        
        _ = c.SDL_SetRenderDrawColor(r, 192, 192, 192, 255);
        _ = c.SDL_RenderFillRect(r, &win_rect);
        
        // Title Bar
        _ = c.SDL_SetRenderDrawColor(r, 0, 0, 128, 255);
        const title_rect = c.SDL_Rect{ .x = self.pm_x, .y = self.pm_y, .w = self.pm_w, .h = 20 };
        _ = c.SDL_RenderFillRect(r, &title_rect);
        
        // Grid
        if (!self.pm_minimized) {
            const start_x = self.pm_x + 80;
            const start_y = self.pm_y + 40;
            
            for (self.icons.items, 0..) |icon, i| {
                const col: i32 = @intCast(i % 4);
                const row: i32 = @intCast(i / 4);
                const icon_x = start_x + col * 240;
                const icon_y = start_y + row * 160;
                
                const dst = c.SDL_Rect{ .x = icon_x, .y = icon_y, .w = 96, .h = 96 };
                _ = c.SDL_RenderCopy(r, icon.texture, null, &dst);
                
                if (self.selected_index == i) {
                    _ = c.SDL_SetRenderDrawColor(r, 255, 255, 255, 255);
                    const border = c.SDL_Rect{ .x = icon_x - 4, .y = icon_y - 4, .w = 104, .h = 104 };
                    _ = c.SDL_RenderDrawRect(r, &border);
                }
                
                // Label
                _ = c.SDL_SetRenderDrawColor(r, 0, 0, 0, 255);
                const label_w: i32 = @intCast(icon.name.len * 8 * 2); // 8px * 2x scale
                const label_x = icon_x + 48 - @divTrunc(label_w, 2);
                
                const label_bg = c.SDL_Rect{ .x = label_x - 4, .y = icon_y + 100, .w = label_w + 8, .h = 20 };
                _ = c.SDL_RenderFillRect(r, &label_bg);
                _ = c.SDL_SetRenderDrawColor(r, 255, 255, 255, 255);
                font.drawText(r, icon.name, label_x, icon_y + 102, 2);
            }
        }
        
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
    
    // Load metadata
    try desktop.loadTools("assets/tools.yaml");
    
    var event: c.SDL_Event = undefined;
    while (true) {
        while (c.SDL_PollEvent(&event) != 0) {
            if (try desktop.handleEvent(event)) return;
        }
        desktop.draw();
        c.SDL_Delay(16);
    }
}
