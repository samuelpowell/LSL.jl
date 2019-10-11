# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# StreamOutlet.jl: type and method definitions for steam outlet

export StreamOutlet

export push_sample, push_chunk, have_consumers, wait_for_consumers

mutable struct StreamOutlet{T}
  handle::lib.lsl_outlet
  info::StreamInfo{T}

  function StreamOutlet(handle, info::StreamInfo{T}) where T
    outlet = new{T}(handle, info)
    finalizer(_destroy, outlet)
  end

end

# Destroy a StreamInfo handle
function _destroy(outlet::StreamOutlet)
  if outlet.handle != C_NULL
    lib.lsl_destroy_outlet(outlet)
  end
  return nothing
end

# Define conversion to pointer
unsafe_convert(::Type{lib.lsl_outlet}, outlet::StreamOutlet) = outlet.handle

# Define constructor
"""
    StreamOutlet(info; chunk_size = 0, max_buffered = 360)
    
Establish a new stream outlet. This makes the stream discoverable.

# arguments
- `info::StreamInfo`: The stream information to use for creating this stream. Stays constant
                      over the lifetime of the outlet.

# Keyword arguments
- `chunk_size::Integer`: Desired chunk granularity (in samples) for transmission. If
                         specified as 0, each push operation yields one chunk. Stream
                         recipients can have this setting bypassed.
- `max_buffered::Integer`: Maximum amount of data to buffer (in seconds if there is a
                           nominal sampling rate, otherwise x100 in samples). A good default
                           is 360, which corresponds to 6 minutes of data. Note that, for
                           high-bandwidth data you will almost certainly want to use a lower
                           value here to avoid running out of RAM. 
"""
function StreamOutlet(info::StreamInfo{T}; chunk_size = 0, max_buffered = 360) where T

  # Create and test handle
  handle = lib.lsl_create_outlet(info, chunk_size, max_buffered)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during StreamOutlet creation")
  end

  # Create an internal information object
  info = lib.lsl_get_info(handle)
  
  return StreamOutlet(handle, StreamInfo(info, T))
end


#
# Push sample
#

# Type mappings
const _lsl_typestring_map = Dict{DataType, String}(Float32 => "f",
                                                   Float64 => "d",
                                                   Clong => "l",
                                                   Int32 => "i",
                                                   Int16 => "s",
                                                   Cchar => "c",
                                                   String => "str",
                                                   Cvoid => "v")

_lsl_push_sample_tp(o, d::Vector{Float32}, ts, pt)  = lib.lsl_push_sample_ftp(o, d, ts, pt)
_lsl_push_sample_tp(o, d::Vector{Float64}, ts, pt)  = lib.lsl_push_sample_dtp(o, d, ts, pt)
@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
  _lsl_push_sample_tp(o, d::Vector{Clong}, ts, pt)    = lib.lsl_push_sample_ltp(o, d, ts, pt)
end
_lsl_push_sample_tp(o, d::Vector{Int32}, ts, pt)    = lib.lsl_push_sample_itp(o, d, ts, pt)
_lsl_push_sample_tp(o, d::Vector{Int16}, ts, pt)    = lib.lsl_push_sample_stp(o, d, ts, pt)
_lsl_push_sample_tp(o, d::Vector{Cchar}, ts, pt)    = lib.lsl_push_sample_ctp(o, d, ts, pt)
_lsl_push_sample_tp(o, d::Vector{Cvoid}, ts, pt)    = lib.lsl_push_sample_vtp(o, d, ts, pt)
_lsl_push_sample_tp(o, d::Vector{String}, ts, pt)   = lib.lsl_push_sample_strtp(o, d, ts, pt)

 """
    push_sample(outlet::StreamOutlet{T},
                data::Vector{T};
                timestamp = 0.0,
                pushthrough = true)
                
Push a sample into the outlet. Each entry in the vector corresponds to one channel.

# Keyword arguments      
-`timestamp::Number`: Capture time of the sample, in agreement with `local_clock()`, if
                      ommitted, the current time is used.
- `passthrough::Bool`: Whether to push the sample through to the receivers instead of
                       buffering it with subsequent samples. Note that the chunk_size, if
                       specified at outlet construction, takes precedence over the
                       pushthrough flag.
""" 
function push_sample(outlet::StreamOutlet{T},
                     data::Vector{T};
                     timestamp = 0.0,
                     pushthrough = true) where T

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(_lsl_push_sample_tp(outlet, data, timestamp, pushthrough))
end

