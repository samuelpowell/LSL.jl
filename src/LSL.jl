# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# LSL.jl: main module definition
module LSL

using Libdl
using CEnum
using LightXML

export protocol_version, library_version, library_info, local_clock

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
module lib
  using CEnum
  import ..liblsl
  include(joinpath(@__DIR__, "..", "gen", "liblsl_common.jl"))
  include(joinpath(@__DIR__, "..", "gen", "liblsl_api.jl"))
end

using .lib


# Constants
const FOREVER = lib.LSL_FOREVER
const IRREGULAR_RATE = lib.LSL_IRREGULAR_RATE
const DEDUCED_TIMESTAMP = lib.LSL_DEDUCED_TIMESTAMP
const NO_PREFERENCE = lib.LSL_NO_PREFERENCE

# Type maps
_lsl_channel_format(::Type{Float32})    = lib.lsl_channel_format_t(1)
_lsl_channel_format(::Type{Float64})    = lib.lsl_channel_format_t(2)
_lsl_channel_format(::Type{String})     = lib.lsl_channel_format_t(3)
_lsl_channel_format(::Type{Int32})      = lib.lsl_channel_format_t(4)
_lsl_channel_format(::Type{Int16})      = lib.lsl_channel_format_t(5)
_lsl_channel_format(::Type{Cchar})      = lib.lsl_channel_format_t(6)
_lsl_channel_format(::Type{Int64})      = lib.lsl_channel_format_t(7)
_lsl_channel_format(::Type{T}) where T  = lib.lsl_channel_format_t(0)

function _jl_channel_format(lsl_format::lib.lsl_channel_format_t)

  if lsl_format == 1
    return Float32
  elseif lsl_format == 2
    return Float64
  elseif lsl_format == 3
    return String
  elseif lsl_format == 4
    return Int32
  elseif lsl_format == 5
    return Int16
  elseif lsl_format == 6
    return Cchar
  elseif lsl_format == 7
    return Int64
  else 
    return Cvoid
  end

end

_jl_channel_format(::Type{Float32})    = lib.lsl_channel_format_t(1)
_jl_channel_format(::Type{Float64})    = lib.lsl_channel_format_t(2)
_jl_channel_format(::Type{String})     = lib.lsl_channel_format_t(3)
_jl_channel_format(::Type{Int32})      = lib.lsl_channel_format_t(4)
_jl_channel_format(::Type{Int16})      = lib.lsl_channel_format_t(5)
_jl_channel_format(::Type{Int64})      = lib.lsl_channel_format_t(7)
_jl_channel_format(::Type{T}) where T  = lib.lsl_channel_format_t(0)

# Error handling

function handle_error(errcode)
  if errcode >= 0
    return errcode
  elseif errcode == -1
    error("operation failed due to timeout")
  elseif errcode == -2
    error("the stream has been lost")
  elseif errcode == -3
    error("an argument was incorrectly specified")
  elseif errcode == -4
    error("an internal error has occurred")
  else
    error("an unknown error has occurred")
  end
  return 0
end



# Basic functions
"""
    protocol_version()

Return the version number of the protocol.

Clients with different minor versions are protocol-compatible with each 
other while clients with different major versions will refuse to work 
together.
"""
function protocol_version()
    major, minor = divrem(lib.lsl_protocol_version(), 100)
    return VersionNumber(major, minor)
end

"""
    library_version()

Return the version number of the underlying liblsl library.
"""
function library_version()
    major, minor = divrem(lib.lsl_library_version(), 100)
    return VersionNumber(major, minor)
end

"""
    library_info()

Return string containing library information.

Contents are for debugging purposes and should not be replied upon by a user application.
"""
library_info() = unsafe_string(lib.lsl_library_info())

"""
    local_clock()

Return local system time stamp in seconds.

The resolution is better than a milisecond. This reading can be used to assign time stamps
to samples as they are being acquired. If the "age" of a sample is known at a particular
time (e.g., from USB transmission delays), it can be used as an offset to local_clock() to 
obtain a better estimate of when a sample was actually captured. See push_sample() for a use
case.
"""
local_clock() = lib.lsl_local_clock()

# High level object API
include("XMLElement.jl")
include("StreamInfo.jl")
include("StreamOutlet.jl")
include("StreamInlet.jl")
include("Resolver.jl")

end # module
