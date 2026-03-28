const std = @import("std");
const qoi = @import("qoi.zig");

pub const AssetProxy = struct {
    allocator: std.mem.Allocator,

    pub fn loadOrConvert(self: AssetProxy, path: []const u8) !qoi.QoiImage {
        // 1. If it's already a .qoi path, load it directly
        if (std.mem.endsWith(u8, path, ".qoi")) {
            const data = try std.fs.cwd().readFileAlloc(self.allocator, path, 1024 * 1024 * 10);
            defer self.allocator.free(data);
            return try qoi.decode(self.allocator, data);
        }

        // 2. If it's a .png, check for a cached .qoi
        if (std.mem.endsWith(u8, path, ".png")) {
            const qoi_path = try std.fmt.allocPrint(self.allocator, "{s}.qoi", .{path[0..path.len-4]});
            defer self.allocator.free(qoi_path);

            if (self.isCacheValid(path, qoi_path)) {
                std.debug.print("AssetProxy: Loading cached {s}\n", .{qoi_path});
                const data = try std.fs.cwd().readFileAlloc(self.allocator, qoi_path, 1024 * 1024 * 10);
                defer self.allocator.free(data);
                return try qoi.decode(self.allocator, data);
            }

            // 3. Conversion needed
            std.debug.print("AssetProxy: Converting {s} to QOI...\n", .{path});
            return try self.convertPngToQoi(path, qoi_path);
        }

        return error.UnsupportedAssetFormat;
    }

    fn isCacheValid(self: AssetProxy, src: []const u8, cache: []const u8) bool {
        _ = self;
        const src_stat = std.fs.cwd().statFile(src) catch return false;
        const cache_stat = std.fs.cwd().statFile(cache) catch return false;
        return cache_stat.mtime >= src_stat.mtime;
    }

    fn convertPngToQoi(self: AssetProxy, src: []const u8, cache: []const u8) !qoi.QoiImage {
        const rgba_tmp = try std.fmt.allocPrint(self.allocator, "{s}.rgba", .{src});
        defer self.allocator.free(rgba_tmp);

        const rgba_arg = try std.fmt.allocPrint(self.allocator, "RGBA:{s}", .{rgba_tmp});
        defer self.allocator.free(rgba_arg);

        // Run ImageMagick: convert src.png -depth 8 RGBA:src.rgba
        var child = std.process.Child.init(&[_][]const u8{
            "convert", src, "-depth", "8", rgba_arg,
        }, self.allocator);
        
        const term = try child.spawnAndWait();
        if (term != .Exited or term.Exited != 0) return error.ImageMagickFailed;

        // Read RGBA pixels
        const rgba_data = try std.fs.cwd().readFileAlloc(self.allocator, rgba_tmp, 1024 * 1024 * 50);
        defer self.allocator.free(rgba_data);
        defer std.fs.cwd().deleteFile(rgba_tmp) catch {};

        // Get Dimensions via identify
        var dim_child = std.process.Child.init(&[_][]const u8{
            "identify", "-format", "%w %h", src,
        }, self.allocator);
        dim_child.stdout_behavior = .Pipe;
        try dim_child.spawn();
        
        const out = try dim_child.stdout.?.readToEndAlloc(self.allocator, 1024);
        defer self.allocator.free(out);
        _ = try dim_child.wait();

        var dim_iter = std.mem.tokenizeAny(u8, out, " \n\r");
        const w = try std.fmt.parseInt(u32, dim_iter.next().?, 10);
        const h = try std.fmt.parseInt(u32, dim_iter.next().?, 10);

        // Convert byte buffer to u32 pixels (RGBA8888)
        const pixels = try self.allocator.alloc(u32, w * h);
        for (0..w*h) |i| {
            const r = rgba_data[i * 4 + 0];
            const g = rgba_data[i * 4 + 1];
            const b = rgba_data[i * 4 + 2];
            const a = rgba_data[i * 4 + 3];
            pixels[i] = (@as(u32, r) << 24) | (@as(u32, g) << 16) | (@as(u32, b) << 8) | a;
        }

        // Encode to QOI & Cache
        const qoi_data = try qoi.encode(self.allocator, w, h, pixels);
        defer self.allocator.free(qoi_data);
        try std.fs.cwd().writeFile(.{ .sub_path = cache, .data = qoi_data });

        return qoi.QoiImage{
            .width = w,
            .height = h,
            .pixels = pixels,
            .allocator = self.allocator,
        };
    }
};
