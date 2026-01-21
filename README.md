# 🦎 ZIGR

> Zig bindings for [TIGR](https://github.com/erkkah/tigr/) (TIny GRaphics library)

# Updating Instructions
1. Find the latest [TIGR](https://github.com/erkkah/tigr/) release
2. Run `zig fetch --save=tigr "git+github.com/erkkah/tigr#<COMMIT_HASH>`
3. Run `zig build bindgen`
4. Run `git apply --check bindings.patch`
5. If that works, run `git apply bindings.patch`
6. Add new functions to `src/main.zig`
7. Update `version` and `minimum_zig_version` in `build.zig.zon`

## Licence

This project is licensed under the [ISC license](./LICENSE).
