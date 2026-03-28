const std = @import("std");

pub fn main() !void {
    const sample_rate = 22050; // Lo-fi retro standard
    const duration_sec = 10.0;
    const num_samples = @as(usize, @intFromFloat(sample_rate * duration_sec));
    
    var file = try std.fs.cwd().createFile("assets/music/corporate_dread.wav", .{});
    defer file.close();
    
    var buffer: [500000]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    const w = fbs.writer();

    // RIFF Header
    try w.writeAll("RIFF");
    try w.writeInt(u32, @as(u32, 36 + @as(u32, @intCast(num_samples * 2))), .little); 
    try w.writeAll("WAVEfmt ");
    try w.writeInt(u32, 16, .little); 
    try w.writeInt(u16, 1, .little);  // AudioFormat (PCM)
    try w.writeInt(u16, 1, .little);  // NumChannels
    try w.writeInt(u32, sample_rate, .little);
    try w.writeInt(u32, sample_rate * 2, .little); // ByteRate
    try w.writeInt(u16, 2, .little);  // BlockAlign
    try w.writeInt(u16, 16, .little); // BitsPerSample
    
    // data subchunk
    try w.writeAll("data");
    try w.writeInt(u32, @as(u32, @intCast(num_samples * 2)), .little);

    for (0..num_samples) |t| {
        // Bytebeat-inspired math for 90s industrial/corporate vibes
        const bytebeat = (t * ((t >> 9) | (t >> 11))) & (t >> 5);
        const sample_f = @as(f32, @floatFromInt(bytebeat & 0xFF)) / 128.0 - 1.0;
        
        // Add a "Pulse" bass layer
        const time = @as(f32, @floatFromInt(t)) / @as(f32, sample_rate);
        const bass_freq = 55.0;
        const bass = std.math.sin(2.0 * std.math.pi * bass_freq * time);
        
        const mixed = (sample_f * 0.4 + bass * 0.6);
        const sample_i16 = @as(i16, @intFromFloat(std.math.clamp(mixed, -1.0, 1.0) * 20000.0));
        try w.writeInt(i16, sample_i16, .little);
    }
    
    try file.writeAll(fbs.getWritten());
}