#
# Push chunk
#

# Type mappings
_lsl_push_chunk_tp(o, d::Matrix{Float32}, ts::Number, pt) = lib.lsl_push_chunk_ftp(o, d, length(d), ts, pt)
_lsl_push_chunk_tp(o, d::Matrix{Float64}, ts::Number, pt) = lib.lsl_push_chunk_dtp(o, d, length(d), ts, pt)
@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
  _lsl_push_chunk_tp(o, d::Matrix{Clong}, ts::Number, pt)   = lib.lsl_push_chunk_ltp(o, d, length(d), ts, pt)
end
_lsl_push_chunk_tp(o, d::Matrix{Int32}, ts::Number, pt)   = lib.lsl_push_chunk_itp(o, d, length(d), ts, pt)
_lsl_push_chunk_tp(o, d::Matrix{Int16}, ts::Number, pt)   = lib.lsl_push_chunk_stp(o, d, length(d), ts, pt)
_lsl_push_chunk_tp(o, d::Matrix{Cchar}, ts::Number, pt)   = lib.lsl_push_chunk_ctp(o, d, length(d), ts, pt)
_lsl_push_chunk_tp(o, d::Matrix{Cvoid}, ts::Number, pt)   = lib.lsl_push_chunk_vtp(o, d, length(d), ts, pt)
#_lsl_push_chunk_tp(o, d::Vector{String}, ts::Number, pt)  = lsl_push_chunk_strtp(o, d, length(d), ts, pt)

_lsl_push_chunk_tnp(o, d::Matrix{Float32}, ts::Vector, pt) = lib.lsl_push_chunk_ftnp(o, d, length(d), ts, pt)
_lsl_push_chunk_tnp(o, d::Matrix{Float64}, ts::Vector, pt) = lib.lsl_push_chunk_dtnp(o, d, length(d), ts, pt)
@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
  _lsl_push_chunk_tnp(o, d::Matrix{Clong}, ts::Vector, pt)   = lib.lsl_push_chunk_ltnp(o, d, length(d), ts, pt)
end
_lsl_push_chunk_tnp(o, d::Matrix{Int32}, ts::Vector, pt)   = lib.lsl_push_chunk_itnp(o, d, length(d), ts, pt)
_lsl_push_chunk_tnp(o, d::Matrix{Int16}, ts::Vector, pt)   = lib.lsl_push_chunk_stnp(o, d, length(d), ts, pt)
_lsl_push_chunk_tnp(o, d::Matrix{Cchar}, ts::Vector, pt)   = lib.lsl_push_chunk_ctnp(o, d, length(d), ts, pt)
_lsl_push_chunk_tnp(o, d::Matrix{Cvoid}, ts::Vector, pt)   = lib.lsl_push_chunk_vtnp(o, d, length(d), ts, pt)
#_lsl_push_chunk_tnp(o, d::Vector{String}, ts::Vector, pt)  = lsl_push_chunk_strtnp(o, d, length(d), ts, pt)

