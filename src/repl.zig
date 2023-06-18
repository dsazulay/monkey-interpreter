const std = @import("std");
const lexer = @import("lexer.zig");
const token = @import("token.zig");

const prompt = ">> ";

pub fn start(in: std.fs.File.Reader, out: std.fs.File.Writer) !void {
    var buffer: [20]u8 = undefined;

    try out.print("Hello! This is the monkey programming language!\n", .{});
    try out.print("Feel free to type commands\n", .{});
    while (true) {
        try out.print("{s}", .{prompt});
        if (try in.readUntilDelimiterOrEof(&buffer, '\n')) |input| {
            var l = lexer.Lexer.init(input);

            var tok = l.nextToken();
            while (!std.mem.eql(u8, tok.ttype, token.EOF)) {
                try out.print("[Type:{s} Literal:{s}]\n", .{tok.ttype, tok.literal});
                tok = l.nextToken();
            }
        } else {
            try out.print("Nothing to read", .{});
            return;
        }
    }
}

