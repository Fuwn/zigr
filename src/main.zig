//! ZIGR - Zig TIny GRaphics Library - v3.2
//!        ^    ^   ^^
//!
//! rawr.

const C = @import("c.zig");
const std = @import("std");
const assert = std.debug.assert;

/// This struct contains one pixel.
pub const Pixel = extern struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,
    pub fn initRGB(r: u8, g: u8, b: u8) Pixel {
        return .{ .r = r, .g = g, .b = b };
    }
};

/// Alias to Tigr
pub const Window = Tigr;

/// A Tigr bitmap.
pub const Tigr = extern struct {
    w: c_int,
    h: c_int,
    cx: c_int,
    cy: c_int,
    cw: c_int,
    ch: c_int,
    pix: [*c]Pixel,
    handle: ?*anyopaque,
    blitMode: c_int,

    /// Creates a new empty window with a given bitmap size.
    ///
    /// Title is UTF-8.
    pub inline fn init(w: c_int, h: c_int, title: [:0]const u8, flags: WindowFlags) *Tigr {
        return C.tigrWindow(w, h, title.ptr, flags.convert()).?;
    }

    /// Creates an empty off-screen bitmap.
    pub inline fn initBitmap(w: c_int, h: c_int) *Tigr {
        return C.tigrBitmap(w, h);
    }

    /// Deletes a window/bitmap.
    pub inline fn free(bmp: *Tigr) void {
        C.tigrFree(bmp);
    }

    /// Returns non-zero if the user requested to close a window.
    pub inline fn closed(bmp: *Tigr) bool {
        return C.tigrClosed(bmp) != 0;
    }

    /// Displays a window's contents on-screen and updates input.
    pub inline fn update(bmp: *Tigr) void {
        return C.tigrUpdate(bmp);
    }

    /// Called before doing direct OpenGL calls and before update.
    /// Returns non-zero if OpenGL is available.
    pub inline fn beginOpenGL(bmp: *Tigr) c_int {
        return C.tigrBeginOpenGL(bmp);
    }

    /// Sets post shader for a window.
    /// This replaces the built-in post-FX shader.
    pub inline fn setPostShader(bmp: *Tigr, code: [*c]const u8, size: c_int) void {
        return C.tigrSetPostShader(bmp, code, size);
    }

    /// Sets post-FX properties for a window.
    ///
    /// The built-in post-FX shader uses the following parameters:
    /// p1: hblur - use bilinear filtering along the x-axis (pixels)
    /// p2: vblur - use bilinear filtering along the y-axis (pixels)
    /// p3: scanlines - CRT scanlines effect (0-1)
    /// p4: contrast - contrast boost (1 = no change, 2 = 2X contrast, etc)
    pub inline fn setPostFX(bmp: *Tigr, p1: f32, p2: f32, p3: f32, p4: f32) void {
        return C.tigrSetPostFX(bmp, p1, p2, p3, p4);
    }

    /// Helper for reading pixels.
    /// For high performance, just access bmp->pix directly.
    pub inline fn get(bmp: *Tigr, x: c_int, y: c_int) Pixel {
        return C.tigrGet(bmp, x, y);
    }

    /// Plots a pixel.
    /// Clips and blends.
    /// For high performance, just access bmp->pix directly.
    pub inline fn plot(bmp: *Tigr, x: c_int, y: c_int, pix: Pixel) void {
        return C.tigrPlot(bmp, x, y, pix);
    }

    /// Clears a bitmap to a color.
    /// No blending, no clipping.
    pub inline fn clear(bmp: *Tigr, color: Pixel) void {
        return C.tigrClear(bmp, color);
    }

    /// Fills a rectangular area.
    /// No blending, no clipping.
    pub inline fn fill(bmp: *Tigr, x: c_int, y: c_int, w: c_int, h: c_int, color: Pixel) void {
        return C.tigrFill(bmp, x, y, w, h, color);
    }

    /// Draws a line.
    /// Start pixel is drawn, end pixel is not.
    /// Clips and blends.
    pub inline fn line(bmp: *Tigr, x0: c_int, y0: c_int, x1: c_int, y1: c_int, color: Pixel) void {
        return C.tigrLine(bmp, x0, y0, x1, y1, color);
    }

    /// Draws an empty rectangle.
    /// Drawing a 1x1 rectangle yields the same result as calling plot.
    /// Clips and blends.
    pub inline fn rect(bmp: *Tigr, x: c_int, y: c_int, w: c_int, h: c_int, color: Pixel) void {
        return C.tigrRect(bmp, x, y, w, h, color);
    }

    /// Fills a rectangle.
    /// Fills the inside of the specified rectangular area.
    /// Calling rect followed by fillRect using the same arguments
    /// causes no overdrawing.
    /// Clips and blends.
    pub inline fn fillRect(bmp: *Tigr, x: c_int, y: c_int, w: c_int, h: c_int, color: Pixel) void {
        return C.tigrFillRect(bmp, x, y, w, h, color);
    }

    /// Draws a circle.
    /// Drawing a zero radius circle yields the same result as calling plot.
    /// Drawing a circle with radius one draws a circle three pixels wide.
    /// Clips and blends.
    pub inline fn circle(bmp: *Tigr, x: c_int, y: c_int, r: c_int, color: Pixel) void {
        return C.tigrCircle(bmp, x, y, r, color);
    }

    /// Fills a circle.
    /// Fills the inside of the specified circle.
    /// Calling circle followed by fillCircle using the same arguments
    /// causes no overdrawing.
    /// Filling a circle with zero radius has no effect.
    /// Clips and blends.
    pub inline fn fillCircle(bmp: *Tigr, x: c_int, y: c_int, r: c_int, color: Pixel) void {
        return C.tigrFillCircle(bmp, x, y, r, color);
    }

    /// Sets clip rect.
    /// Set to (0, 0, -1, -1) to reset clipping to full bitmap.
    pub inline fn clip(bmp: *Tigr, cx: c_int, cy: c_int, cw: c_int, ch: c_int) void {
        return C.tigrClip(bmp, cx, cy, cw, ch);
    }

    /// Set destination bitmap blend mode for blit operations.
    pub inline fn setBlitMode(dest: *Tigr, mode: BlitMode) void {
        return C.tigrBlitMode(dest, @intFromEnum(mode));
    }

    /// Loads a font from a bitmap font sheet.
    /// The loaded font takes ownership of the provided bitmap.
    ///
    /// Codepages:
    ///
    ///  TCP_ASCII   - Regular 7-bit ASCII
    ///  TCP_1252    - Windows 1252
    ///  TCP_UTF32   - Unicode subset
    ///
    /// For ASCII and 1252, the font bitmap should contain all characters
    /// for the given codepage, excluding the first 32 control codes.
    ///
    /// For UTF32 - the font bitmap contains a subset of Unicode characters
    /// and must be in the format generated by font for UTF32.
    ///
    pub inline fn loadFont(bitmap: *Tigr, codepage: Codepage) *Font {
        return C.tigrLoadFont(bitmap, @intFromEnum(codepage));
    }

    /// Prints UTF-8 text onto a bitmap.
    /// NOTE:
    ///  This uses the target bitmap blit mode.
    ///  See blitTint for details.
    ///
    /// If font is null, it will use the built in font.
    pub inline fn print(dest: *Tigr, font: ?*Font, x: c_int, y: c_int, color: Pixel, text: [:0]const u8) void {
        return C.tigrPrint(dest, font orelse tfont, x, y, color, text.ptr);
    }

    /// Returns mouse input for a window.
    /// The value set to "buttons" is a bit set where bits 0, 1 and 2
    /// corresponds to the left, right and middle buttons.
    /// A set bit indicates that a button is held.
    pub inline fn mouse(bmp: *Tigr) Mouse {
        var x: c_int = undefined;
        var y: c_int = undefined;
        var buttons: c_int = undefined;
        C.tigrMouse(bmp, &x, &y, &buttons);
        return .{
            .x = x,
            .y = y,
            .left = (buttons & 0b0001) > 0,
            .right = (buttons & 0b0010) > 0,
            .middle = (buttons & 0b0100) > 0,
        };
    }

    /// Reads touch input for a window.
    /// Returns number of touch points read.
    pub inline fn touch(bmp: *Tigr, points: [*c]touchPoint, maxPoints: c_int) c_int {
        return C.tigrTouch(bmp, points, maxPoints);
    }

    /// Reads the delta of the scroll "wheel" in somewhat platform neutral
    /// units where 1.0 corresponds to a "notch". The actual correlation between
    /// physical movement and this number varies between platforms, input methods
    /// and settings.
    pub inline fn scrollWheel(bmp: *Tigr, x: [*c]f32, y: [*c]f32) void {
        return C.tigrScrollWheel(bmp, x, y);
    }

    /// Reads the keyboard for a window.
    /// Returns non-zero if a key is pressed/held.
    /// keyDown tests for the initial press, keyHeld repeats each frame.
    pub inline fn keyDown(bmp: *Tigr, key: Key) bool {
        return C.tigrKeyDown(bmp, @intFromEnum(key)) != 0;
    }

    /// Reads the keyboard for a window.
    /// Returns non-zero if a key is pressed/held.
    /// keyDown tests for the initial press, keyHeld repeats each frame.
    pub inline fn keyHeld(bmp: *Tigr, key: Key) bool {
        return C.tigrKeyHeld(bmp, @intFromEnum(key)) != 0;
    }

    /// Reads character input for a window.
    /// Returns the Unicode value of the last key pressed, or 0 if none.
    pub inline fn readChar(bmp: *Tigr) ?Key {
        const char = C.tigrReadChar(bmp);
        if (char == 0) return null;
        return @enumFromInt(char);
    }

    /// Loads a PNG from a file. (fileName is UTF-8)
    /// On error, returns NULL and sets errno.
    pub inline fn loadImage(fileName: [:0]const u8) *Tigr {
        return C.tigrLoadImage(fileName.ptr);
    }

    /// Loads a PNG from memory.
    /// On error, returns NULL and sets errno.
    pub inline fn loadImageMem(data: ?*const anyopaque, length: c_int) *Tigr {
        return C.tigrLoadImageMem(data, length);
    }

    /// Saves a PNG to a file. (fileName is UTF-8)
    /// On error, returns zero and sets errno.
    pub inline fn saveImage(bmp: *Tigr, fileName: [:0]const u8) c_int {
        return C.tigrSaveImage(fileName.ptr, bmp);
    }
};

