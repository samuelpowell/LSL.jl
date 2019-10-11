# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# StreamInlet.jl: type and method definitions for steam inlet

export StreamInlet
export open_stream, close_stream, set_postprocessing, pull_sample, pull_sample!, pull_chunk
export was_clock_reset, smoothing_halftime, samples_available

mutable struct StreamInlet{T}
  handle::lib.lsl_inlet
  info::StreamInfo{T}

  function StreamInlet(handle, info::StreamInfo{T}) where T
    inlet = new{T}(handle, info)
    finalizer(_destroy, inlet)
  end
end

# Destroy a StreamInfo handle
function _destroy(inlet::StreamInlet)
  if inlet.handle != C_NULL
    lib.lsl_destroy_inlet(inlet)
  end
  return nothing
end

# Define conversion to pointer
unsafe_convert(::Type{lib.lsl_inlet}, inlet::StreamInlet) = inlet.handle

# Define constructor
"""
    StreamInlet(info; max_buflen = 360, max_chunklen = 0, recover = True, procesing_flags = 0)

Establish a new stream inlet from a resolved stream description.

# Arguments
- `info::StreamInfo`: A resolved stream description object (as coming from one of the
                      resolver functions). Note: the stream_inlet may also be constructed
                      with a fully-specified stream_info, if the desired channel format and
                      count is already known up-front, but this is strongly discouraged and
                      should only ever be done if there is no time to resolve the stream
                      up-front (e.g., due to limitations in the client program).                  

# Keyword arguments
- `max_buflen::Integer`: The maximum amount of data to buffer (in seconds if there is a
                         nominal sampling rate, otherwise x100 in samples). Recording
                         applications want to use a fairly large buffer size here, while
                         real-time applications would only buffer as much as they need to 
                         perform their next calculation.
- `max_chunklen::Integer`: The maximum size, in samples, at which chunks are transmitted
                           (the default corresponds to the chunk sizes used by the sender).
                           Recording programs can use a generous size here (leaving it to
                           the network how to pack things), while real-time applications may 
                           want a finer (perhaps 1-sample) granularity. If left unspecified
                           (=0), the sender determines the chunk granularity.
- `recover::Bool`: Try to silently recover lost streams that are recoverable (those that 
                   have a source_id set). In all other cases (recover is false, or the 
                   stream is not recoverable), functions may throw a lost_error if the 
                   stream's source is lost (e.g., due to an app or computer crash).
"""
function StreamInlet(info::StreamInfo{T}; 
                     max_buflen = 360,
                     max_chunklen = 0,
                     recover = true,
                     processing_flags = 0) where T

  # Create and test handle
  handle = lib.lsl_create_inlet(info, max_buflen, max_chunklen, recover)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during StreamInlet creation")
  end

  if processing_flags > 0
    handle_error(lib.lsl_set_postprocessing(handle, processing_flags))
  end
  
  return StreamInlet(handle, info)
end

#
# Open close and time correction
#

"""
    open_stream(inlet::StreamInlet; timeout=LSL_FOREVER)
    
Subscribe to the data stream.

All samples pushed in at the other end from this moment onwards will be queued and
eventually be delivered in response to pull_sample() or pull_chunk() calls. Pulling a sample
without some preceding open_stream is permitted (the stream will then be opened implicitly).

Function may throw a timeout error, or lost error (if the stream source has been lost).

# Keyword arguments
- `timeout::Number`: timeout of the operation.
"""
function open_stream(inlet::StreamInlet; timeout = FOREVER)
  errcode = Ref{Int32}(0)
  lib.lsl_open_stream(inlet, timeout, errcode)
  handle_error(errcode[])
  return inlet
end

"""
    close_stream(inlet::StreamInlet)

Drop the current data stream.

All samples that are still buffered or in flight will be dropped and transmission and
buffering of data for this inlet will be stopped. If an application stops being interested
in data from a source (temporarily or not) but keeps the outlet alive, it should call
lsl_close_stream() to not waste unnecessary system and network  resources.
"""
close_stream(inlet::StreamInlet) = lib.lsl_close_stream(inlet)

