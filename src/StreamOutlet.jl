# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# StreamOutlet.jl: type and method definitions for steam outlet

export StreamOutlet

export push_sample, push_chunk, have_consumers, wait_for_consumers

mutable struct StreamOutlet{T}
  handle::lsl_outlet
  info::StreamInfo{T}

  function StreamOutlet(handle, info::StreamInfo{T}) where T
    outlet = new{T}(handle, info)
    finalizer(_destroy, outlet)
  end

end

# Destroy a StreamInfo handle
function _destroy(outlet::StreamOutlet)
  if outlet.handle != C_NULL
    lsl_destroy_outlet(outlet)
  end
  return nothing
end

# Define conversion to pointer
unsafe_convert(::Type{lsl_outlet}, outlet::StreamOutlet) = outlet.handle

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
  handle = lsl_create_outlet(info, chunk_size, max_buffered)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during StreamOutlet creation")
  end

  # Create an internal information object
  info = lsl_get_info(handle)
  
  return StreamOutlet(handle, StreamInfo(info, T))
end


#
# Push sample
#

const _lsl_typestring_map = Dict{DataType, String}(Float32 => "f",
                                                   Float64 => "d",
                                                   Clong => "l",
                                                   Int32 => "i",
                                                   Int16 => "s",
                                                   Cchar => "c",
                                                   String => "str",
                                                   Cvoid => "v")

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
function push_sample(outlet::StreamOutlet{Float32},
                     data::Vector{Float32};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_ftp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{Float64},
                     data::Vector{Float64};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_dtp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{Clong},
                     data::Vector{Clong};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_ltp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{Int32},
                     data::Vector{Int32};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_itp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{Int16},
                     data::Vector{Int16};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_stp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{Cchar},
                     data::Vector{Cchar};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_ctp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{String},
                     data::Vector{String};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_strtp(outlet, data, timestamp, pushthrough))
end

function push_sample(outlet::StreamOutlet{Cvoid},
                     data::Vector{Cvoid};
                     timestamp = 0.0,
                     pushthrough = true) 

  length(data) == channel_count(outlet.info) || error("data length ≂̸ channel count")
  handle_error(lsl_push_sample_vtp(outlet, data, timestamp, pushthrough))
end


#
# Push chunk
#


#
# Utility functions
#

"""
    have_consumers(outlet::StreamOutlet)

Return true if consumers are currently registered, false otherwise.
"""
have_consumers(outlet::StreamOutlet) = lsl_have_consumers(outlet) > 0 ? true : false


"""
    wait_for_consumers(outlet::SteamOutlet)

Wait until some consumer shows up (without wasting resources).

Returns true if succesful, false if timeout ocurred.
"""
function wait_for_consumers(outlet::StreamOutlet, timeout)
  status = lsl_wait_for_consumers(outlet, timeout)
  return status == 1 ? true : false
end

""" 
    info(outlet::StreamOutlet)

Return a StreamInfo record provided by the outlet.

This is what was used to create the stream (and also has the Additional Network Information
fields assigned).
"""
function info(outlet::StreamOutlet{T}) where T
  handle = lsl_get_info(outlet)
  return StreamInfo(handle, T)
end

