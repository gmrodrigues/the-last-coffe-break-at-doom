const std = @import("std");
const assets = @import("assets.zig");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const EditorAsset = struct {
    name: [64]u8, // Fixed buffer for filename
    name_len: usize,
    sdl_texture: *c.SDL_Texture,
    width: i32,
    height: i32,
};

pub fn main() !void {
    std.debug.print("Initializing The Last Coffee Break at D.O.O.M. Content Editor...\n", .{});
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.debug.print("Failed to init SDL2 Editor: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("D.O.O.M. ASSET BROWSER", 
        c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 
        1280, 720, c.SDL_WINDOW_RESIZABLE);
    if (window == null) return error.SDLWindowFailed;
    defer c.SDL_DestroyWindow(window);

    const sdl_renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED);
    if (sdl_renderer == null) return error.SDLRendererFailed;
    defer c.SDL_DestroyRenderer(sdl_renderer);

    // Set Blend Mode to allow transparency overlay drawing properly
    _ = c.SDL_SetRenderDrawBlendMode(sdl_renderer, c.SDL_BLENDMODE_BLEND);

    // Load Assets From Disk using explicit Directory Traversing
    var loaded_assets: [1024]EditorAsset = undefined;
    var loaded_assets_len: usize = 0;
    defer {
        for (0..loaded_assets_len) |i| {
            c.SDL_DestroyTexture(loaded_assets[i].sdl_texture);
        }
    }

    var dir = std.fs.cwd().openDir("assets", .{ .iterate = true }) catch null;
    if (dir != null) {
        var iter = dir.?.iterate();
        while (try iter.next()) |entry| {
            if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".qoi")) {
                var path_buf: [1024]u8 = undefined;
                const path = try std.fmt.bufPrint(&path_buf, "assets/{s}", .{entry.name});
                
                var tex = assets.Texture.load(allocator, path) catch continue;
                defer tex.deinit(); // Free QOI uncompressed bytes after uploading them to actual GPU

                const sdl_tex = c.SDL_CreateTexture(sdl_renderer, 
                    c.SDL_PIXELFORMAT_RGBA8888, 
                    c.SDL_TEXTUREACCESS_STATIC, 
                    @intCast(tex.width), @intCast(tex.height));
                
                // Allow our .qoi pixels marked as 'blank=0x00000000' to be fully transparent on top of the black blocks
                _ = c.SDL_SetTextureBlendMode(sdl_tex, c.SDL_BLENDMODE_BLEND);

                _ = c.SDL_UpdateTexture(sdl_tex, null, tex.pixels.ptr, @intCast(tex.width * @sizeOf(u32)));
                var new_asset = EditorAsset{
                    .name = undefined,
                    .name_len = entry.name.len,
                    .sdl_texture = sdl_tex.?,
                    .width = @intCast(tex.width),
                    .height = @intCast(tex.height),
                };
                @memcpy(new_asset.name[0..entry.name.len], entry.name);
                
                if (loaded_assets_len < 1024) {
                    loaded_assets[loaded_assets_len] = new_asset;
                    loaded_assets_len += 1;
                    std.debug.print("Asset Indexed: {s} ({}x{})\n", .{entry.name, tex.width, tex.height});
                }
            }
        }
        dir.?.close();
    }

    var quit: bool = false;
    var event: c.SDL_Event = undefined;
    var selected_index: i32 = 0;

    const UPSCALE: i32 = 4; // Asset zooming
    const PADDING: i32 = 30;

    while (!quit) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => quit = true,
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_ESCAPE => quit = true,
                        c.SDLK_RIGHT => {
                            if (loaded_assets_len > 0) {
                                selected_index += 1;
                                if (selected_index >= loaded_assets_len) {
                                    selected_index = @as(i32, @intCast(loaded_assets_len)) - 1;
                                }
                            }
                        },
                        c.SDLK_LEFT => {
                            selected_index -= 1;
                            if (selected_index < 0) selected_index = 0;
                        },
                        else => {}
                    }
                },
                else => {},
            }
        }

        // Blueish gray background for the Editor app
        _ = c.SDL_SetRenderDrawColor(sdl_renderer, 45, 55, 65, 255);
        _ = c.SDL_RenderClear(sdl_renderer);

        var draw_x: i32 = 50;
        var draw_y: i32 = 100;
        var row_max_h: i32 = 0;

        for (loaded_assets[0..loaded_assets_len], 0..) |asset, i| {
            const dest_w = asset.width * UPSCALE;
            const dest_h = asset.height * UPSCALE;
            
            if (draw_x + dest_w + PADDING > 1280) {
                draw_x = 50;
                draw_y += row_max_h + PADDING * 3;
                row_max_h = 0;
            }
            if (dest_h > row_max_h) row_max_h = dest_h;

            const rect = c.SDL_Rect{ .x = draw_x, .y = draw_y, .w = dest_w, .h = dest_h };

            // Highlight the currently selected object using Arrows
            if (i == selected_index) {
                _ = c.SDL_SetRenderDrawColor(sdl_renderer, 230, 200, 50, 255); // Yellow
                const sel_rect = c.SDL_Rect{ .x = draw_x - 5, .y = draw_y - 5, .w = dest_w + 10, .h = dest_h + 10 };
                _ = c.SDL_RenderFillRect(sdl_renderer, &sel_rect);
            }

            // Dark framing around the pure transparency limits so pixel arts stand out from the grid bg
            _ = c.SDL_SetRenderDrawColor(sdl_renderer, 20, 25, 30, 255);
            _ = c.SDL_RenderFillRect(sdl_renderer, &rect);

            _ = c.SDL_RenderCopy(sdl_renderer, asset.sdl_texture, null, &rect);

            draw_x += dest_w + PADDING;
        }

        c.SDL_RenderPresent(sdl_renderer);
        c.SDL_Delay(16);
    }
}
