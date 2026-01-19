const zigr = @import("zigr");

pub fn main() void {
    const screen: *zigr.Window = .init(320, 240, "Hello", .{});

    while (!screen.closed() and !(screen.keyDown(.ESCAPE))) {
        screen.clear(.initRGB(0x80, 0x90, 0xa0));
        screen.print(null, 120, 110, .initRGB(0xff, 0xff, 0xff), "Hello, world.");
        screen.update();
    }

    screen.update();
}
