const std = @import("std");


pub fn main() !void {
    const file = @embedFile("./input.txt");
    var stdout_buffer: [4080]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    @setEvalBranchQuota(150_000);

    //add padding with '.' to make later stuff easier
    var comptime_fun = comptime blk: {
        var it = std.mem.tokenizeSequence(u8, file, "\n");
        const width = it.peek().?.len;

        const new_lines = std.mem.count(u8, file, "\n");
        //the last two terms are for zero padding the input
        const input_len = (file.len - new_lines) + (width + 2) * 2 + width * 2 ;

        var buffer: [input_len] u8 = [_]u8 {'.'} ** input_len;

        var start = width + 3; 
        var i = start;
        for (file) |char| {

            if (char != '\n'){
                if (i < start + width - 1){
                    buffer[i] = char;
                    i += 1;
                }else {
                    buffer[i] = char;
                    i += 3;
                    start = i;
                }
            }
        }
        
    break :blk .{
            .data = buffer,
            .width = width,
        };
    };

    //later stuff..

    var stop: u8 = 0;
    var total_count: usize = 0;
    var input_array = comptime_fun.data;
    while (stop == 0) {

        var count: usize = 0;

        const padded_w = comptime_fun.width + 2;
        for (input_array,0..) |value,index| {
            if (value == '@'){
                const upper_slice = input_array[(index - padded_w - 1)..(index - padded_w + 2)];
                const middle_slice = input_array[index-1..index+2];
                const lower_slice = input_array[(index + padded_w - 1)..(index + padded_w + 2)];

                const paper_roll_count = std.mem.count(u8, upper_slice, "@") + 
                                         std.mem.count(u8, middle_slice, "@") +
                                         std.mem.count(u8, lower_slice, "@");

                if (paper_roll_count < 5){
                    count += 1;
                    total_count += 1;
                    input_array[index] = '.';
                }

            }

        }
        stop = if (count == 0) 1 else 0;
    }

    try stdout.print("{d}", .{total_count});
    try stdout.flush();


}
