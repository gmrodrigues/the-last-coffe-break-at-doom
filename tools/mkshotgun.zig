const std = @import("std");

pub fn main() !void {
    const sample_rate = 44100;
    const duration_sec = 0.8;
    const num_samples = @as(usize, @intFromFloat(sample_rate * duration_sec));
    
    var file = try std.fs.cwd().createFile("assets/sfx/shotgun.wav", .{});
    defer file.close();
    
    var buffer: [200000]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    const writer = fbs.writer();

    // RIFF/WAVE Headers (Omitted for brevity in scratch but mandatory in final)
    try writer.writeAll("RIFF");
    try writer.writeInt(u32, @as(u32, 36 + @as(u32, @intCast(num_samples * 2))), .little); 
    try writer.writeAll("WAVE");
    try writer.writeAll("fmt ");
    try writer.writeInt(u32, 16, .little); 
    try writer.writeInt(u16, 1, .little);  
    try writer.writeInt(u16, 1, .little);  
    try writer.writeInt(u32, sample_rate, .little);
    try writer.writeInt(u32, sample_rate * 2, .little); 
    try writer.writeInt(u16, 2, .little);  
    try writer.writeInt(u16, 16, .little); 
    try writer.writeAll("data");
    try writer.writeInt(u32, @as(u32, @intCast(num_samples * 2)), .little);

    var prng = std.Random.DefaultPrng.init(42);
    const random = prng.random();

    // Synthesis
    for (0..num_samples) |i| {
        const time = @as(f32, @floatFromInt(i)) / @as(f32, sample_rate);
        
        // Layer 1: The Mechanical "Crack" (Square Wave + Fast Noise)
        const crack_env = @exp(-80.0 * time);
        const noise = (random.float(f32) * 2.0 - 1.0);
        const square = if (std.math.sin(2.0 * std.math.pi * 200.0 * time) > 0) @as(f32, 1.0) else -1.0;
        const crack = (noise * 0.7 + square * 0.3) * crack_env;
        
        // Layer 2: The "Roar" (Sawtooth for grit)
        const roar_env = @exp(-15.0 * time);
        const saw = (2.0 * (time * 100.0 - @floor(time * 100.0 + 0.5)));
        const roar = saw * roar_env * 0.3;
        
        // Layer 3: The "Sub-Boom" (Low-freq sine)
        const boom_env = @exp(-8.0 * time);
        const boom = std.math.sin(2.0 * std.math.pi * 55.0 * time) * boom_env;
        
        // Layer 4: The "Smoke" (Lo-pass Noise)
        const hiss_env = @exp(-4.0 * time) * 0.15;
        const hiss = (random.float(f32) * 2.0 - 1.0) * hiss_env;
        
        // Mixing with Soft Clipping for "Loudness"
        const raw_mixed = (crack * 0.8 + roar * 0.4 + boom * 1.2 + hiss * 0.2);
        
        // Soft clipping approximation: x - (x^3 / 3)
        const x = std.math.clamp(raw_mixed, -1.0, 1.0);
        const soft_clipped = x - (x * x * x / 3.0);
        
        const sample = @as(i16, @intFromFloat(soft_clipped * 32767.0));
        try writer.writeInt(i16, sample, .little);
    }
    
    try file.writeAll(fbs.getWritten());
}
