module Liblsl

using Libdl

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("LibFoo not installed properly, run Pkg.build(\"LibFoo\"), restart Julia and try again")
end
include(depsjl_path)

# Module initialization function
function __init__()
    check_deps()
end

end # module
