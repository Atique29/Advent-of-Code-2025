const std = @import("std");

pub fn main()!void{
    const file = @embedFile("./input.txt");

    @setEvalBranchQuota(5000000);
    const input_len = comptime blk: {
        var it0 = std.mem.tokenizeAny(u8, file, " \n ");
        var len = 0;
        while (it0.next()) |val|{
            _ = val;
            len += 1;
        }
        break :blk len;
    };

    var input: [input_len] u64 = undefined;
    var it = std.mem.tokenizeAny(u8, file, " \n ");
    var j: usize = 0;
    while (it.next()) |val| {
        //not handling cases cuz..
        //learning how to catch em :)
        input[j] = std.fmt.parseInt(u64, val, 10) catch |err| blk1: {
            if (err == error.InvalidCharacter){
                const res = if (std.mem.eql(u8, val, "*")) @as(u64, 42) else @as(u64, 43);
                break :blk1 res;
            }else {
                return err;
            }
        };

        j += 1;
    }

    const lines: usize  =  std.mem.count(u8, file, "\n");
    const width: usize = input_len / lines;

    //Logic
    // std.debug.print("{d}:{d}\n", .{input_params[0],lines});
    var result: usize = 0;
    for (0..width) |x| {
        var preli_result: usize = 0;
        const operator: u64 =  input[x + width * (lines - 1)];
        var i: usize = 0;
        if (operator == 43){
            while (i < lines - 1): (i+=1) {
                preli_result += input[x + i * width];
            }
        }else {
            var preli_result_2: usize = 1;
            while (i < lines - 1): (i+=1) {
                preli_result_2 *= input[x + i * width];
            }
            preli_result = preli_result_2;
        }

        result += preli_result;

    }

    std.debug.print("RES {d}\n", .{result});

}
