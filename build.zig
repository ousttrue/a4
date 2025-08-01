const std = @import("std");
const zcc = @import("compile_commands");

pub fn build(b: *std.Build) void {
    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = "a4",
        .link_libc = true,
    });
    exe.addCSourceFiles(.{
        .flags = &.{
            "-DHAVE_UNIBILIUM=1",
            "-D_POSIX_C_SOURCE=200809L",
            "-D_XOPEN_SOURCE=700",
            "-D_XOPEN_SOURCE_EXTENDED",
            "-DVERSION=\"0.2.3\"",
            "-DTERMINFO_DIRS=\"/etc/terminfo\"",
            "-DSYSCONFDIR=\"/etc/share\"",
        },
        .files = &.{
            "a4.c",
            //
            "lib/unibilium/uniutil.c",
            "lib/unibilium/unibilium.c",
            "lib/unibilium/uninames.c",
            //
            "lib/inih/ini.c",
            //
            "lib/libtermkey/termkey.c",
            "lib/libtermkey/driver-csi.c",
            "lib/libtermkey/driver-ti.c",
            //
            "lib/libtickit/src/window.c",
            "lib/libtickit/src/bindings.c",
            "lib/libtickit/src/term.c",
            "lib/libtickit/src/rectset.c",
            "lib/libtickit/src/pen.c",
            "lib/libtickit/src/debug.c",
            "lib/libtickit/src/tickit.c",
            "lib/libtickit/src/rect.c",
            "lib/libtickit/src/evloop-default.c",
            "lib/libtickit/src/renderbuffer.c",
            "lib/libtickit/src/string.c",
            "lib/libtickit/src/utf8.c",
            "lib/libtickit/src/termdriver-xterm.c",
            "lib/libtickit/src/termdriver-ti.c",
            //
            "lib/libvterm/src/keyboard.c",
            "lib/libvterm/src/unicode.c",
            "lib/libvterm/src/parser.c",
            "lib/libvterm/src/vterm.c",
            "lib/libvterm/src/screen.c",
            "lib/libvterm/src/state.c",
            "lib/libvterm/src/pen.c",
            "lib/libvterm/src/encoding.c",
        },
    });
    targets.append(exe) catch @panic("OOM");
    exe.addIncludePath(b.path("lib/libtickit/include"));
    exe.addIncludePath(b.path("lib/libtermkey"));
    b.installArtifact(exe);

    _ = zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}
