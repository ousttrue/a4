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
            "-D_POSIX_C_SOURCE=200809L",
            "-D_XOPEN_SOURCE=700",
            "-D_XOPEN_SOURCE_EXTENDED",
            "-DVERSION=\"0.2.3\"",
            "-DSYSCONFDIR=\"/etc/share\"",
        },
        .files = &.{
            "a4.c",
            "lib/inih/ini.c",
        },
    });
    targets.append(exe) catch @panic("OOM");
    b.installArtifact(exe);

    exe.linkLibrary(build_vterm(b, target, optimize, b.path("lib/libvterm")));
    exe.linkLibrary(build_unibilium(b, target, optimize, b.path("lib/unibilium")));
    const termkey = build_termkey(b, target, optimize, b.path("lib/libtermkey"));
    const tickit = build_tickit(b, target, optimize, b.path("lib/libtickit"));
    tickit.linkLibrary(termkey);
    exe.linkLibrary(tickit);
    _ = zcc.createStep(b, "cdb", targets.toOwnedSlice() catch @panic("OOM"));
}

fn build_vterm(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "vterm",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addCSourceFiles(.{
        .root = root.path(b, "src"),
        .files = &.{
            "keyboard.c",
            "unicode.c",
            "parser.c",
            "vterm.c",
            "screen.c",
            "state.c",
            "pen.c",
            "encoding.c",
        },
    });
    lib.addIncludePath(root.path(b, "include"));
    return lib;
}

fn build_termkey(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "termkey",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "termkey.c",
            "driver-csi.c",
            "driver-ti.c",
        },
        .flags = &.{
            "-DHAVE_UNIBILIUM=1",
        },
    });
    lib.addIncludePath(root);
    lib.installHeader(root.path(b, "termkey.h"), "termkey.h");
    return lib;
}

fn build_unibilium(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "unibilium",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addCSourceFiles(.{
        .root = root,
        .files = &.{
            "uniutil.c",
            "unibilium.c",
            "uninames.c",
        },
        .flags = &.{
            "-DTERMINFO_DIRS=\"/etc/terminfo\"",
        },
    });
    return lib;
}

fn build_tickit(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "tickit",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addCSourceFiles(.{
        .root = root.path(b, "src"),
        .files = &.{
            "window.c",
            "bindings.c",
            "term.c",
            "rectset.c",
            "pen.c",
            "debug.c",
            "tickit.c",
            "rect.c",
            "evloop-default.c",
            "renderbuffer.c",
            "string.c",
            "utf8.c",
            "termdriver-xterm.c",
            "termdriver-ti.c",
        },
        .flags = &.{},
    });
    lib.addIncludePath(root.path(b, "include"));
    lib.installHeader(root.path(b, "include/tickit.h"), "tickit.h");
    return lib;
}