/// Creates a new empty window with a given bitmap size.
///
/// Title is UTF-8.
pub inline fn initWindow(w: c_int, h: c_int, title: [:0]const u8, flags: WindowFlags) *Tigr {
    return C.tigrWindow(w, h, title.ptr, flags.convert()).?;
}

pub const WindowFlags = struct {
    const TIGR_FIXED = @as(c_int, 0);
    const TIGR_AUTO = @as(c_int, 1);
    const TIGR_2X = @as(c_int, 2);
    const TIGR_3X = @as(c_int, 4);
    const TIGR_4X = @as(c_int, 8);
    const TIGR_RETINA = @as(c_int, 16);
    const TIGR_NOCURSOR = @as(c_int, 32);
    const TIGR_FULLSCREEN = @as(c_int, 64);
    /// In TIGR_FIXED mode, the window is made as large as possible to contain an integer-scaled
    /// version of the bitmap while still fitting on the screen. Resizing the window will adapt
    /// the scale in integer steps to fit the bitmap.
    ///
    /// In TIGR_AUTO mode, the initial window size is set to the bitmap size times the pixel
    /// scale. Resizing the window will resize the bitmap using the specified scale.
    /// For example, in forced 2X mode, the window will be twice as wide (and high) as the bitmap.
    size: enum { fixed, auto } = .fixed,
    scale: enum(c_int) { x1 = 0, x2 = TIGR_2X, x3 = TIGR_3X, x4 = TIGR_4X } = .x1,

    /// Turning on TIGR_RETINA mode will request full backing resolution on OSX, meaning that
    /// the effective window size might be integer scaled to a larger size. In TIGR_AUTO mode,
    /// this means that the Tigr bitmap will change size if the window is moved between
    /// retina and non-retina screens.
    retina: bool = false,
    nocursor: bool = false,
    fullscreen: bool = false,
    pub inline fn convert(self: WindowFlags) c_int {
        return (if (self.size == .auto) TIGR_AUTO else TIGR_FIXED) +
            @intFromEnum(self.scale) +
            (if (self.retina) TIGR_RETINA else 0) +
            (if (self.nocursor) TIGR_NOCURSOR else 0) +
            (if (self.fullscreen) TIGR_FULLSCREEN else 0);
    }
};

