const std = @import("std");
const token = @import("token.zig");

pub const Lexer = struct {
    input: []const u8,
    position: u32, // current position in input (points to current char)
    read_position: u32, // current reading position in input (after current char)
    ch: u8, // current char under examination

    pub fn init(input: []const u8) Lexer {
        var lexer = Lexer {
            .input = input,
            .position = 0,
            .read_position = 0,
            .ch = 0,
        };
        lexer.readChar();
        return lexer;
    }

    pub fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn nextToken(self: *Lexer) token.Token {
        var tok: token.Token = undefined;
        self.skipWhitespace();
        const max_index = std.math.min(self.position + 1, self.input.len);
        const ch = self.input[self.position..max_index];
        tok = switch (self.ch) {
            '=' => tok: {
                if (self.peekChar() == '=') {
                    const index = self.position;
                    self.readChar();
                    break :tok newToken(token.EQ, self.input[index..self.position + 1]);

                } else {
                    break :tok newToken(token.ASSIGN, ch);
                }
            },
            '+' => newToken(token.PLUS, ch),
            '-' => newToken(token.MINUS, ch),
            '!' => tok: {
                if (self.peekChar() == '=') {
                    const index = self.position;
                    self.readChar();
                    break :tok newToken(token.NOT_EQ, self.input[index..index + 2]);
                } else {
                    break :tok newToken(token.BANG, ch);
                }
            },
            '/' => newToken(token.SLASH, ch),
            '*' => newToken(token.ASTERISK, ch),
            '<' => newToken(token.LT, ch),
            '>' => newToken(token.GT, ch),
            ';' => newToken(token.SEMICOLON, ch),
            ',' => newToken(token.COMMA, ch),
            '(' => newToken(token.LPAREN, ch),
            ')' => newToken(token.RPAREN, ch),
            '{' => newToken(token.LBRACE, ch),
            '}' => newToken(token.RBRACE, ch),
            'a'...'z', 'A'...'Z', '_' => {
                const lit = self.readIndentifier();
                const t = token.lookupIdent(lit);
                return token.Token.init(t, lit);
            },
            '0'...'9' => {
                return token.Token.init(token.INT, self.readNumber());
            },
            0 => token.Token.init(token.EOF, ""),
            else => newToken(token.ILLEGAL, ch),
        };

        self.readChar();
        return tok;
    }

    pub fn readIndentifier(self: *Lexer) []const u8 {
        const position = self.position;
        while (isLetter(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    pub fn readNumber(self: *Lexer) []const u8 {
        const position = self.position;
        while (isDigit(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    pub fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        } 
    }

    pub fn peekChar(self: *Lexer) u8 {
        if (self.read_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.read_position];
        }
    }
};

pub fn newToken(ttype: []const u8, ch: []const u8) token.Token {
    return token.Token {
        .ttype = ttype,
        .literal = ch,
    };
}

pub fn isLetter(ch: u8) bool {
    return std.ascii.isAlphabetic(ch) or ch == '_';
}

pub fn isDigit(ch: u8) bool {
    return std.ascii.isDigit(ch);
}

test "member function" {
    const input = "let myString = 5;";
    const l = Lexer.init(input);
    try std.testing.expect(std.mem.eql(u8, l.input, input));
    try std.testing.expect(l.read_position == 1);
    try std.testing.expect(l.ch == 'l');
}

test "new token" {
    const t = newToken(token.ASSIGN, "=");
    try std.testing.expect(std.mem.eql(u8, t.ttype, token.ASSIGN));
    try std.testing.expect(std.mem.eql(u8, t.literal, "="));
}

test "next token" {
    const input = 
        \\let five = 5;
        \\let ten = 10;
        \\
        \\let add = fn(x, y) {
        \\    x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
        \\
    ;

    const tests = [_]token.Token {
        token.Token.init(token.LET, "let"),
        token.Token.init(token.IDENT, "five"),
        token.Token.init(token.ASSIGN, "="),
        token.Token.init(token.INT, "5"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.LET, "let"),
        token.Token.init(token.IDENT, "ten"),
        token.Token.init(token.ASSIGN, "="),
        token.Token.init(token.INT, "10"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.LET, "let"),
        token.Token.init(token.IDENT, "add"),
        token.Token.init(token.ASSIGN, "="),
        token.Token.init(token.FUNCTION, "fn"),
        token.Token.init(token.LPAREN, "("),
        token.Token.init(token.IDENT, "x"),
        token.Token.init(token.COMMA, ","),
        token.Token.init(token.IDENT, "y"),
        token.Token.init(token.RPAREN, ")"),
        token.Token.init(token.LBRACE, "{"),
        token.Token.init(token.IDENT, "x"),
        token.Token.init(token.PLUS, "+"),
        token.Token.init(token.IDENT, "y"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.RBRACE, "}"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.LET, "let"),
        token.Token.init(token.IDENT, "result"),
        token.Token.init(token.ASSIGN, "="),
        token.Token.init(token.IDENT, "add"),
        token.Token.init(token.LPAREN, "("),
        token.Token.init(token.IDENT, "five"),
        token.Token.init(token.COMMA, ","),
        token.Token.init(token.IDENT, "ten"),
        token.Token.init(token.RPAREN, ")"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.BANG, "!"),
        token.Token.init(token.MINUS, "-"),
        token.Token.init(token.SLASH, "/"),
        token.Token.init(token.ASTERISK, "*"),
        token.Token.init(token.INT, "5"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.INT, "5"),
        token.Token.init(token.LT, "<"),
        token.Token.init(token.INT, "10"),
        token.Token.init(token.GT, ">"),
        token.Token.init(token.INT, "5"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.IF, "if"),
        token.Token.init(token.LPAREN, "("),
        token.Token.init(token.INT, "5"),
        token.Token.init(token.LT, "<"),
        token.Token.init(token.INT, "10"),
        token.Token.init(token.RPAREN, ")"),
        token.Token.init(token.LBRACE, "{"),
        token.Token.init(token.RETURN, "return"),
        token.Token.init(token.TRUE, "true"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.RBRACE, "}"),
        token.Token.init(token.ELSE, "else"),
        token.Token.init(token.LBRACE, "{"),
        token.Token.init(token.RETURN, "return"),
        token.Token.init(token.FALSE, "false"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.RBRACE, "}"),
        token.Token.init(token.INT, "10"),
        token.Token.init(token.EQ, "=="),
        token.Token.init(token.INT, "10"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.INT, "10"),
        token.Token.init(token.NOT_EQ, "!="),
        token.Token.init(token.INT, "9"),
        token.Token.init(token.SEMICOLON, ";"),
        token.Token.init(token.EOF, ""),
    };

    var l = Lexer.init(input);

    for (tests) |t| {
        const tok = l.nextToken();
        try std.testing.expect(std.mem.eql(u8, tok.ttype, t.ttype));
        try std.testing.expect(std.mem.eql(u8, tok.literal, t.literal));
    }

}
