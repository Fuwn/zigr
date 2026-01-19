#!/usr/bin/env bash

git submodule update --init --recursive

zig translate-c libs/tigr/tigr.h > src/c.zig