/// Creates an empty off-screen bitmap.
pub inline fn initBitmap(w: c_int, h: c_int) *Tigr {
    return C.tigrBitmap(w, h);
}

/// Deletes a window/bitmap.
pub inline fn free(bmp: *Tigr) void {
    C.tigrFree(bmp);
}

/// Returns non-zero if the user requested to close a window.
pub inline fn closed(bmp: *Tigr) bool {
    return C.tigrClosed(bmp) != 0;
}

/// Displays a window's contents on-screen and updates input.
pub inline fn update(bmp: *Tigr) void {
    return C.tigrUpdate(bmp);
}

/// Called before doing direct OpenGL calls and before update.
/// Returns non-zero if OpenGL is available.
pub inline fn beginOpenGL(bmp: *Tigr) c_int {
    return C.tigrBeginOpenGL(bmp);
}

/// Sets post shader for a window.
/// This replaces the built-in post-FX shader.
pub inline fn setPostShader(bmp: *Tigr, code: [*c]const u8, size: c_int) void {
    return C.tigrSetPostShader(bmp, code, size);
}

/// Sets post-FX properties for a window.
///
/// The built-in post-FX shader uses the following parameters:
/// p1: hblur - use bilinear filtering along the x-axis (pixels)
/// p2: vblur - use bilinear filtering along the y-axis (pixels)
/// p3: scanlines - CRT scanlines effect (0-1)
/// p4: contrast - contrast boost (1 = no change, 2 = 2X contrast, etc)
pub inline fn setPostFX(bmp: *Tigr, p1: f32, p2: f32, p3: f32, p4: f32) void {
    return C.tigrSetPostFX(bmp, p1, p2, p3, p4);
}

