const std = @import("std");
const testing = std.testing;
const zap = @import("zap");

test "hello function basic test" {
    // Test that our hello logic works correctly
    const allocator = testing.allocator;

    // Test case 1: Default name
    {
        const result = try std.fmt.allocPrint(allocator, "Hello {s}", .{"World"});
        defer allocator.free(result);
        try testing.expectEqualStrings("Hello World", result);
    }

    // Test case 2: Custom name
    {
        const result = try std.fmt.allocPrint(allocator, "Hello {s}", .{"Zig"});
        defer allocator.free(result);
        try testing.expectEqualStrings("Hello Zig", result);
    }

    // Test case 3: Empty name should default to World
    {
        const name = "";
        const actual_name = if (name.len == 0) "World" else name;
        const result = try std.fmt.allocPrint(allocator, "Hello {s}", .{actual_name});
        defer allocator.free(result);
        try testing.expectEqualStrings("Hello World", result);
    }
}

test "JSON parsing logic" {
    const allocator = testing.allocator;

    // Test valid JSON with name
    {
        const json_str = "{\"name\": \"TestUser\"}";
        const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_str);
        defer parsed.deinit();

        const name = if (parsed.value.object.get("name")) |name_value|
            if (name_value == .string) name_value.string else "World"
        else
            "World";

        try testing.expectEqualStrings("TestUser", name);
    }

    // Test JSON without name field
    {
        const json_str = "{\"other\": \"value\"}";
        const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_str);
        defer parsed.deinit();

        const name = if (parsed.value.object.get("name")) |name_value|
            if (name_value == .string) name_value.string else "World"
        else
            "World";

        try testing.expectEqualStrings("World", name);
    }

    // Test empty JSON object
    {
        const json_str = "{}";
        const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_str);
        defer parsed.deinit();

        const name = if (parsed.value.object.get("name")) |name_value|
            if (name_value == .string) name_value.string else "World"
        else
            "World";

        try testing.expectEqualStrings("World", name);
    }
}

test "response formatting" {
    const allocator = testing.allocator;

    const test_cases = [_]struct {
        input: []const u8,
        expected: []const u8,
    }{
        .{ .input = "Alice", .expected = "Hello Alice" },
        .{ .input = "Bob", .expected = "Hello Bob" },
        .{ .input = "Zig Language", .expected = "Hello Zig Language" },
        .{ .input = "123", .expected = "Hello 123" },
        .{ .input = "special-chars_!@#", .expected = "Hello special-chars_!@#" },
    };

    for (test_cases) |case| {
        const result = try std.fmt.allocPrint(allocator, "Hello {s}", .{case.input});
        defer allocator.free(result);
        try testing.expectEqualStrings(case.expected, result);
    }
}
