const std = @import("std");

fn write(b: []u8, p: *usize, data: []const u8) void {
    @memcpy(b[p.* .. p.* + data.len], data);
    p.* += data.len;
}
fn writeByte(b: []u8, p: *usize, val: u8) void {
    b[p.*] = val;
    p.* += 1;
}
fn writeU16LE(b: []u8, p: *usize, val: u16) void {
    std.mem.writeInt(u16, b[p.* .. p.* + 2][0..2], val, .little);
    p.* += 2;
}

const Packer = struct {
    fn pack(c: u16, size: u5, bb: *u32, bc: *u5, b: []u8, bp: *usize) void {
        bb.* |= @as(u32, c) << bc.*;
        bc.* += size;
        while (bc.* >= 8) {
            b[bp.*] = @intCast(bb.* & 0xFF);
            bp.* += 1;
            bb.* >>= 8;
            bc.* -= 8;
        }
    }
};

/// Minimal GIF89a encoder for Voxel Forge.
pub fn encode(allocator: std.mem.Allocator, w: u16, h: u16, frames: [][]const u8, palette: []const u32) ![]u8 {
    const frame_size = 1024 + (w * h * 2); 
    const total_est = 2048 + (frames.len * frame_size);
    var out = try allocator.alloc(u8, total_est);
    var pos: usize = 0;

    // 1. Header
    write(out, &pos, "GIF89a");

    // 2. Logical Screen Descriptor
    writeU16LE(out, &pos, w);
    writeU16LE(out, &pos, h);
    writeByte(out, &pos, 0xF2); 
    writeByte(out, &pos, 0); 
    writeByte(out, &pos, 0); 

    // 3. Global Color Table
    for (0..8) |i| {
        const c = if (i < palette.len) palette[i] else 0;
        writeByte(out, &pos, @intCast((c >> 24) & 0xFF));
        writeByte(out, &pos, @intCast((c >> 16) & 0xFF));
        writeByte(out, &pos, @intCast((c >> 8) & 0xFF));
    }

    // 4. Netscape Looping Extension
    write(out, &pos, "\x21\xFF\x0B" ++ "NETSCAPE2.0" ++ "\x03\x01\x00\x00\x00");

    // 5. Frames
    for (frames) |pixels| {
        write(out, &pos, "\x21\xF9\x04\x04\x0A\x00\x00\x00");

        writeByte(out, &pos, 0x2C);
        writeU16LE(out, &pos, 0); 
        writeU16LE(out, &pos, 0); 
        writeU16LE(out, &pos, w);
        writeU16LE(out, &pos, h);
        writeByte(out, &pos, 0); 

        const lzw_min_code_size: u8 = 3; 
        writeByte(out, &pos, lzw_min_code_size);

        var bit_buf: u32 = 0;
        var bit_count: u5 = 0;
        
        var block = try allocator.alloc(u8, w * h * 2);
        defer allocator.free(block);
        var bpos: usize = 0;

        const clear_code: u16 = 8;
        const eoi_code: u16 = 9;
        const code_size: u5 = 4;

        Packer.pack(clear_code, code_size, &bit_buf, &bit_count, block, &bpos);
        for (pixels) |p| {
            Packer.pack(p, code_size, &bit_buf, &bit_count, block, &bpos);
        }
        Packer.pack(eoi_code, code_size, &bit_buf, &bit_count, block, &bpos);
        if (bit_count > 0) {
            block[bpos] = @intCast(bit_buf & 0xFF);
            bpos += 1;
        }

        var chip: usize = 0;
        while (chip < bpos) {
            const chunk_size = @min(255, bpos - chip);
            writeByte(out, &pos, @intCast(chunk_size));
            write(out, &pos, block[chip .. chip + chunk_size]);
            chip += chunk_size;
        }
        writeByte(out, &pos, 0); 
    }

    // 6. Trailer
    writeByte(out, &pos, 0x3B);

    return out[0..pos];
}
