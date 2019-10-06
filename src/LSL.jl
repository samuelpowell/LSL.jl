# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# LSL.jl: main module definition

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

# Type maps
_lsl_channel_format(::Type{Float32})    = lsl_channel_format_t(1)
_lsl_channel_format(::Type{Float64})    = lsl_channel_format_t(2)
_lsl_channel_format(::Type{String})     = lsl_channel_format_t(3)
_lsl_channel_format(::Type{Int32})      = lsl_channel_format_t(4)
_lsl_channel_format(::Type{Int16})      = lsl_channel_format_t(5)
_lsl_channel_format(::Type{Int64})      = lsl_channel_format_t(7)
_lsl_channel_format(::Type{T}) where T  = lsl_channel_format_t(0)

# Basic functions
"""
    protocol_version()

Return the version number of the protocol.

Clients with different minor versions are protocol-compatible with each 
other while clients with different major versions will refuse to work 
together.
"""
function protocol_version()
    major, minor = divrem(lsl_protocol_version(), 100)
    return VersionNumber(major, minor)
end

"""
    library_version()

Return the version number of the underlying liblsl library.
"""
function library_version()
    major, minor = divrem(lsl_library_version(), 100)
    return VersionNumber(major, minor)
end

"""
    library_info()

Return string containing library information.

Contents are for debugging purposes and should not be replied upon by a user application.
"""
library_info() = unsafe_string(lsl_library_info())

"""
    local_clock()

Return local system time stamp in seconds.

The resolution is better than a milisecond. This reading can be used to assign time stamps
to samples as they are being acquired. If the "age" of a sample is known at a particular
time (e.g., from USB transmission delays), it can be used as an offset to local_clock() to 
obtain a better estimate of when a sample was actually captured. See push_sample() for a use
case.
"""
local_clock() = lsl_local_clock()

# High level object API
include("StreamInfo.jl")
#include("StreamOutlet.jl")
#include("StreamInlet.jl")


# Stean


# ## PUSH
# push_sample(outlet, data; timestamp=, pushthrough)
# push_sample_buf(outlet, data; timestamp=, pushthrough)


# # Sample push
# # Buffer push
# # Chunk push

# ## PULL




end # module
