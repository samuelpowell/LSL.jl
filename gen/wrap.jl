# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# wrap.jl: automatically wrap C API using Clang.jl

# Note: in current wrap the following manual changes are made
# 1. Remove duplicate signature
# 2. Change signature of push/pull const *char to Cchar from Cstring
# 3. Guard Clong functions with @static if !Sys.iswindows() && Sys.WORD_SIZE == 64

@info("NOTE MANUAL CHANGES in deps/wrap.jl")

using Clang

const LIBLSL_INCLUDE = joinpath(@__DIR__, "..", "deps", "usr", "include") |> normpath
const LIBLSL_HEADERS = [joinpath(LIBLSL_INCLUDE, header) for header in ["lsl_constants.h", "lsl_c.h"]]

wc = init(; headers = LIBLSL_HEADERS,
            output_file = joinpath(@__DIR__, "liblsl_api.jl"),
            common_file = joinpath(@__DIR__, "liblsl_common.jl"),
            clang_includes = vcat(LIBLSL_INCLUDE, CLANG_INCLUDE),
            clang_args = ["-I", joinpath(LIBLSL_INCLUDE, "..")],
            header_wrapped = (root, current)->root == current,
            header_library = x->"liblsl",
            clang_diagnostics = true,
            )

run(wc)

