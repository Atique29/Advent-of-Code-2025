const std = @import("std");

pub fn main() !void {

    var stdout_buffer: [4084]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const filename = "./input.txt";
    const file = try std.fs.cwd().openFile(filename, .{.mode = .read_only});
    defer file.close();
    var read_buf: [1024]u8 = undefined;
    var file_reader: std.fs.File.Reader = file.reader(&read_buf);


    while (try file_reader.interface.takeDelimiter('\n')) |line| {

        var it1 = std.mem.splitScalar(u8, line, ',');
        var result: u100 = 0;
        while (it1.next()) |range| {
            var it2 = std.mem.splitScalar(u8, range, '-');
            const start_str: []const u8 = it2.next().?;
            const stop_str: []const u8 = it2.next().?;
            const start: u64 = try std.fmt.parseInt(u64, start_str, 10);
            const stop:  u64 = try std.fmt.parseInt(u64, stop_str, 10);
            // std.debug.print("{d}-{d}\n", .{start,stop});

            var i: u64 = start;
            while (i <= stop) {
                const number_of_digits: u64 = (std.math.log10_int(i) + 1); 

                //skip if #digits is odd
                if (number_of_digits % 2 != 0){ 
                    i += 1;
                    continue;
                }

                const zeroes: u64 = std.math.pow(u64, 10, number_of_digits / 2);
                const left_half: u64 = i / zeroes; 
                const right_half: u64 = i % zeroes; 

                if (left_half == right_half){
                    // std.debug.print("number:{d}\n", .{i});
                    // try stdout.print("start: {d} -- number: {d}\n", .{start, i});
                    // try stdout.flush();
                    result += i;
                }

                i += 1;
            }

        }

        try stdout.print("result: {d}\n", .{result});
        try stdout.flush();
    }

}