"""
    time_correction(inlet::StreamInlet; timeout = LSL_FOREVER)

Retrieve an estimated time correction offset for the given stream.
  
The first call to this function takes several miliseconds until a reliable first estimate is
obtained. Subsequent calls are instantaneous (and rely on periodic background updates). The
precision of these estimates should be below 1 ms (empirically within +/-0.2 ms).

Returns the current time correction estimate. This is the number that needs to be added to a
time stamp that was remotely generated via local_clock() to map it into the local clock
domain of this machine.

Function may throw a timeout error, or lost error (if the stream source has been lost).

# Keyword arguments
`timeout::Number`: timeout to acquire the first time-correction estimate.
"""
function time_correction(inlet::StreamInlet; timeout = FOREVER)
  errcode = Ref{Int32}(0) #Ref{lsl_error_code_t}(lsl_error_code_t(0))
  timcorr = lib.lsl_time_correction(inlet, timeout, errcode)
  handle_error(errcode[])
  return timcorr
end

"""
  set_postprocessing(inlet::StreamInlet, flags::UInt32)

Set post-processing flags to use.

By default, the inlet performs NO post-processing and returns the ground-truth time stamps,
which can then be manually synchronized using time_correction(), and then 
smoothed/dejittered if desired. This function allows automating these two and possibly more
operations.

Warning: when you enable this, you will no longer receive or be able to recover the original
time stamps.

Function may throw an argument error if unknown flags are supplied.

# Arguments:
`flags::UInt32`: An integer that is the result of bitwise OR'ing one or more options from
                 processing_options_t together. A good setting is to use post_ALL.
                 
"""
function set_postprocessing(inlet::StreamInlet, flags::UInt32)
  handle_error(lib.lsl_set_postprocessing(inlet, flags))
  return inlet
end


#
# Pull samples
#

# Type mapping
_lsl_pull_sample(i, d::Vector{Float32}, to, ec) = lib.lsl_pull_sample_f(i, d, length(d), to, ec)
_lsl_pull_sample(i, d::Vector{Float64}, to, ec) = lib.lsl_pull_sample_d(i, d, length(d), to, ec)
@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
  _lsl_pull_sample(i, d::Vector{Clong},   to, ec) = lib.lsl_pull_sample_l(i, d, length(d), to, ec)
end
_lsl_pull_sample(i, d::Vector{Int32},   to, ec) = lib.lsl_pull_sample_i(i, d, length(d), to, ec)
_lsl_pull_sample(i, d::Vector{Int16},   to, ec) = lib.lsl_pull_sample_s(i, d, length(d), to, ec)
_lsl_pull_sample(i, d::Vector{Cchar},   to, ec) = lib.lsl_pull_sample_c(i, d, length(d), to, ec)

"""
    pull_sample(inlet::StreamInfo; timeout = LSL_FOREVER)

Pull a sample from the inlet and return as a vector of appropriate type.

Function may throw timeout error, lost error if the stream has been lost. Note that if a
timeout occurrs, or if a timeout of 0.0 is specified an no new sample is available, the 
timestamp will be 0.0.

# Keyword arguments
`timeout::Number`: timeout to acquire the sample.
"""
function pull_sample(inlet::StreamInlet{T}; timeout = FOREVER) where T
  data = Vector{T}(undef, channel_count(inlet.info))
  return pull_sample!(data, inlet, timeout=timeout)
end

"""
    pull_sample!(data::Vector{T}, inlet::StreamInfo; timeout = LSL_FOREVER)

Pull a sample from the inlet and assign to provided vector.

Function may throw timeout error, lost error if the stream has been lost. Note that if a
timeout occurrs, or if a timeout of 0.0 is specified an no new sample is available, the 
timestamp will be 0.0.

# Keyword arguments
`timeout::Number`: timeout to acquire the sample.
"""
function pull_sample!(data::Vector{T}, inlet::StreamInlet{T}; timeout = FOREVER) where T
  length(data) == channel_count(inlet.info) || error("data length ≂̸ channel count")
  errcode = Ref{Int32}(0); 
  timestamp = _lsl_pull_sample(inlet, data, timeout, errcode)
  handle_error(errcode[])
  return timestamp, data
end

#
# Pull chunks
#