/// Helper for reading pixels.
/// For high performance, just access bmp->pix directly.
pub inline fn get(bmp: *Tigr, x: c_int, y: c_int) Pixel {
    return C.tigrGet(bmp, x, y);
}

/// Plots a pixel.
/// Clips and blends.
/// For high performance, just access bmp->pix directly.
pub inline fn plot(bmp: *Tigr, x: c_int, y: c_int, pix: Pixel) void {
    return C.tigrPlot(bmp, x, y, pix);
}

/// Clears a bitmap to a color.
/// No blending, no clipping.
pub inline fn clear(bmp: *Tigr, color: Pixel) void {
    return C.tigrClear(bmp, color);
}

/// Fills a rectangular area.
/// No blending, no clipping.
pub inline fn fill(bmp: *Tigr, x: c_int, y: c_int, w: c_int, h: c_int, color: Pixel) void {
    return C.tigrFill(bmp, x, y, w, h, color);
}

/// Draws a line.
/// Start pixel is drawn, end pixel is not.
/// Clips and blends.
pub inline fn line(bmp: *Tigr, x0: c_int, y0: c_int, x1: c_int, y1: c_int, color: Pixel) void {
    return C.tigrLine(bmp, x0, y0, x1, y1, color);
}

/// Draws an empty rectangle.
/// Drawing a 1x1 rectangle yields the same result as calling plot.
/// Clips and blends.
pub inline fn rect(bmp: *Tigr, x: c_int, y: c_int, w: c_int, h: c_int, color: Pixel) void {
    return C.tigrRect(bmp, x, y, w, h, color);
}

