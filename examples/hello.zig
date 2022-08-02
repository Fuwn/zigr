const zigr = @import("zigr");

pub fn main() void {
    var screen = zigr.tigrWindow(320, 240, "Hello", 0);

    while (!(zigr.tigrClosed(screen) == 1) and !(zigr.tigrKeyDown(screen, zigr.TK_ESCAPE) == 1)) {
        zigr.tigrClear(screen, zigr.tigrRGB(0x80, 0x90, 0xa0));
        zigr.tigrPrint(screen, zigr.tfont, 120, 110, zigr.tigrRGB(0xff, 0xff, 0xff), "Hello, world.");
        zigr.tigrUpdate(screen);
    }

    zigr.tigrUpdate(screen);
}
