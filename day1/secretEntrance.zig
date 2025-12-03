const std = @import("std");

pub fn main() !void {
    const filename = "./input.txt";
    const file = try std.fs.cwd().openFile(filename, .{.mode = .read_only});
    defer file.close();
    var read_buf: [1024]u8 = undefined;
    var file_reader: std.fs.File.Reader = file.reader(&read_buf);

    const rol = std.math.rotl;
    const ror = std.math.rotr;
    var dial_state: u100 = undefined;
    dial_state = 1 << 50;
    var zero_count: u32 = 0;

    while (try file_reader.interface.takeDelimiter('\n')) |line| {

        const steps_int: u32 = try std.fmt.parseInt(u32, line[1..], 10);
        const steps: u32 = @mod(steps_int,100);

        if (line[0] == 'L') {
            dial_state = rol(u100, dial_state, steps);

        } else {
            dial_state = ror(u100, dial_state, steps);
        }

        const dial_at_zero = (dial_state & 1);
        if (dial_at_zero == 1){
            zero_count += 1 ;
        }
        
        // std.debug.print("{b:0>100}\n", .{dial_state});
        // std.debug.print("{b:0>100}", .{dial_state});

        // std.debug.print("{s}\n", .{line});
    }
    std.debug.print("{d}", .{zero_count});

}