# Type mapping
_lsl_pull_chunk(i, d::VecOrMat{Float32}, ts, to, ec) = lib.lsl_pull_chunk_f(i, d, ts, length(d), length(ts), to, ec)
_lsl_pull_chunk(i, d::VecOrMat{Float64}, ts, to, ec) = lib.lsl_pull_chunk_d(i, d, ts, length(d), length(ts), to, ec)
@static if !Sys.iswindows() && Sys.WORD_SIZE == 64
  _lsl_pull_chunk(i, d::VecOrMat{Clong},   ts, to, ec) = lib.lsl_pull_chunk_l(i, d, ts, length(d), length(ts), to, ec)
end
_lsl_pull_chunk(i, d::VecOrMat{Int32},   ts, to, ec) = lib.lsl_pull_chunk_i(i, d, ts, length(d), length(ts), to, ec)
_lsl_pull_chunk(i, d::VecOrMat{Int16},   ts, to, ec) = lib.lsl_pull_chunk_s(i, d, ts, length(d), length(ts), to, ec)
_lsl_pull_chunk(i, d::VecOrMat{Cchar},   ts, to, ec) = lib.lsl_pull_chunk_c(i, d, ts, length(d), length(ts), to, ec)

"""
    pull_chunk(inlet::StreamInfo; max_samples = 1024, timeout = LSL_FOREVER)

Pull a chunk of data from the inlet and assign to provided matrix.

Function returns a vector of timestamps of length N, being <= `max_samples` alongside a 
matrix of data where each column consists of a sample such that size(data) = (M,N)

Function may throw timeout error, lost error if the stream has been lost. Note that if a
timeout occurrs, or if a timeout of 0.0 is specified an no new sample is available, the 
timestamp will be 0.0.

# Keyword arguments
`timeout::Number`: timeout to acquire the sample.
"""
function pull_chunk(inlet::StreamInlet{T}; max_samples = 1024, timeout = FOREVER) where T
  slen = Int(channel_count(inlet.info))
  data = zeros(T, slen * max_samples)
  timestamps = zeros(Float64, max_samples)
  errcode = Ref{Int32}(0); 

  # Pull the chunk, getting the number of individual sample elements, form number of chunks
  dlen = Int(_lsl_pull_chunk(inlet, data, timestamps, timeout, errcode))
  clen = Int(dlen ÷ channel_count(inlet.info))
  handle_error(errcode[])

  # Shrink data and timestamp vector to output length, reshape data to matrix
  resize!(data, dlen)
  data = reshape(data, slen, clen) 
  resize!(timestamps, clen)
  return timestamps, data
end

#
# Utility functions
#

"""
  samples_available(inlet::StreamInlet)

Query whether samples are currently available for immediate pickup.

Note that it is not a good idea to use samples_available() to determine whether a pull_*()
call would block: to be sure, set the pull timeout to 0.0 or an acceptably low value. If the
underlying implementation supports it, the value will be the number of samples available
(otherwise it will be 1 or 0).
"""
samples_available(inlet::StreamInlet) = lib.lsl_samples_available(inlet)

"""
    was_clock_reset(inlet::StreamInlet)

Query whether the clock was potentially reset since the last call to was_clock_reset().

This is rarely-used function is only needed for applications that combine multiple
time_correction values to estimate precise clock drift if they should tolerate cases where
the source machine was hot-swapped or restarted.
"""
was_clock_reset(inlet::StreamInlet) = lib.lsl_was_clock_reset(inlet)

"""
  smoothing_halftime(inlet::StreamInlet, value)

Override the half-time (forget factor) of the time-stamp smoothing.

The default is 90 seconds unless a different value is set in the config file. Using a longer
window will yield lower jitter in the time stamps, but longer windows will have trouble
tracking changes in the clock rate (usually due to temperature changes); the default is able
to track changes up to 10 degrees C per minute sufficiently well.

# Arguments
`value::Number`: The new value, in seconds. This is the time after which a past sample will
                 be weighted by 1/2 in the exponential smoothing window.
"""
smoothing_halftime(inlet, value) = handle_error(lib.lsl_smoothing_halftime(inlet, value))