/// Fills a rectangle.
/// Fills the inside of the specified rectangular area.
/// Calling rect followed by fillRect using the same arguments
/// causes no overdrawing.
/// Clips and blends.
pub inline fn fillRect(bmp: *Tigr, x: c_int, y: c_int, w: c_int, h: c_int, color: Pixel) void {
    return C.tigrFillRect(bmp, x, y, w, h, color);
}

/// Draws a circle.
/// Drawing a zero radius circle yields the same result as calling plot.
/// Drawing a circle with radius one draws a circle three pixels wide.
/// Clips and blends.
pub inline fn circle(bmp: *Tigr, x: c_int, y: c_int, r: c_int, color: Pixel) void {
    return C.tigrCircle(bmp, x, y, r, color);
}

/// Fills a circle.
/// Fills the inside of the specified circle.
/// Calling circle followed by fillCircle using the same arguments
/// causes no overdrawing.
/// Filling a circle with zero radius has no effect.
/// Clips and blends.
pub inline fn fillCircle(bmp: *Tigr, x: c_int, y: c_int, r: c_int, color: Pixel) void {
    return C.tigrFillCircle(bmp, x, y, r, color);
}

/// Sets clip rect.
/// Set to (0, 0, -1, -1) to reset clipping to full bitmap.
pub inline fn clip(bmp: *Tigr, cx: c_int, cy: c_int, cw: c_int, ch: c_int) void {
    return C.tigrClip(bmp, cx, cy, cw, ch);
}

/// Copies bitmap data.
/// dx/dy = dest co-ordinates
/// sx/sy = source co-ordinates
/// w/h   = width/height
///
/// RGBAdest = RGBAsrc
/// Clips, does not blend.
pub inline fn blit(dest: *Tigr, src: *Tigr, dx: c_int, dy: c_int, sx: c_int, sy: c_int, w: c_int, h: c_int) void {
    return C.tigrBlit(dest, src, dx, dy, sx, sy, w, h);
}

/// Same as blit, but alpha blends the source bitmap with the
/// target using per pixel alpha and the specified global alpha.
///
/// Ablend = Asrc * alpha
/// RGBdest = RGBsrc * Ablend + RGBdest * (1 - Ablend)
///
/// Blit mode == TIGR_KEEP_ALPHA:
/// Adest = Adest
///
/// Blit mode == TIGR_BLEND_ALPHA:
/// Adest = Asrc * Ablend + Adest * (1 - Ablend)
/// Clips and blends.
pub inline fn blitAlpha(dest: *Tigr, src: *Tigr, dx: c_int, dy: c_int, sx: c_int, sy: c_int, w: c_int, h: c_int, alpha: f32) void {
    return C.tigrBlitAlpha(dest, src, dx, dy, sx, sy, w, h, alpha);
}

/// Same as blit, but tints the source bitmap with a color
/// and alpha blends the resulting source with the destination.
///
/// Rblend = Rsrc * Rtint
/// Gblend = Gsrc * Gtint
/// Bblend = Bsrc * Btint
/// Ablend = Asrc * Atint
///
/// RGBdest = RGBblend * Ablend + RGBdest * (1 - Ablend)
///
/// Blit mode == TIGR_KEEP_ALPHA:
/// Adest = Adest
///
/// Blit mode == TIGR_BLEND_ALPHA:
/// Adest = Ablend * Ablend + Adest * (1 - Ablend)
/// Clips and blends.
pub inline fn blitTint(dest: *Tigr, src: *Tigr, dx: c_int, dy: c_int, sx: c_int, sy: c_int, w: c_int, h: c_int, tint: Pixel) void {
    return C.tigrBlitTint(dest, src, dx, dy, sx, sy, w, h, tint);
}

