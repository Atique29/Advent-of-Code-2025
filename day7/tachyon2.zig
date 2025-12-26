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

    //hashmap to store splitter that are hit and the number of paths to them 
    var splitter_state = std.AutoHashMap(u64, u64).init(allocator);
    defer splitter_state.deinit();
    try splitter_state.put(start_idx, 1);  //first ^ is hit, path count starts with 1
    

    var y: u64 = (start_idx / width) + 1; //start from the line after the one with start_idx
    while (y < lines):(y+=1) {
        var x: u64 = 0;
        outer: while (x < width):(x+=1){
            if (input[x + y*width] == '^'){
                //check the rows above, from y-1 to 1 (second row), between <-^-> columns to see if this splitter will be hit
                //by the beam coming from another splitter on top
                std.debug.print("found ^ @ ({d},{d})\n", .{x,y});
                std.debug.print("init ({d},{d}) with 0 paths \n", .{x,y});
                try splitter_state.put(x + y*width, 0);
                var k: u64 = y - 1;
                while (k > 1):(k-=1) {
                    std.debug.print("iteraring at row k = {d}\n", .{k});
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
                        std.debug.print("Not a hit :( \n Onto the next ^ \n", .{});
                        continue :outer; //this splitter done, onto the next one

                    } 

                    if (elem_left == '^'){

                        std.debug.print("elem_left: ({d},{d})-> k = {d}\n", .{x,y,k});
                        if (splitter_state.contains(elem_left_idx)) { //if this one up at here was hit, the one under the scope (x,y) is also hit
                            std.debug.print("Its a hit :)\n", .{});
                            std.debug.print("Inheriting {d} paths from ({d},{d}) \n", .{splitter_state.get(elem_left_idx).?, x-1,k});
                            const add_paths_from_elem_left = splitter_state.get(elem_left_idx).? + splitter_state.get(x + y*width).?;
                            try splitter_state.put(x + y * width, add_paths_from_elem_left ); //put this ^ in the set and onto the next one
                            // continue :outer;
                        }
                    } 

                    if (elem_right == '^'){ //same as above
                        std.debug.print("elem_right: ({d},{d})-> k = {d}\n", .{x,y,k});
                        if (splitter_state.contains(elem_right_idx)) {
                            std.debug.print("Its a hit :)\n", .{});
                            std.debug.print("Inheriting {d} paths from ({d},{d}) \n", .{splitter_state.get(elem_right_idx).?, x+1,k});
                            const add_paths_from_elem_right = splitter_state.get(elem_right_idx).? + splitter_state.get(x + y*width).?;
                            try splitter_state.put(x + y * width, add_paths_from_elem_right ); //put this ^ in the set and onto the next one
                            // continue :outer;
                        }

                    }
                }




            }

        }
    }


    std.debug.print("\n\n\n", .{});

    //count the answer from the final row
    //do same as before but on . instead of ^ , i.e, add all the paths that are coming to the last row 
    var result: u64 = 0;
    outer_for: for(1..width-1) |x| { //skip the first and last . ,  will add 2 to the result for them 

        var k: u64 = lines - 1;
        while (k > 1):(k-=1) {
            std.debug.print("iteraring at row k = {d}\n", .{k});
            //get all three elements in this row
            const elem_left_idx = (x-1) + k*width ;
            const elem_left = input[elem_left_idx] ;
            const elem_mid_idx = x + k*width ;
            const elem_mid = input[elem_mid_idx] ;
            const elem_right_idx = (x+1) + k*width ;
            const elem_right = input[elem_right_idx] ;

            if (elem_mid == '^') {
                std.debug.print("elem_mid: ({d},{d})\n", .{x,k});
                std.debug.print("Not a hit :( \n Onto the next ^ \n", .{});
                continue :outer_for; //this splitter done, onto the next one
            } 

            if (elem_left == '^'){

                std.debug.print("elem_left: ({d},{d})\n", .{x,k});
                std.debug.print("Adding {d} paths from ({d},{d}) \n", .{splitter_state.get(elem_left_idx).?, x-1,k});
                result += splitter_state.get(elem_left_idx).? ;
            } 

            if (elem_right == '^'){ //same as above
                std.debug.print("elem_right: ({d},{d})\n", .{x,k});
                std.debug.print("Adding {d} paths from ({d},{d}) \n", .{splitter_state.get(elem_right_idx).?, x+1,k});
                result += splitter_state.get(elem_right_idx).? ;
            }
        }
    }

    result += 2; //cuz we skipped the first and last . and those are just 2 paths from the top

    std.debug.print("result:{d}", .{result});







}
