const std = @import("std");

pub fn main() !void {

    const file = @embedFile("./input.txt");
    var it = std.mem.tokenizeSequence(u8, file[0..], "\n");
    var result:usize = 0;

    while (it.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        var number: [12] u8 = undefined;
        var max_index :usize = 0; //cuz findScalar returns usize
        for (0..12) |i| {
            const max = std.mem.max(u8, line[max_index..(line.len - (11-i))]);
            max_index = std.mem.findScalar(u8, line[max_index..], max).? + max_index + 1; 
            std.debug.print("{d}", .{max-48});
            number[i] = max;

        }
        std.debug.print("\n", .{});
        std.debug.print("number: {any}\n", .{number});

        result += try std.fmt.parseInt(usize, number[0..], 10);


    }
    std.debug.print("result: {d}", .{result});
}
