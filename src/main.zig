const std = @import("std");
const entities = @import("entities.zig");
const renderer = @import("renderer.zig");
const assets = @import("assets.zig");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    std.debug.print("Initializing 'The Last Coffee Break at D.O.O.M.'...\n", .{});
    
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.debug.print("Failed to initialize SDL2: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window_scale = 3; 
    const win_width = renderer.SCREEN_WIDTH * window_scale;
    const win_height = renderer.SCREEN_HEIGHT * window_scale;

    const window = c.SDL_CreateWindow("The Last Coffee Break at D.O.O.M.", 
        c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 
        win_width, win_height, 0);
    if (window == null) return error.SDLWindowCreationFailed;
    defer c.SDL_DestroyWindow(window);

    const sdl_renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED);
    if (sdl_renderer == null) return error.SDLRendererCreationFailed;
    defer c.SDL_DestroyRenderer(sdl_renderer);

    const texture = c.SDL_CreateTexture(sdl_renderer, 
        c.SDL_PIXELFORMAT_RGBA8888, 
        c.SDL_TEXTUREACCESS_STREAMING, 
        renderer.SCREEN_WIDTH, renderer.SCREEN_HEIGHT);
    if (texture == null) return error.SDLTextureCreationFailed;
    defer c.SDL_DestroyTexture(texture);
    
    const main_slayer = entities.Slayer{};
    std.debug.print("Slayer Ready. Age: {d}. Good luck.\n", .{main_slayer.age});
    
    // Map with a big room in the middle for our Server
    const map_data = [_]u8{
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1, // Central space
        1, 0, 0, 1, 1, 0, 0, 1, 1, 1,
        1, 0, 0, 1, 2, 0, 0, 1, 2, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    };
    
    const map = renderer.Map{
        .width = 10,
        .height = 10,
        .data = &map_data,
    };
    
    // Load Textures from Disk
    var wall_tex = try assets.Texture.load(allocator, "assets/wall.qoi");
    defer wall_tex.deinit();
    var server_tex = try assets.Texture.load(allocator, "assets/server.qoi");
    defer server_tex.deinit();
    var weapon_tex = try assets.Texture.load(allocator, "assets/weapon.qoi");
    defer weapon_tex.deinit();
    var flash_tex = try assets.Texture.load(allocator, "assets/flash.qoi");
    defer flash_tex.deinit();
    
    var render_target = renderer.Renderer{
        .map = map,
        .buffer = undefined,   
        .z_buffer = undefined,
        .wall_texture = &wall_tex,
    };
    
    var camera = renderer.Camera{
        .x = 2.5,
        .y = 2.5,
        .dir_x = -1.0,
        .dir_y = 0.0,
        .plane_x = 0.0,
        .plane_y = 0.66,
    };

    // Instantiate Sprites
    const server_sprite = renderer.Sprite{
        .x = 5.5,
        .y = 4.5,
        .texture = &server_tex,
    };
    const scene_sprites = [_]renderer.Sprite{server_sprite};
    
    var quit: bool = false;
    var event: c.SDL_Event = undefined;

    const move_speed: f32 = 0.05;
    const rot_speed: f32 = 0.03;
    var is_firing: bool = false;
    var fire_frames: u32 = 0; // Control animation timer

    while (!quit) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => quit = true,
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_ESCAPE => quit = true,
                        c.SDLK_SPACE => {
                            is_firing = true;
                            fire_frames = 10; // Lasts ~10 frames
                        },
                        else => {}
                    }
                },
                else => {},
            }
        }

        const keystates = c.SDL_GetKeyboardState(null);
        if (keystates[c.SDL_SCANCODE_W] != 0) {
            camera.x += camera.dir_x * move_speed;
            camera.y += camera.dir_y * move_speed;
        }
        if (keystates[c.SDL_SCANCODE_S] != 0) {
            camera.x -= camera.dir_x * move_speed;
            camera.y -= camera.dir_y * move_speed;
        }
        if (keystates[c.SDL_SCANCODE_A] != 0) {
            const old_dir_x = camera.dir_x;
            camera.dir_x = camera.dir_x * @cos(rot_speed) - camera.dir_y * @sin(rot_speed);
            camera.dir_y = old_dir_x * @sin(rot_speed) + camera.dir_y * @cos(rot_speed);
            const old_plane_x = camera.plane_x;
            camera.plane_x = camera.plane_x * @cos(rot_speed) - camera.plane_y * @sin(rot_speed);
            camera.plane_y = old_plane_x * @sin(rot_speed) + camera.plane_y * @cos(rot_speed);
        }
        if (keystates[c.SDL_SCANCODE_D] != 0) {
            const old_dir_x = camera.dir_x;
            camera.dir_x = camera.dir_x * @cos(-rot_speed) - camera.dir_y * @sin(-rot_speed);
            camera.dir_y = old_dir_x * @sin(-rot_speed) + camera.dir_y * @cos(-rot_speed);
            const old_plane_x = camera.plane_x;
            camera.plane_x = camera.plane_x * @cos(-rot_speed) - camera.plane_y * @sin(-rot_speed);
            camera.plane_y = old_plane_x * @sin(-rot_speed) + camera.plane_y * @cos(-rot_speed);
        }

        // Firing logic / animation cooldown
        if (fire_frames > 0) {
            fire_frames -= 1;
        } else {
            is_firing = false;
        }

        const frame_allocator = arena.allocator();
        _ = frame_allocator; 
        
        // 1. Render World
        render_target.renderFrame(camera, &scene_sprites);
        
        // 2. Render UI (Weapon overlay)
        render_target.renderWeaponOverlay(&weapon_tex, &flash_tex, is_firing);
        
        // Push pixels
        _ = c.SDL_UpdateTexture(texture, null, &render_target.buffer, renderer.SCREEN_WIDTH * @sizeOf(u32));
        _ = c.SDL_RenderClear(sdl_renderer);
        _ = c.SDL_RenderCopy(sdl_renderer, texture, null, null);
        c.SDL_RenderPresent(sdl_renderer);

        _ = arena.reset(.retain_capacity);
        
        c.SDL_Delay(16); // roughly 60 FPS
    }
}
