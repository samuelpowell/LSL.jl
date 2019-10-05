# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

module LSL

using Libdl
using CEnum

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("LSL not installed properly, run Pkg.build(\"LSL\"), restart Julia and try again")
end
include(depsjl_path)

# Module initialization function
function __init__()
    check_deps()
end

# Include wrapper
include(joinpath(@__DIR__, "..", "gen", "liblsl_common.jl"))
include(joinpath(@__DIR__, "..", "gen", "liblsl_api.jl"))




end # module
