const std =  @import("std");
const file = @embedFile("./input.txt");

const Point = struct {
    x: u64,
    y: u64,
    z: u64,
};

const Pair = struct {
    p1: Point,
    p2: Point,
    dist_sq : u64, //distance squared
};

//not doing square root, we can just compare the distance^2 to sort the pairs
fn distance_sq(p1: Point, p2: Point) u64 {
    const del_x = if (p1.x > p2.x ) (p1.x - p2.x) else (p2.x - p1.x);
    const del_y = if (p1.y > p2.y ) (p1.y - p2.y) else (p2.y - p1.y);
    const del_z = if (p1.z > p2.z ) (p1.z - p2.z) else (p2.z - p1.z);
    return del_x*del_x + del_y*del_y + del_z*del_z; 
}


//function compare two pairs so that priorityQue can store the pairs with smallest distances
fn priorityQueHelper(_: void, a: Pair, b: Pair) std.math.Order{
    if (a.dist_sq == b.dist_sq){
        return .eq;
    }else if (a.dist_sq < b.dist_sq){
        return .lt; //for part-2 its .lt, as we want to merge the closest pairs first from the heap
    }else if (a.dist_sq > b.dist_sq){
        return .gt;
    }else {
        unreachable;
    }
}

const unionFind = struct {
    parent: [] usize,
    points: [] Point,

    //finds root node 
    fn find(self: unionFind, point_idx: usize) usize {
        if (self.parent[point_idx] == point_idx){
            return point_idx; //its a root
        }

        self.parent[point_idx] = find(self, self.parent[point_idx]); //recursively find root and update parent
        return self.parent[point_idx];
    }

    //union of sets: connects nodes by root
    fn unify(self: unionFind, p1_idx: usize, p2_idx: usize) void {
        const root_p1 = self.find(p1_idx);
        const root_p2 = self.find(p2_idx);

        if (root_p1 == root_p2){
            //they are already connected, do nothing
            return;
        }

        //otherwise, merge the trees: connect the roots
        self.parent[root_p1] = root_p2;
        // std.debug.print("merge: {any} and {any}\n", .{self.points[p1_idx], self.points[p2_idx]});

    }
    fn findPointIndex(self: unionFind, point: Point) usize {
        for (self.points, 0..) |p, idx| {
            if (p.x == point.x and p.y == point.y and p.z == point.z) {
                return idx;
            }
        }
        unreachable;  
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    @setEvalBranchQuota(50000);
    const point_arr_size: u64 = comptime blk:{
        const len: u64 = std.mem.countScalar(u8, file, '\n');
        break :blk len;
    };

    // std.debug.print("{d}\n", .{point_arr_size});

    var point_arr: [point_arr_size] Point = undefined;
    
    var it = std.mem.tokenizeAny(u8, file, ",\n");
    var i: u64 = 0;
    while (i < point_arr_size):(i+=1){

        const x = try std.fmt.parseInt(u64, it.next().?, 10);
        const y = try std.fmt.parseInt(u64, it.next().?, 10);
        const z = try std.fmt.parseInt(u64, it.next().?, 10);

        point_arr[i] = .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    // std.debug.print("{any}", .{point_arr});



    var PQ = std.PriorityQueue(Pair, void, priorityQueHelper).init(allocator, {});
    defer PQ.deinit();
    try PQ.ensureTotalCapacity(1000); //taking all mem i need at once

    for (point_arr,0..) |p1,j| {
        //j+1 : pair with points after p1. The points above had already paired with p1
        for (j+1..point_arr_size) |p2_idx| { 
            const p2 = point_arr[p2_idx];
            const curr_pair_dist_sq = distance_sq(p1, p2);

            //for part-2 we need to connect all boxes, not just the closest 1000
            try PQ.add(.{.p1 = p1, .p2 = p2, .dist_sq = curr_pair_dist_sq}); 
        }
    }

    //array to store the parents in the tree
    var parent_arr: [point_arr_size] usize = undefined;
    for (0..point_arr_size) |k| {
        parent_arr[k] = k;
    }

    const UF = unionFind {
        .parent = &parent_arr,
        .points = &point_arr,
    };
    

    while (PQ.removeOrNull()) |pair| {
        const p1_idx = UF.findPointIndex(pair.p1);
        const p2_idx = UF.findPointIndex(pair.p2);
        // std.debug.print("{any}\n", .{pair});
        UF.unify(p1_idx, p2_idx);
    }



}
