pub const BlitMode = enum(c_int) {
    /// Keep destination alpha value
    TIGR_KEEP_ALPHA = 0,
    /// Blend destination alpha (default)
    TIGR_BLEND_ALPHA = 1,
};

/// Set destination bitmap blend mode for blit operations.
pub inline fn blitMode(dest: *Tigr, mode: BlitMode) void {
    return C.tigrBlitMode(dest, @intFromEnum(mode));
}

pub const Glyph = C.TigrGlyph;
pub const Font = C.TigrFont;
pub const Codepage = enum(c_int) {
    TCP_ASCII = 0,
    TCP_1252 = 1252,
    TCP_UTF32 = 12001,
};

/// Loads a font from a bitmap font sheet.
/// The loaded font takes ownership of the provided bitmap.
///
/// Codepages:
///
///  TCP_ASCII   - Regular 7-bit ASCII
///  TCP_1252    - Windows 1252
///  TCP_UTF32   - Unicode subset
///
/// For ASCII and 1252, the font bitmap should contain all characters
/// for the given codepage, excluding the first 32 control codes.
///
/// For UTF32 - the font bitmap contains a subset of Unicode characters
/// and must be in the format generated by font for UTF32.
///
pub inline fn loadFont(bitmap: *Tigr, codepage: Codepage) *Font {
    return C.tigrLoadFont(bitmap, @intFromEnum(codepage));
}

/// Frees a font and associated font sheet.
pub inline fn freeFont(font: *Font) void {
    return C.tigrFreeFont(font);
}

/// Prints UTF-8 text onto a bitmap.
/// NOTE:
///  This uses the target bitmap blit mode.
///  See blitTint for details.
pub inline fn print(dest: *Tigr, font: ?*Font, x: c_int, y: c_int, color: Pixel, text: [:0]const u8) void {
    return C.tigrPrint(dest, font orelse tfont, x, y, color, text.ptr);
}

/// Returns the width of a string.
pub inline fn textWidth(font: ?*Font, text: [:0]const u8) c_int {
    return C.tigrTextWidth(font orelse tfont, text.ptr);
}

/// Returns the height of a string.
pub inline fn textHeight(font: ?*Font, text: [:0]const u8) c_int {
    return C.tigrTextHeight(font orelse tfont, text.ptr);
}

/// The built-in font.
pub extern var tfont: *Font;

/// Key scancodes. For letters/numbers, use ASCII ('A'-'Z' and '0'-'9').
pub const Key = enum(c_int) {
    PAD0 = 128,
    PAD1 = 129,
    PAD2 = 130,
    PAD3 = 131,
    PAD4 = 132,
    PAD5 = 133,
    PAD6 = 134,
    PAD7 = 135,
    PAD8 = 136,
    PAD9 = 137,
    PADMUL = 138,
    PADADD = 139,
    PADENTER = 140,
    PADSUB = 141,
    PADDOT = 142,
    PADDIV = 143,
    F1 = 144,
    F2 = 145,
    F3 = 146,
    F4 = 147,
    F5 = 148,
    F6 = 149,
    F7 = 150,
    F8 = 151,
    F9 = 152,
    F10 = 153,
    F11 = 154,
    F12 = 155,
    BACKSPACE = 156,
    TAB = 157,
    RETURN = 158,
    SHIFT = 159,
    CONTROL = 160,
    ALT = 161,
    PAUSE = 162,
    CAPSLOCK = 163,
    ESCAPE = 164,
    SPACE = 165,
    PAGEUP = 166,
    PAGEDN = 167,
    END = 168,
    HOME = 169,
    LEFT = 170,
    UP = 171,
    RIGHT = 172,
    DOWN = 173,
    INSERT = 174,
    DELETE = 175,
    LWIN = 176,
    RWIN = 177,
    NUMLOCK = 178,
    SCROLL = 179,
    LSHIFT = 180,
    RSHIFT = 181,
    LCONTROL = 182,
    RCONTROL = 183,
    LALT = 184,
    RALT = 185,
    SEMICOLON = 186,
    EQUALS = 187,
    COMMA = 188,
    MINUS = 189,
    DOT = 190,
    SLASH = 191,
    BACKTICK = 192,
    LSQUARE = 193,
    BACKSLASH = 194,
    RSQUARE = 195,
    TICK = 196,
    _,
    pub fn char(c: u8) Key {
        assert(std.ascii.isAlphanumeric(c));
        return @enumFromInt(c);
    }
};

