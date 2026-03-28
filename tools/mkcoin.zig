const std = @import("std");

pub fn main() !void {
    const sample_rate = 44100;
    const duration_sec = 0.5;
    const num_samples = @as(usize, @intFromFloat(sample_rate * duration_sec));
    
    var file = try std.fs.cwd().createFile("assets/sfx/coin.wav", .{});
    defer file.close();
    
    var buffer: [100000]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    const writer = fbs.writer();

    // RIFF Header
    try writer.writeAll("RIFF");
    try writer.writeInt(u32, @as(u32, 36 + @as(u32, @intCast(num_samples * 2))), .little); // Total size
    try writer.writeAll("WAVE");
    
    // fmt subchunk
    try writer.writeAll("fmt ");
    try writer.writeInt(u32, 16, .little); // Subchunk1Size
    try writer.writeInt(u16, 1, .little);  // AudioFormat (PCM)
    try writer.writeInt(u16, 1, .little);  // NumChannels
    try writer.writeInt(u32, sample_rate, .little);
    try writer.writeInt(u32, sample_rate * 2, .little); // ByteRate
    try writer.writeInt(u16, 2, .little);  // BlockAlign
    try writer.writeInt(u16, 16, .little); // BitsPerSample
    
    // data subchunk
    try writer.writeAll("data");
    try writer.writeInt(u32, @as(u32, @intCast(num_samples * 2)), .little);

    // Synthesis
    for (0..num_samples) |i| {
        const time = @as(f32, @floatFromInt(i)) / @as(f32, sample_rate);
        
        // Two oscillators for "ping"
        const f1: f32 = 1200.0;
        const f2: f32 = 1800.0;
        
        // Exponential decay
        const envelope = @exp(-8.0 * time);
        
        const wave = 0.6 * std.math.sin(2.0 * std.math.pi * f1 * time) + 
                     0.4 * std.math.sin(2.0 * std.math.pi * f2 * time);
        
        const sample = @as(i16, @intFromFloat(wave * envelope * 32767.0));
        try writer.writeInt(i16, sample, .little);
    }
    
    try file.writeAll(fbs.getWritten());
}
