const std = @import("std");
const zap = @import("zap");

const HelloHandler = struct {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    pub fn hello(r: zap.Request) void {
        // Get the 'name' query parameter
        const name = r.getParamStr("name") orelse "World";

        // Create the response message
        const response = std.fmt.allocPrint(allocator, "Hello {s}", .{name}) catch {
            r.setStatus(.internal_server_error);
            r.sendBody("Internal Server Error") catch {};
            return;
        };
        defer allocator.free(response);

        // Set content type and send response
        r.setHeader("Content-Type", "text/plain") catch {};
        r.sendBody(response) catch {};
    }

    pub fn hello_post(r: zap.Request) void {
        // Get JSON body
        const body = r.body orelse {
            r.setStatus(.bad_request);
            r.sendBody("Missing request body") catch {};
            return;
        };

        // Parse JSON to get the name
        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();
        const arena_allocator = arena.allocator();

        const parsed = std.json.parseFromSlice(std.json.Value, arena_allocator, body) catch {
            r.setStatus(.bad_request);
            r.sendBody("Invalid JSON") catch {};
            return;
        };

        const name = if (parsed.value.object.get("name")) |name_value|
            if (name_value == .string) name_value.string else "World"
        else
            "World";

        // Create the response message
        const response = std.fmt.allocPrint(allocator, "Hello {s}", .{name}) catch {
            r.setStatus(.internal_server_error);
            r.sendBody("Internal Server Error") catch {};
            return;
        };
        defer allocator.free(response);

        // Set content type and send response
        r.setHeader("Content-Type", "text/plain") catch {};
        r.sendBody(response) catch {};
    }

    pub fn health(r: zap.Request) void {
        r.setHeader("Content-Type", "application/json") catch {};
        r.sendBody("{\"status\":\"ok\"}") catch {};
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Setup listener
    var listener = zap.HttpListener.init(.{
        .port = 8080,
        .on_request = null,
        .log = true,
        .max_clients = 100000,
    });
    defer listener.deinit();

    // Setup router
    var router = zap.Router.init(allocator, .{});
    defer router.deinit();

    try router.handle_func("/hello", &HelloHandler.hello, .GET);
    try router.handle_func("/hello", &HelloHandler.hello_post, .POST);
    try router.handle_func("/health", &HelloHandler.health, .GET);

    listener.on_request = router.on_request_handler();

    std.log.info("Starting server on port 8080...", .{});
    std.log.info("GET  /hello?name=YourName", .{});
    std.log.info("POST /hello with JSON {\"name\": \"YourName\"}", .{});
    std.log.info("GET  /health", .{});

    // Start listening
    try listener.listen();

    std.log.info("Server started successfully!", .{});

    // Start worker threads
    zap.start(.{
        .threads = 2,
        .workers = 2,
    });
}
