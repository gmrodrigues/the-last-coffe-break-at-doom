const std = @import("std");
const qoi = @import("qoi.zig");

pub const Texture = struct {
    width: usize,
    height: usize,
    pixels: []u32,
    qoi_image: qoi.QoiImage,
    
    pub fn load(allocator: std.mem.Allocator, path: []const u8) !Texture {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        
        const file_size = try file.getEndPos();
        const buffer = try allocator.alloc(u8, file_size);
        defer allocator.free(buffer);
        
        _ = try file.readAll(buffer);
        const qimage = try qoi.decode(allocator, buffer);
        
        return Texture{
            .width = qimage.width,
            .height = qimage.height,
            .pixels = qimage.pixels,
            .qoi_image = qimage,
        };
    }

    pub fn deinit(self: *Texture) void {
        self.qoi_image.deinit();
    }
    
    pub fn get(self: Texture, x: usize, y: usize) u32 {
        if (x >= self.width or y >= self.height) return 0;
        return self.pixels[y * self.width + x];
    }
};
