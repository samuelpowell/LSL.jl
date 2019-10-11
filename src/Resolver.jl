# LSL.jl: Julia interface for Lab Streaming Layer
# Copyright (C) 2019 Samuel Powell

# Resolver.jl: functions and types for resolving streams

export resolve_streams, resolve_byprop, resolve_bypred

const MAX_RESOLVE = 1024

"""
    Continuous Resolver

A convenience class resolving streams continuously in the background. This object can be
queried at any time for the set of streams that are currently visible on the network.
"""
mutable struct ContinuousResolver
  handle::lib.lsl_continuous_resolver

  function ContinuousResolver(handle)
    resolver = new(handle)
    finalizer(_destroy, resolver)
  end

end

# Define conversion to pointer
unsafe_convert(::Type{lib.lsl_continuous_resolver}, resolver::ContinuousResolver) = resolver.handle

function _destroy(resolver::ContinuousResolver)
  if resolver.handle != C_NULL
    lib.lsl_destroy_continuous_resolver(resolver)
  end
  return nothing
end

""" 
    ContinuousResolver(; forget_after = 5.0)

Construct a continuous resolver which resolves all streams on the network.

# Keyword arguments
`forget_after::Number`: When a stream is no longer visible on the network (e.g., because it
                        was shut down), this is the time in seconds after which it is no
                        longer reported by the resolver.
"""
function ContinuousResolver(; forget_after = 5.0)
  handle = lib.lsl_create_continuous_resolver(forget_after)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during ContinuousResolver creation")
  end
  return ContinuousResolver(handle)
end

"""
  ContinuousResolver(prop = "", value = ""; forget_after = 5.0)

Construct a continuous resolver that resolves all streams with a specific value for a
given property.

This is analogous to the functionality provided by the function resolve_stream(prop,value).

# Arguments
-`prop::String`: The StreamInfo property that should have a specific value (e.g., "name",
"type", "source_id", or "desc/manufaturer").
-`value::String`: The string value that the property should have (e.g., "EEG" as the type
                         property).

# Keyword arguments
-`forget_after::Number`: When a stream is no longer visible on the network (e.g., because it
                        was shut down), this is the time in seconds after which it is no
                        longer reported by the resolver.
"""
function ContinuousResolver(prop::String, value::String; forget_after = 5.0)
  handle = lib.lsl_create_continuous_resolver_byprop(prop, value, forget_after)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during ContinuousResolver creation")
  end
  return ContinuousResolver(handle)
end


"""
  ContinuousResolver(predicate; forget_after = 5.0)

Construct a new continuous resolver that resolves all streams that match a given XPath
1.0 predicate.

This is analogous to the functionality provided by the free function resolve_bypred

# Arugments
-`predicate::String`: Predicate string, e.g. "name='BioSemi'" or "type='EEG' and
starts-with(name,'BioSemi') and count(description/desc/channels/channel)=32"

# Keyword arguments
-`forget_after::Number`: When a stream is no longer visible on the network (e.g., because it
                        was shut down), this is the time in seconds after which it is no
                        longer reported by the resolver.
"""
function ContinuousResolver(predicate::String; forget_after = 5.0)
  handle = lib.lsl_create_continuous_resolver_bypred(predicate, forget_after)
  if handle == C_NULL
    error("liblsl library returned NULL pointer during ContinuousResolver creation")
  end
  return ContinuousResolver(handle)
end


"""
    resolve_streams(;timeout = 1.0)

Returns all currently available streams from any outlet on the network. 

The network is usually the subnet specified at the local router, but may also include a
group of machines visible to each other via multicast packets (given that the network
supports it), or list of hostnames. These details may optionally be customized by the
experimenter in a configuration file (see Network Connectivity in the LSL wiki).  
                         
Returns a vector of StreamInfo objects (with empty desc field), any of which can
subsequently be used to open an inlet. The full description can be retrieved from the inlet.

# Keyword arguments:
-`timeout`: The waiting time for the operation, in seconds, to search for streams. Warning:
            If this is too short (<0.5s) only a subset (or none) of the outlets that are
            present on the network may be returned.
"""
function resolve_streams(;timeout = 1.0)
  infoptrs = Vector{lib.lsl_streaminfo}(undef, MAX_RESOLVE)
  nstreams = handle_error(lib.lsl_resolve_all(infoptrs, MAX_RESOLVE, timeout))
  infos = Vector{StreamInfo}(undef, nstreams)
  for i in 1:nstreams
    format_type = _jl_channel_format(lib.lsl_get_channel_format(infoptrs[i]))
    infos[i] = StreamInfo(infoptrs[i], format_type)
  end
  return infos 
end

"""
    resolve_byprop(prop, value; minimum = 1, timeout = LSL_FOREVER)

Resolve all streams with a specific value for a given property.

If the goal is to resolve a specific stream, this method is preferred over resolving all
streams and then selecting the desired one.

Returns a vector of matching StreamInfo objects (with empty desc field), any of which can
subsequently be used to open an inlet.

# Arguments
-`prop::String`: The StreamInfo property that should have a specific value (e.g., "name",
                "type", "source_id", or "desc/manufaturer").
-`value::String`: The string value that the property should have (e.g., "EEG" as the type
                 property).

# Keyword arguments
-`minimum::Integer`: Return at least this many streams.
-`timeout::Number`: A timeout of the operation, in seconds. If the timeout expires, less than
                   the desired number of streams (possibly none) will be returned.                   

# Example
results = resolve_byprop("type", "EEG")                  
"""
function resolve_byprop(prop::String, value::String; minimum = 1, timeout = FOREVER)
  infoptrs = Vector{lib.lsl_streaminfo}(undef, MAX_RESOLVE)
  nstreams = handle_error(lib.lsl_resolve_byprop(infoptrs, MAX_RESOLVE,
                                                 prop, value, minimum, timeout))
  infos = Vector{StreamInfo}(undef, nstreams)
  for i in 1:nstreams
    format_type = _jl_channel_format(lib.lsl_get_channel_format(infoptrs[i]))
    infos[i] = StreamInfo(infoptrs[i], format_type)
  end
  return infos 
end

"""
    resolve_bypred(predicate; minimum = 1, timeout = LSL_FOREVER)

Resolve all streams that match a given predicate.
   
Advanced query that allows to impose more conditions on the retrieved streams; the given
string is an XPath 1.0 predicate for the <description> node (omitting the surrounding []'s),
see also http://en.wikipedia.org/w/index.php?title=XPath_1.0&oldid=474981951.
              
Returns a vector of matching StreamInfo objects (with empty desc field), any of which can
subsequently be used to open an inlet.

# Argumennts:
-`predicate::String`: Predicate string, e.g. "name='BioSemi'" or "type='EEG' and
                     starts-with(name,'BioSemi') and count(description/desc/channels/channel)=32"

# Keyword arguments
-`minimum::Integer`: Return at least this many streams.
-`timeout::Number`: A timeout of the operation, in seconds. If the timeout expires, less than
                  the desired number of streams (possibly none) will be returned.             
"""
function resolve_bypred(predicate::String; minimum = 1, timeout = FOREVER)
  infoptrs = Vector{lib.lsl_streaminfo}(undef, MAX_RESOLVE)
  nstreams = handle_error(lib.lsl_resolve_bypred(infoptrs, MAX_RESOLVE,
                                                 predicate, minimum, timeout))
  infos = Vector{StreamInfo}(undef, nstreams)
  for i in 1:nstreams
    format_type = _jl_channel_format(lib.lsl_get_channel_format(infoptrs[i]))
    infos[i] = StreamInfo(infoptrs[i], format_type)
  end
  return infos 
end