const Mouse = struct {
    x: c_int,
    y: c_int,
    left: bool,
    right: bool,
    middle: bool,
};

/// Returns mouse input for a window.
/// The value set to "buttons" is a bit set where bits 0, 1 and 2
/// corresponds to the left, right and middle buttons.
/// A set bit indicates that a button is held.
pub inline fn mouse(bmp: *Tigr) Mouse {
    var x: c_int = undefined;
    var y: c_int = undefined;
    var buttons: c_int = undefined;
    C.tigrMouse(bmp, &x, &y, &buttons);
    return .{
        .x = x,
        .y = y,
        .left = (buttons & 0b0001) > 0,
        .right = (buttons & 0b0010) > 0,
        .middle = (buttons & 0b0100) > 0,
    };
}
pub const touchPoint = C.TigrTouchPoint;

/// Reads touch input for a window.
/// Returns number of touch points read.
pub inline fn touch(bmp: *Tigr, points: [*c]touchPoint, maxPoints: c_int) c_int {
    return C.tigrTouch(bmp, points, maxPoints);
}

/// Reads the delta of the scroll "wheel" in somewhat platform neutral
/// units where 1.0 corresponds to a "notch". The actual correlation between
/// physical movement and this number varies between platforms, input methods
/// and settings.
pub inline fn scrollWheel(bmp: *Tigr, x: [*c]f32, y: [*c]f32) void {
    return C.tigrScrollWheel(bmp, x, y);
}

/// Reads the keyboard for a window.
/// Returns non-zero if a key is pressed/held.
/// keyDown tests for the initial press, keyHeld repeats each frame.
pub inline fn keyDown(bmp: *Tigr, key: Key) bool {
    return C.tigrKeyDown(bmp, @intFromEnum(key)) != 0;
}

/// Reads the keyboard for a window.
/// Returns non-zero if a key is pressed/held.
/// keyDown tests for the initial press, keyHeld repeats each frame.
pub inline fn keyHeld(bmp: *Tigr, key: Key) bool {
    return C.tigrKeyHeld(bmp, @intFromEnum(key)) != 0;
}

/// Reads character input for a window.
/// Returns the Unicode value of the last key pressed, or 0 if none.
pub inline fn readChar(bmp: *Tigr) ?Key {
    const char = C.tigrReadChar(bmp);
    if (char == 0) return null;
    return @enumFromInt(char);
}

/// Loads a PNG from a file. (fileName is UTF-8)
/// On error, returns NULL and sets errno.
pub inline fn loadImage(fileName: [:0]const u8) *Tigr {
    return C.tigrLoadImage(fileName.ptr);
}

/// Loads a PNG from memory.
/// On error, returns NULL and sets errno.
pub inline fn loadImageMem(data: ?*const anyopaque, length: c_int) *Tigr {
    return C.tigrLoadImageMem(data, length);
}

