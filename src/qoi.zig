const std = @import("std");

pub const QoiImage = struct {
    width: u32,
    height: u32,
    pixels: []u32, // RGBA format 0xRRGGBBAA
    allocator: std.mem.Allocator,

    pub fn deinit(self: QoiImage) void {
        self.allocator.free(self.pixels);
    }
};

const QOI_OP_INDEX  = 0x00;
const QOI_OP_DIFF   = 0x40;
const QOI_OP_LUMA   = 0x80;
const QOI_OP_RUN    = 0xc0;
const QOI_OP_RGB    = 0xfe;
const QOI_OP_RGBA   = 0xff;
const QOI_MASK_2    = 0xc0;

pub fn decode(allocator: std.mem.Allocator, data: []const u8) !QoiImage {
    if (data.len < 14) return error.InvalidQOI;
    if (data[0] != 'q' or data[1] != 'o' or data[2] != 'i' or data[3] != 'f') return error.InvalidQOI;

    var stream = std.io.fixedBufferStream(data);
    var reader = stream.reader();
    _ = try reader.readBytesNoEof(4); // skip magic
    
    const width = try reader.readInt(u32, .big);
    const height = try reader.readInt(u32, .big);
    const channels = try reader.readByte();
    _ = try reader.readByte(); // colorspace
    _ = channels; 

    const total_pixels = width * height;
    var pixels = try allocator.alloc(u32, total_pixels);
    errdefer allocator.free(pixels);

    var index = [_]u32{0} ** 64;
    var r: u32 = 0;
    var g: u32 = 0;
    var b: u32 = 0;
    var a: u32 = 255;

    var p: usize = 0;
    while (p < total_pixels) {
        const b1 = try reader.readByte();

        if (b1 == QOI_OP_RGB) {
            r = try reader.readByte();
            g = try reader.readByte();
            b = try reader.readByte();
        } else if (b1 == QOI_OP_RGBA) {
            r = try reader.readByte();
            g = try reader.readByte();
            b = try reader.readByte();
            a = try reader.readByte();
        } else if ((b1 & QOI_MASK_2) == QOI_OP_INDEX) {
            const idx = b1;
            const px = index[idx];
            r = (px >> 24) & 0xFF;
            g = (px >> 16) & 0xFF;
            b = (px >> 8) & 0xFF;
            a = px & 0xFF;
        } else if ((b1 & QOI_MASK_2) == QOI_OP_DIFF) {
            r = (r +% ((b1 >> 4) & 0x03) -% 2) & 0xFF;
            g = (g +% ((b1 >> 2) & 0x03) -% 2) & 0xFF;
            b = (b +% (b1 & 0x03) -% 2) & 0xFF;
        } else if ((b1 & QOI_MASK_2) == QOI_OP_LUMA) {
            const b2 = try reader.readByte();
            const vg = ((b1 & 0x3F) -% 32);
            r = (r +% vg -% 8 +% ((b2 >> 4) & 0x0F)) & 0xFF;
            g = (g +% vg) & 0xFF;
            b = (b +% vg -% 8 +% (b2 & 0x0F)) & 0xFF;
        } else if ((b1 & QOI_MASK_2) == QOI_OP_RUN) {
            const run = (b1 & 0x3F);
            const px = (r << 24) | (g << 16) | (b << 8) | a;
            for (0..run) |_| {
                if (p < total_pixels) {
                    pixels[p] = px;
                    p += 1;
                }
            }
        }

        const px = (r << 24) | (g << 16) | (b << 8) | a;
        index[(r *% 3 +% g *% 5 +% b *% 7 +% a *% 11) % 64] = px;
        
        if (p < total_pixels) {
            pixels[p] = px;
            p += 1;
        }
    }

    return QoiImage{ .width = width, .height = height, .pixels = pixels, .allocator = allocator };
}

pub fn encode(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u32) ![]u8 {
    const total_pixels = width * height;
    const out_size = 14 + (total_pixels * 5) + 8;
    var out = try allocator.alloc(u8, out_size);
    
    @memcpy(out[0..4], "qoif");
    out[4] = @intCast((width >> 24) & 0xFF);
    out[5] = @intCast((width >> 16) & 0xFF);
    out[6] = @intCast((width >> 8) & 0xFF);
    out[7] = @intCast(width & 0xFF);
    out[8] = @intCast((height >> 24) & 0xFF);
    out[9] = @intCast((height >> 16) & 0xFF);
    out[10] = @intCast((height >> 8) & 0xFF);
    out[11] = @intCast(height & 0xFF);
    out[12] = 4; 
    out[13] = 0; 
    
    var p: usize = 14;
    for (pixels) |px| {
        out[p] = 0xff; // OP_RGBA
        out[p+1] = @intCast((px >> 24) & 0xFF);
        out[p+2] = @intCast((px >> 16) & 0xFF);
        out[p+3] = @intCast((px >> 8) & 0xFF);
        out[p+4] = @intCast(px & 0xFF);
        p += 5;
    }
    
    @memcpy(out[p..p+8], &[_]u8{0,0,0,0,0,0,0,1});
    return out;
}