"""
push_chunk(outlet::StreamOutlet{T},
           data::Matrix{T};
           timestamp = 0.0,
           pushthrough = true)
            
Push a chunk of samples into the outlet.

Each sample consists of the column of the matrix `data` such that size(data) = (M,N) where
M is the channel count of the outlet, and N is the number of samples in the chunk.

# Keyword arguments      
-`timestamp::Number`: Capture time of the sample, in agreement with `local_clock()`, if
                  ommitted, the current time is used.
- `passthrough::Bool`: Whether to push the sample through to the receivers instead of
                   buffering it with subsequent samples. Note that the chunk_size, if
                   specified at outlet construction, takes precedence over the
                   pushthrough flag.
""" 
function push_chunk(outlet::StreamOutlet{T},
                    data::Matrix{T};
                    timestamp = 0.0,
                    pushthrough = true) where T

  size(data,1) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(_lsl_push_chunk_tp(outlet, data, timestamp, pushthrough))
end

"""
push_chunk(outlet::StreamOutlet{T},
           data::Matrix{T},
           timestamp::Vector{Float64};
           pushthrough = true)
            
Push a chunk of samples into the outlet with individual timestamps.

Each sample consists of the column of the matrix `data` such that size(data) = (M,N) where
M is the channel count of the outlet, and N is the number of samples in the chunk.

# Arguments
-`timestamps`: Capture time of the sample, in agreement with `local_clock()`, if ommitted,
               the current time is used.

# Keyword arguments      
-`passthrough::Bool`: Whether to push the sample through to the receivers instead of
                      buffering it with subsequent samples. Note that the chunk_size, if
                      specified at outlet construction, takes precedence over the
                      pushthrough flag.
""" 
function push_chunk(outlet::StreamOutlet{T},
                    data::Matrix{T},
                    timestamp::Vector;
                    pushthrough = true) where T

  size(data,2) == length(timestamp) || error("number of timestamps != chunk_count")
  size(data,1) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(_lsl_push_chunk_tnp(outlet, data, timestamp, pushthrough))
end


# """
# push_chunk(outlet::StreamOutlet{T},
#            data::Vector{Vector{T}};
#            timestamp = 0.0,
#            pushthrough = true)
            
# Push a vector of samples into the outlet. 

# Each entry in the vector corresponds sample, and each entry in the underlying vector
# corresponds to one channel.

# Note that this function must allocate a new vector to concatenate the individual samples, it
# is preferable to specify the chunks as a matrix of N columns, where there are N samples in 
# the chunk.

# # Keyword arguments      
# -`timestamp::Number`: Capture time of the most recent sample, in agreement with
#                       local_clock(); if omitted, the current time is used. The time stamps
#                       of other samples are automatically derived according to the sampling
#                       rate of the stream.
# - `passthrough::Bool`: Whether to push the sample through to the receivers instead of
#                        buffering it with subsequent samples. Note that the chunk_size, if
#                        specified at outlet construction, takes precedence over the
#                        pushthrough flag.
# """ 
# function push_chunk(outlet::StreamOutlet{T},
#                     data::Vector{Vector{T}};
#                     timestamp = 0.0,
#                     pushthrough = true) where T

#   # Check all samples are the same, and the correct length
#   if !all(length(d) == channel_count(outlet.info) for d in data)
#     error("at least one data length ≂̸ channel count")
#   end
#   dmat = hcat(data...)
#   push_chunk(outlet, dmat, timestamp = timestamp, passthrough = passthrough)
# end

#
# Utility functions
#

"""
    have_consumers(outlet::StreamOutlet)

Return true if consumers are currently registered, false otherwise.
"""
have_consumers(outlet::StreamOutlet) = lib.lsl_have_consumers(outlet) > 0 ? true : false


"""
    wait_for_consumers(outlet::SteamOutlet)

Wait until some consumer shows up (without wasting resources).

Returns true if succesful, false if timeout ocurred.
"""
function wait_for_consumers(outlet::StreamOutlet, timeout)
  status = lib.lsl_wait_for_consumers(outlet, timeout)
  return status == 1 ? true : false
end

""" 
    info(outlet::StreamOutlet)

Return a StreamInfo record provided by the outlet.

This is what was used to create the stream (and also has the Additional Network Information
fields assigned).
"""
function info(outlet::StreamOutlet{T}) where T
  handle = lib.lsl_get_info(outlet)
  return StreamInfo(handle, T)
end