/// Saves a PNG to a file. (fileName is UTF-8)
/// On error, returns zero and sets errno.
pub inline fn saveImage(fileName: [:0]const u8, bmp: *Tigr) c_int {
    return C.tigrSaveImage(fileName.ptr, bmp);
}

/// Returns the amount of time elapsed since time was last called,
/// or zero on the first call.
pub inline fn time() f32 {
    return C.tigrTime();
}

/// Displays an error message and quits. (UTF-8)
/// 'bmp' can be NULL.
pub const tigrError = C.tigrError;

/// Reads an entire file into memory. (fileName is UTF-8)
/// Free it yourself after with 'free'.
/// On error, returns NULL and sets errno.
/// TIGR will automatically append a NUL terminator byte
/// to the end (not included in the length)
pub inline fn readFile(fileName: [:0]const u8, length: [*c]c_int) ?*anyopaque {
    return C.tigrReadFile(fileName.ptr, length);
}

/// Decompresses DEFLATEd zip/zlib data into a buffer.
/// Returns non-zero on success.
pub inline fn inflate(out: ?*anyopaque, outlen: c_uint, in: ?*const anyopaque, inlen: c_uint) c_int {
    return C.tigrInflate(out, outlen, in, inlen);
}

/// Decodes a single UTF8 codepoint and returns the next pointer.
pub inline fn decodeUTF8(text: [:0]const u8, cp: [*c]c_int) [*c]const u8 {
    return C.tigrDecodeUTF8(text.ptr, cp);
}

/// Encodes a single UTF8 codepoint and returns the next pointer.
pub inline fn encodeUTF8(text: [*c]u8, cp: c_int) [*c]u8 {
    return C.tigrEncodeUTF8(text, cp);
}

/// Do not call this function.
/// It exists so that the inline functions get compiled.
pub fn compileAllFunctions() void {
    _ = initWindow(undefined, undefined, undefined, .{});
    _ = initBitmap(undefined, undefined);
    free(undefined);
    _ = closed(undefined);
    update(undefined);
    _ = beginOpenGL(undefined);
    setPostShader(undefined, undefined, undefined);
    setPostFX(undefined, undefined, undefined, undefined, undefined);
    _ = get(undefined, undefined, undefined);
    plot(undefined, undefined, undefined, undefined);
    clear(undefined, undefined);
    fill(undefined, undefined, undefined, undefined, undefined, undefined);
    line(undefined, undefined, undefined, undefined, undefined, undefined);
    rect(undefined, undefined, undefined, undefined, undefined, undefined);
    fillRect(undefined, undefined, undefined, undefined, undefined, undefined);
    circle(undefined, undefined, undefined, undefined, undefined);
    fillCircle(undefined, undefined, undefined, undefined, undefined);
    clip(undefined, undefined, undefined, undefined, undefined);
    blit(undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined);
    blitAlpha(undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined);
    blitTint(undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined);
    blitMode(undefined, undefined);
    _ = loadFont(undefined, undefined);
    freeFont(undefined);
    print(undefined, null, undefined, undefined, undefined, undefined);
    _ = textWidth(null, undefined);
    _ = textHeight(null, undefined);
    _ = mouse(undefined);
    _ = touch(undefined, undefined, undefined);
    scrollWheel(undefined, undefined, undefined);
    _ = keyDown(undefined, undefined);
    _ = keyHeld(undefined, undefined);
    _ = readChar(undefined);
    _ = loadImage(undefined);
    _ = loadImageMem(undefined, undefined);
    _ = saveImage(undefined, undefined);
    _ = time();
    _ = readFile(undefined, undefined);
    _ = inflate(undefined, undefined, undefined, undefined);
    _ = decodeUTF8(undefined, undefined);
    _ = encodeUTF8(undefined, undefined);
}

test "refAllDecls" {
    _ = std.testing.refAllDeclsRecursive(@This());
}
