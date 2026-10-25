-- LÖVE runs on LuaJIT, so lint against LuaJIT (Lua 5.1 + bit/jit), not 5.4.
std = "luajit+love"
max_line_length = 100

-- Vendored code stays unmodified, so don't lint it.
exclude_files = { "lib/", "build/", ".luarocks/" }

-- Allow intentionally unused arguments/variables when prefixed with "_" (e.g. `_dt`).
ignore = { "21./_.*" }

-- The sim and match layers must be deterministic and engine-free. This std has
-- no `love`, no `os`, and a `math` without `random`/`randomseed`, so the linter
-- catches determinism and layering violations instead of code review.
stds.deterministic = {
    read_globals = {
        "assert", "error", "getmetatable", "ipairs", "next", "pairs", "pcall",
        "print", "rawequal", "rawget", "rawset", "require", "select",
        "setmetatable", "tonumber", "tostring", "type", "unpack", "xpcall",
        "string", "table", "bit",
        math = {
            fields = {
                "abs", "acos", "asin", "atan", "atan2", "ceil", "cos", "cosh",
                "deg", "exp", "floor", "fmod", "frexp", "huge", "ldexp", "log",
                "log10", "max", "min", "modf", "pi", "pow", "rad", "sin", "sinh",
                "sqrt", "tan", "tanh",
            },
        },
    },
}

files["src/sim/"] = { std = "deterministic" }
files["src/match/"] = { std = "deterministic" }

-- Specs run under busted outside LÖVE: no `love`, but busted's globals exist.
files["spec/"] = { std = "luajit+busted" }
