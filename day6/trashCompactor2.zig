const std = @import("std");
const file = @embedFile("input.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var input_arr_list: std.ArrayList(u8) = .empty;
    defer input_arr_list.deinit(allocator);
    var it = std.mem.tokenizeScalar(u8, file, '\n');

    const width: u64 = it.peek().?.len;
    var lines: u64 = 0;
    while (it.next()) |line| {
        const space_replaced_line = try std.mem.replaceOwned(u8, allocator, line, " ", "0");
        try input_arr_list.appendSlice(allocator, space_replaced_line);
        lines += 1;
    }
    // std.debug.print("{s}\n", .{input_arr_list.items});
    // for (input_arr_list.items) |value| {
    //     std.debug.print("{c} ", .{(value)});
    // }

    var result: u64 = 0;
    var operator: u8 = input_arr_list.items[width*(lines-1)];
    var local_result: u64 = if (operator == '*') 1 else 0;
    for (0..width) |x| {
        const is_this_an_operator = input_arr_list.items[x + width*(lines-1)];
        operator = if (is_this_an_operator == '0') operator else is_this_an_operator; 

        var multiplier: u64 = 1;
        var number: u64 = 0;
        for (0..lines-1) |y| {
            const digit: u8 = input_arr_list.items[x + width * (lines-y-2)]; 
            if (digit != '0'){
                number += multiplier * (digit - '0');
                multiplier *= 10;
            }

        }

        if (number == 0) {
            result += local_result;
            // std.debug.print("result:{d}\n", .{result});
            local_result = if (input_arr_list.items[x + 1 + width * (lines - 1)] == '*') 1 else 0;
            continue;
        }

        local_result = if(operator == '*') local_result * number else local_result + number;
        // std.debug.print("local_result: {d}\n", .{local_result});


    }

    result += local_result;
    std.debug.print("result:{d}\n", .{result});



}

