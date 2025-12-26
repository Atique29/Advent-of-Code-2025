const std = @import("std");
const file = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator(); 
    defer _ = gpa.deinit();

    @setEvalBranchQuota(50000);
    const input_len = comptime blk: {
        const newlines: usize = std.mem.countScalar(u8, file, '\n');
        break :blk file.len - newlines;
    };

    var input: [input_len] u8 = undefined; 
    var it = std.mem.tokenizeScalar(u8, file, '\n');
    const width = it.peek().?.len;
    const lines: u64 = input_len / width;
    var idx_start: usize = 0;
    while (it.next()) |line| {
        @memcpy(input[idx_start..idx_start+width], line );
        idx_start += width;
    }

    std.debug.print("{d}\n", .{width});
    
    //start tracing after the first instance of ^
    const start_idx = std.mem.findScalar(u8, &input, '^').?;
    std.debug.print("{d}\n", .{start_idx});

    //hashmap(set) to store splitter that are hit 
    var splitter_hit = std.AutoHashMap(u64, void).init(allocator);
    defer splitter_hit.deinit();
    try splitter_hit.put(start_idx, {});  //first ^ is hit
    

    var y: u64 = (start_idx / width) + 1; //start from the line after the one with start_idx
    while (y < lines):(y+=1) {
        var x: u64 = 0;
        outer: while (x < width):(x+=1){
            if (input[x + y*width] == '^'){
                //check the rows above, from y-1 to 1 (second row), between <-^-> columns to see if this splitter will be hit
                //by the beam coming from another splitter on top
                std.debug.print("found ^ @ ({d},{d})\n", .{x,y});
                var k: u64 = y - 1;
                while (k > 1):(k-=1) {
                    std.debug.print("k:{d}\n", .{k});
                    //get all three elements in this row
                    const elem_left_idx = (x-1) + k*width ;
                    const elem_left = input[elem_left_idx] ;
                    const elem_mid_idx = x + k*width ;
                    const elem_mid = input[elem_mid_idx] ;
                    const elem_right_idx = (x+1) + k*width ;
                    const elem_right = input[elem_right_idx] ;

                    //check if theres a splitter ^ directly above in this row. If true, this splitter is will not be hit
                    if (elem_mid == '^') {
                        //dont put this index on the hashmap. when checked for later, contain() will return false, implying "not hit"
                        std.debug.print("elem_mid: ({d},{d})-> k = {d}\n", .{x,y,k});
                        std.debug.print("Not a hit :( \n", .{});
                        continue :outer; //this splitter done, onto the next one

                    } else if (elem_left == '^'){

                        std.debug.print("elem_left: ({d},{d})-> k = {d}\n", .{x,y,k});
                        if (splitter_hit.contains(elem_left_idx)) { //if this one up at here was hit, the one under the scope (x,y) is also hit
                            std.debug.print("Its a hit :)\n", .{});
                            try splitter_hit.put(x + y * width, {}); //put this ^ in the set and onto the next one
                            continue :outer;
                        }
                    } else if (elem_right == '^'){ //same as above
                        std.debug.print("elem_right: ({d},{d})-> k = {d}\n", .{x,y,k});
                        if (splitter_hit.contains(elem_right_idx)) {
                            std.debug.print("Its a hit :)\n", .{});
                            try splitter_hit.put(x + y * width, {}); 
                            continue :outer;
                        }

                    }
                }




            }

        }
    }

    std.debug.print("{any}", .{splitter_hit.count()});










}
