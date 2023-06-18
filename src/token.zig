const std = @import("std");

pub const ILLEGAL = "ILLEGAL";
pub const EOF = "EOF";

// Identifiers + literals
pub const IDENT = "IDENT";
pub const INT = "INT";

// Operators
pub const ASSIGN = "=";
pub const PLUS = "+";
pub const MINUS = "-";
pub const BANG = "!";
pub const ASTERISK = "*";
pub const SLASH = "/";

pub const LT = "<";
pub const GT = ">";
pub const EQ = "==";
pub const NOT_EQ = "!=";

// Delimiters
pub const COMMA = ",";
pub const SEMICOLON = ";";

pub const LPAREN = "(";
pub const RPAREN = ")";
pub const LBRACE = "{";
pub const RBRACE = "}";

// Keywords
pub const FUNCTION = "FUNCTION";
pub const LET = "LET";
pub const TRUE = "TRUE";
pub const FALSE = "FALSE";
pub const IF = "IF";
pub const ELSE = "ELSE";
pub const RETURN = "RETURN";

pub const keywords = std.ComptimeStringMap([]const u8, .{
    .{ "fn", FUNCTION },
    .{ "let", LET },
    .{ "true", TRUE },
    .{ "false", FALSE },
    .{ "if", IF },
    .{ "else", ELSE },
    .{ "return", RETURN },
});

pub fn lookupIdent(ident: []const u8) []const u8 {
    if (keywords.get(ident)) |i| {
        return i;
    }
    return IDENT;
}

pub const Token = struct {
    ttype: []const u8,
    literal: []const u8,

    pub fn init(t: []const u8, l: []const u8) Token {
        return Token {
            .ttype = t,
            .literal = l,
        };
    }

    pub fn asString(self: Token) []const u8 {
        return "{Type: " ++ self.ttype ++ "Literal: " ++ self.literal ++ "}";  
    }
};

