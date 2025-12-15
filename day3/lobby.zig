const std = @import("std");

pub fn main() !void {

    const file = @embedFile("./input.txt");
    var it = std.mem.tokenizeSequence(u8, file[0..], "\n");
    var result:u32 = 0;

    while (it.next()) |line| {
        std.debug.print("{any}\n", .{@TypeOf(line)});
        var buffer: [2] u8 = line[0..2].*;
        for (line[2..]) |val| {

            const b1: u8 = buffer[0] - 48;
            const b2: u8 = buffer[1] - 48;
            const b3: u8 = val - 48;
            const num_in_buff: u8 = try std.fmt.parseInt(u8, buffer[0..], 10);

            //Logic
            const upper: u8 = b1 * 10 + b3;
            const lower: u8 = b2 * 10 + b3;

            const bigger = if (upper > lower) upper else lower;

            if (bigger > num_in_buff){
                buffer[0] = 48 + (bigger / 10);
                buffer[1] = 48 + (bigger % 10);
            }




        }
        result += try std.fmt.parseInt(u8, buffer[0..], 10);
        // std.debug.print("buffer: {s}\n", .{buffer});

    }
    std.debug.print("result: {d}", .{result});
}
